### MQ MFT Setup and Configuration on OCP

There are two sections:
- Installation of the MQ Operator and creation of 4 QMGRs on OCP
- Agent setup and testing on a Unix type of system
---
### Installation and Setup of MQ on OCP

Please note the following:
- An [IBM Entitlement Key](https://myibm.ibm.com/products-services/containerlibrary) is necessary before installation the MQ Operator.  
- The user must be logged into OCP, have the necessary permissions, and be in the namespace/project where MQ will be installed and deployed
- The script,`setupFTEQmgrs.sh`, should be run from within the FTESetup directory

The script will do the following:
- Create a Secret for the IBM Entitlement Key, if necessary
- Create the CatalogSource for IBM Container Registry, if necessary
- Install the MQ Operator, if necessary
- Create a Secret for the TLS key, which is shared amongst all the QMGRs
- Create the necessary Queues, Topics, Channels, and other Objects for each QMGR and place it in a ConfigMap
- Create 4 QMGRs based on the ConfigMap and Secrets
  - Coordination QMGR (FTECOORD)
  - Command QMGR (FTPCMD)
  - Agent2 QMGR (FTEAGENT1)
  - Agent2 QMGR (FTEAGENT2)
- Make sure the Pods are running
- Create the necessary Routes for the channels and export the hostname to a file called, `urls.sh`, that will be placed in the AgentSetup directory.
---
### Setup fo the Agents on a Unix System

The first step is to transfer the contents of the `AgentSetup` directory, including the file created by the previous step, to the target machine that will host the MQ MFT Agents.  It is necessary to already have MQ and MQ MFT installed on the system.

The script, `setupAgents.sh`, should be run within the AgentSetup directory.

The script will do the following:
- Setup the connection the Coordination QMGR
- Setup the connection to the Command QMGR
- Create 2 Agents, AGENT1 and AGENT2, and connect them to the appropriate QMGRs
- Set the proper permissions on the keystore and credentials files
- Make sure the agents are registered and active
- Create a temporary file and transer it from AGENT1 to AGENT2
---
The MQ Channels between the QMGRs should start automatically once the `fteListAgents` and file transfer commands are issued.  If they are not started, then the transfer may not be successful, and the MQ Channels will have to be started manually.  

This is only using a single instance QMGR for each of the QMGRs and is not considered fault tolerant.  NativeHA should be considered to have high availability, and the QMGRs should be part of a Cluster, alond witht he Queues, Topics, Channels, for the best results.
