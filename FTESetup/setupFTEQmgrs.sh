#!/bin/bash
# Script to setup MQ on OCP with 4 QMGRs
#
# Brian S Paskin
# 9/8/2022

function check_status() {
   if [ $1 -ne 0 ]; then
      echo "failed."
      exit 1
   else
      echo "pass."
   fi
}

function getDate() {
	echo "[`date "+%Y-%m-%d %H:%M:%S"`] "
}

# check oc is installed
echo -n $(getDate)  "Checking whether oc is installed ... "
which oc 1>/dev/null 2>&1
check_status $?

# check whether the user is logged in
echo -n $(getDate)  "Checking whether user is logged into OCP ... "
oc status >/dev/null 2>&1
check_status $?

# check if entitlement key is there
echo -n $(getDate)  "Checking if entitlement key is present ... "
oc get secret ibm-entitlement-key  > /dev/null 2>&1

if [ $? -eq 0 ]; then
   echo "installed."
else 
   echo "not installed."

   while true; do
      read -p "IBM Entitlement Key: " ENTITLEMENT_KEY
      if [ ${#ENTITLEMENT_KEY} -ne 0 ]; then
         break
      fi
   done

   echo -n $(getDate)  "Creating entitlement key Secret ... "
   oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLEMENT_KEY > /dev/null 2>&1
   check_status $?
fi 

# check if MQ operator is installed
echo -n $(getDate)  "Checking whether MQ Operator is installed ... "
MESSAGE=`oc get csv 2>&1`
INSTALLED=1

if [[ $MESSAGE !=  *"No resources found"* ]]; then
   oc get csv | grep ibm-mq | grep -i Succeeded > /dev/null 2>&1
   if [ $? -eq 0 ]; then
      echo "installed."
      INSTALLED=0
      STATUS=0
   fi
fi

if [ $INSTALLED -ne 0 ]; then
   echo "not installed."

   echo -n $(getDate) "Installing MQ Operator ... "
   oc apply -f mqinstall.yaml > /dev/null 2>&1
   check_status $?

   echo -n $(getDate) "Waiting (45 min) for successfull install ... "

   STATUS=1
   TIMEOUT=$((SECONDS + 2700))
   while [ $SECONDS -lt $TIMEOUT ]; do
      MESSAGE=`oc get csv 2>&1`
      if [[ $MESSAGE !=  *"No resources found"* ]]; then
         oc get csv | grep ibm-mq | grep -i Succeeded > /dev/null 2>&1
         if [ $? -eq 0 ]; then
            echo "Succeeded."
            STATUS=0
            break
         fi
      fi

      sleep 5
   done

   if [ $STATUS -ne 0 ]; then
      echo "Not Successesful"
      exit 1
   fi 
fi
echo -n $(getDate)  "Running script to setup FTE QMGRs ... "
oc apply -f fte-create.yaml > /dev/null 2>&1 
check_status $?

# Check each qmgrs are Running
echo -n $(getDate)  "Checking if QMGR Pods are running ... "


STATUS=1
TIMEOUT=$((SECONDS + 2700))
while [ $SECONDS -lt $TIMEOUT ]; do

   MESSAGE=`oc get pod qmgr-fteagent1-ibm-mq-0 qmgr-fteagent2-ibm-mq-0 qmgr-ftecmd-ibm-mq-0 qmgr-ftecoord-ibm-mq-0 2>&1`
   
   if [[ MESSAGE != *"NotFound"* ]]; then
     count=`oc get pod qmgr-fteagent1-ibm-mq-0 qmgr-fteagent2-ibm-mq-0 qmgr-ftecmd-ibm-mq-0 qmgr-ftecoord-ibm-mq-0 | grep -i Running | wc -l`
      
     if [ $count == "4" ]; then
        echo "Succeeded."
        STATUS=0
        break
     fi
   fi 

   sleep 5
done

if [ $STATUS -ne 0 ]; then
   echo "Not Successesful"
   exit 1
fi

echo -n $(getDate)  "Getting URLs for FTE Setup ... "
echo COORD_URL=` oc get route qmgr-ftecoord-ibm-mq-qm -o jsonpath='{.spec.host}'` >> ../AgentSetup/urls.sh
echo CMD_URL=`oc get route qmgr-ftecmd-ibm-mq-qm -o jsonpath='{.spec.host}'` >> ../AgentSetup/urls.sh
echo AGENT1_URL=`oc get route qmgr-fteagent1-ibm-mq-qm -o jsonpath='{.spec.host}'` >> ../AgentSetup/urls.sh
echo AGENT2_URL=`oc get route qmgr-fteagent2-ibm-mq-qm -o jsonpath='{.spec.host}'` >> ../AgentSetup/urls.sh
echo "done."

chmod 755 ../AgentSetup/urls.sh

# Funeral Winter
