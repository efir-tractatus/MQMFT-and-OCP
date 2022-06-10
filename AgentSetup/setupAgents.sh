#!/bin/bash
# Script to setup 2 Agents on a System with MQ MFT
# 
# get URL for the QMGRs
# ex: oc get route qmgr-ftecoord-ibm-mq-qm -o jsonpath='{.spec.host}'
#
# Brian S Paskin
# 9/8/2022 

# variables need to be set.  
source urls.sh

MQ_HOME=/opt/mqm
DATA_DIR=/var/mqm/mqft/ # default is /var/mqm/mqft/

COORD_QMGR=FTECOORD
COORD_QMGR_PORT=443
#COORD_URL=
COORD_SVRCONN=FTECOORD.SVRCON

CMD_QMGR=FTECMD
CMD_QMGR_PORT=443
#CMD_URL=
CMD_SVRCONN=FTECMD.SVRCON

AGENT1_QMGR=FTEAGENT1
AGENT1_QMGR_PORT=443
#AGENT1_URL=
AGENT1_SVRCONN=FTEAGENT1.SVRCON

AGENT2_QMGR=FTEAGENT2
AGENT2_QMGR_PORT=443
#AGENT2_URL=
AGENT2_SVRCONN=FTEAGENT2.SVRCON

AGENT1_NAME=AGENT1
AGENT2_NAME=AGENT2

function check_status() {
   if [ $1 -ne 0 ]; then
      echo "failed."
      exit 1
   else
      echo "pass."
   fi
}

if [ -z "$COORD_URL" ]; then
   echo "Hostname variable for Coordination QMGR is missing, please update script"
   echo "oc get route qmgr-ftecoord-ibm-mq-qm -o jsonpath='{.spec.host}'"
   exit 1
fi

if [ -z "$CMD_URL" ]; then
   echo "Hostname variable for Command QMGR is missing, please update script"
   echo "oc get route qmgr-ftecmd-ibm-mq-qm -o jsonpath='{.spec.host}'"
   exit 1
fi 

if [ -z "$AGENT1_URL" ]; then
   echo "Hostname variable for Agent1 QMGR is missing, please update script"
   echo "oc get route qmgr-fteagent1-ibm-mq-qm -o jsonpath='{.spec.host}'"
   exit 1
fi 

if [ -z "$AGENT2_URL" ]; then
   echo "Hostname variable for Agent2 QMGR is missing, please update script"
   echo "oc get route qmgr-fteagent2-ibm-mq-qm -o jsonpath='{.spec.host}'"
   exit 1
fi 

echo -n "Check if MQ FTE is installed ... "
$MQ_HOME/bin/fteDisplayVersion >> /tmp/ftesetup.log 2>&1 
check_status $?

echo -n "Setting up Coordination QMGR ... "
$MQ_HOME/bin/fteSetupCoordination -coordinationQMgr $COORD_QMGR -coordinationQMgrHost $COORD_URL -coordinationQMgrPort $COORD_QMGR_PORT  -coordinationQMgrChannel $COORD_SVRCONN >> /tmp/ftesetup.log 2>&1
check_status $?

echo "coordinationSslCipherSpec=ECDHE_RSA_AES_256_CBC_SHA384" >> $DATA_DIR/config/$COORD_QMGR/coordination.properties 
echo "coordinationSslTrustStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12" >> $DATA_DIR/config/$COORD_QMGR/coordination.properties
echo "coordinationSslTrustStoreType=pkcs12"  >> $DATA_DIR/config/$COORD_QMGR/coordination.properties
echo "coordinationSslTrustStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml" >> $DATA_DIR/config/$COORD_QMGR/coordination.properties
echo "coordinationSslKeyStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml"  >> $DATA_DIR/config/$COORD_QMGR/coordination.properties
echo "coordinationSslKeyStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12"  >> $DATA_DIR/config/$COORD_QMGR/coordination.properties
echo "coordinationSslKeyStoreType=pkcs12" >> $DATA_DIR/config/$COORD_QMGR/coordination.properties

echo -n "Setting up Command QMGR ... "
$MQ_HOME/bin/fteSetupCommands -connectionQMgr $CMD_QMGR -connectionQMgrHost $CMD_URL  -connectionQMgrPort $CMD_QMGR_PORT -connectionQMgrChannel $CMD_SVRCONN -p $COORD_QMGR >> /tmp/ftesetup.log 2>&1
check_status $?

echo "connectionSslCipherSpec=ECDHE_RSA_AES_256_CBC_SHA384" >> $DATA_DIR/config/$COORD_QMGR/command.properties 
echo "connectionSslTrustStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12" >> $DATA_DIR/config/$COORD_QMGR/command.properties
echo "connectionSslTrustStoreType=pkcs12"  >> $DATA_DIR/config/$COORD_QMGR/command.properties
echo "connectionSslTrustStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml" >> $DATA_DIR/config/$COORD_QMGR/command.properties
echo "connectionSslKeyStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml"  >> $DATA_DIR/config/$COORD_QMGR/command.properties
echo "connectionSslKeyStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12"  >> $DATA_DIR/config/$COORD_QMGR/command.properties
echo "connectionSslKeyStoreType=pkcs12" >> $DATA_DIR/config/$COORD_QMGR/command.properties

echo -n "Creating AGENT1 ... "
$MQ_HOME/bin/fteCreateAgent -agentName $AGENT1_NAME -agentQMgr $AGENT1_QMGR -agentQMgrHost $AGENT1_URL -agentQMgrPort $AGENT1_QMGR_PORT -agentQMgrChannel $AGENT1_SVRCONN -p $COORD_QMGR >> /tmp/ftesetup.log 2>&1
check_status $?

echo "agentSslCipherSpec=ECDHE_RSA_AES_256_CBC_SHA384" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties 
echo "agentSslTrustStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties
echo "agentSslTrustStoreType=pkcs12"  >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties
echo "agentSslTrustStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties
echo "agentSslKeyStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml"  >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties
echo "agentSslKeyStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12"  >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties
echo "agentSslKeyStoreType=pkcs12" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT1_NAME/agent.properties

echo -n "Creating AGENT2 ... "
$MQ_HOME/bin/fteCreateAgent -agentName $AGENT2_NAME -agentQMgr $AGENT2_QMGR -agentQMgrHost $AGENT2_URL -agentQMgrPort $AGENT2_QMGR_PORT -agentQMgrChannel $AGENT2_SVRCONN -p $COORD_QMGR  >> /tmp/ftesetup.log 2>&1
check_status $?

echo "agentSslCipherSpec=ECDHE_RSA_AES_256_CBC_SHA384" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties 
echo "agentSslTrustStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties
echo "agentSslTrustStoreType=pkcs12"  >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties
echo "agentSslTrustStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties
echo "agentSslKeyStoreCredentialsFile=$DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml"  >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties
echo "agentSslKeyStore=$DATA_DIR/config/$COORD_QMGR/agenttls.p12"  >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties
echo "agentSslKeyStoreType=pkcs12" >> $DATA_DIR/config/$COORD_QMGR/agents/$AGENT2_NAME/agent.properties

if [ -f "MQMFTCredentials.xml" ]; then
   cp MQMFTCredentials.xml $DATA_DIR/config/$COORD_QMGR/
   chmod 600 $DATA_DIR/config/$COORD_QMGR/MQMFTCredentials.xml
else 
   echo "Missing MQMFTCredentials.xml ... exiting"
   exit 1
fi

if [ -f "MQMFTCredentials.xml" ]; then
  cp agenttls.p12 $DATA_DIR/config/$COORD_QMGR/
  chmod 600 $DATA_DIR/config/$COORD_QMGR/agenttls.p12
else 
   echo "Missing agenttls.p12 ... exiting"
   exit 1
fi

echo -n "Starting AGENT1 ... "
$MQ_HOME/bin/fteStartAgent $AGENT1_NAME  >> /tmp/ftesetup.log 2>&1
check_status $?

echo -n "Starting AGENT2 ... "
$MQ_HOME/bin/fteStartAgent $AGENT2_NAME >> /tmp/ftesetup.log 2>&1
check_status $?

sleep 30 

numStarted=`$MQ_HOME/bin/fteListAgents | grep -e ACTIVE -e READY | wc -l`
if [ $numStarted -ne 2 ]; then
   echo "Agents are not reporting started."
   echo "Run fteListAgents to make sure they are started and MQ Channels are running."
   exit 1
fi

mkdir -p /tmp/agent1/dropins
mkdir -p /tmp/agent2/received

echo "Funeral Winter" > /tmp/agent1/dropins/test.txt

echo -n "Testing file transfer ... "
fteCreateTransfer -sa $AGENT1_NAME -da $AGENT2_NAME -df /tmp/agent2/received/dest.txt  /tmp/agent1/dropins/test.txt >> /tmp/ftesetup.log 2>&1
check_status $?

sleep 5

if [ -f /tmp/agent2/received/dest.txt ]; then
   echo "Transfer was successful!"
else
   echo "Transfer was not successful"
fi


