# Inventory Flow - Integration Bus

This project is part of the 'IBM Integration Reference Architecture' suite, available at [https://github.com/ibm-cloud-architecture/refarch-integration](https://github.com/ibm-cloud-architecture/refarch-integration).

The goal of this project is to demonstrate how an IBM Integration Bus runtime can be deployed on premise or on IBM Cloud Private, running the gateway flows to expose REST api from SOAP back end services. We are implementing simple interface mapping flows.

# Table of Contents
* [IIB background](#ibm-integration-bus-background)
* [Server Installations](#server-installation)
* [Flow implementation tutorial](./docs/tutorial/README.md)
* [Deployment](#deployment)
* [CI/CD](#cicd)
* [Service Management](https://github.com/ibm-cloud-architecture/refarch-integration-esb#application-performance-management)
* [Compendium](https://github.com/ibm-cloud-architecture/refarch-integration#compendium)

# IBM Integration Bus Background

IBM Integration Bus is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money.  
IBM Integration Bus supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments. But also IIB now provides an extremely lightweight integration runtime with first class support for modern protocols such as REST and is well aligned with cloud native deployment needs.  
The runtime can now be stopped and started in seconds. It runs in docker containers, and can make building and deploying stateless integration logic following any cloud native application development pattern. It offers great capabilities to develop REST api, integrate with backend, event streaming, and SOA services.  

Here is a brief introduction video to IIB:  

[![Brief introduction to IBM Integration Bus](https://img.youtube.com/vi/qQvT4kJoPTM/0.jpg)](https://www.youtube.com/watch?v=qQvT4kJoPTM)


# Server Installations
We can run IIB directly on bare-metal or virtual machine servers, or as docker container on public or private cloud. In our environment we have one dedicated VM to run IIB. It is not set to be high available, as we do not need to proof that IIB can be HA. We want to focus basic functional requirements and address other non-functional requirements that make more sense in an hybrid solution like CI/CD and service management.

## Virtual Machine deployment
For the VM deployment, we used a standard installation following the instructions from the [product documentation](https://www.ibm.com/support/knowledgecenter/en/SSMKHH_10.0.0/com.ibm.etools.mft.doc/bh25992_.htm).

We created a new virtual machine with one of the supported linux OS.
1. Download the developer edition:    
```
   wget http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/10.0.0.9-IIB-LINUX64-DEVELOPER.tar.gz
```

1. Install the downloaded file into /opt/ibm:
```
   mkdir /opt/ibm
   tar -xf 10.0.0.9-IIB-LINUX64-DEVELOPER.tar.gz --exclude iib-10.0.0.9/tools --directory /opt/ibm
```
1. Review the license agreement and if acceptable accept using the following
command:
```
   /opt/ibm/iib-10.0.0.9/iib make registry global accept license silently     
```
1. Add a user and be sure it is part of the admin/root group, it is a sudoers and added to the group mqbrkrs.

To start the IIB toolkit you can use the `<install_dir>/iib toolkit` command. (e.g. `/opt/ibm/iib/ibb-10.0.09/iib toolkit`)

## Docker
For docker read this note: [Building a docker image that include IBM Integration Bus and IBM MQ embedded using the Developer Editions](docker/README.md)

## IBM Cloud Private
The deployment of IIB on ICP may follow two paths we are discussing them in a separate [note](docs/icp/README.md)

# Inventory Flow
This section addresses how the SOAP to REST mediation flow was created. We develop a REST API using IBM Integration Toolkit ([See product documentation](https://www.ibm.com/support/knowledgecenter/en/SSMKHH_10.0.0/com.ibm.etools.mft.doc/bi12036_.htm) and this [developer article](https://developer.ibm.com/integration/docs/ibm-integration-bus/get-started-developing-an-integration-solution-overview/)) following the steps below:
## 1- Select the implementation style
We start by using a REST api, so focusing on the consumer contract and using RESTful web services, and then using flows we will integrate with existing SOAP web services.
1. Decide on reusable content that will be part of Library. We like reuse. Payload definition like item, inventory, supplier object may be reusable.
1. Create a REST API application using the Integration toolkit product.
1. Define the resources and operations that will be exposed by the API using a swagger file. (See file in integration/InventoryRESapi/inventory-api_1.0.0.yaml)
1. Define the data model (e.g. item and items objects were defined in the swagger file too).
1. Import the WSDL to consumer using the Web Services Explorer and save the wsdl into your project / workbench.
1. For each operation create a subflow: the flow has input and output node,
 * drag and drop SOAP request node and map the node property to the SOAP operation of the WSDL. For example getId is mapped to `itemById` binding operation.
 * Define maps to map REST input to XML input and then XML ouput response to JSON object. (see [this not in knowledge center ](https://www.ibm.com/support/knowledgecenter/SSMKHH_10.0.0/com.ibm.etools.mft.doc/sm12030_.htm))

If you want to access the project, open the IIB toolkit and use import > General > Import existing project, then select the `refarch-integration-esb/integration/InventoryRESTapi` project.

In the API Description the base URL is set to **iib-inventory-api** (this is defined in the header section), then for the resources the following operations are defined:
```
* /item/{id} GET, PUT, DELETE
* /items GET, POST
```

As illustrated in the figure below, the `/item/{id}` path get the `id` string as input and return a item object:
![Get items](docs/getitem-resource.png)

The model definition defined `item` and `items` objects as illustrated below:  
![inv-model](docs/inv-model.png)

This definition is very close to what the Data Access Layer SOAP interface is providing, with some adaptation for the future new consumers of the RESTapi.

The service to consume is from the [Data Access Layer]() project, and it is specified via a SOAP WSDL interface, as illustrated in following figure:

![](docs/wsdl.png)

The project needs to do protocol and data mapping, via the implementation of flows. ([See product documentation](https://www.ibm.com/support/knowledgecenter/en/SSMKHH_10.0.0/com.ibm.etools.mft.doc/bi12020_.htm)).  

The flow below presents the `getItems` operation:   

![](docs/get-items-flow.png)

The input string is mapped to the `itemId` of the soap request, the call to the Data Access Layer SOAP service is done inside the `items_ws` node, and the response is mapped back to json item array in the `mapResponse` node.

The `items_ws` node is a map to call the SOAP service via a `Request` node and process the response:

![](docs/items-ws.png)  

The `mapResponse` node is doing the data mapping to `json item` array:

![](docs/map-json.png)

The same logic / implementation pattern is done for the other flows supporting each REST operations. All the flows are defined in the integration/RESTAPI folder.

| Operation | Flow name | Map |
| --------- | -------- | ----- |
| get item  | getId.subflow | getId_mapRequest, getId_mapResponse |
| put item  | putId.subflow | putId_mapRequest, putId_mapResponse |
| delete item  | deleteId.subflow | deleteId_mapRequest, deleteId_mapResponse |
| get items | getItems.subflow | getItems_mapRequest, getItems_mapResponse |
| post items | postItems.subflow | postItems_mapRequest, postItems_mapResponse |

# Deployment
There are three options for IIB application deployment:
1. Deploy manually using Docker
2. Deploy on IBM Cloud Private using Helm
3. Traditional On-Premise using IIB commands

To implement the [lightweight integration](https://developer.ibm.com/integration/blog/2017/03/31/lightweight-integration-iib/)  strategy and development practices we are moving the mediation flow within container embedding IIB runtime.

## Deploy manually using Docker
See the article [Deploying the application using Docker locally](deploy/README.md)

## Deploy to IBM Cloud Private
See the article [Deploying a new instance of IBM Integration Bus on IBM Cloud Private deploying the newly created application](docs/icp/README.md)

## Deploy to traditional on-premise servers
Follow the standard deployment steps document in the [knowledge center](https://www.ibm.com/support/knowledgecenter/en/SSMKHH_10.0.0/com.ibm.etools.mft.doc/af03890_.htm)

# CI/CD

The elements of the IIB project are text files that are pushed to github repository. It is easy to use Jenkins to automate build and deployment. This section presents what can be done.

## Prerequisite
As a prerequisite, IBM Integration Bus needs to be installed on the Jenkins machine. See instructions
in [main readme](https://github.com/ibm-cloud-architecture/refarch-integration-esb#virtual-machine-deployment)  

The steps can be summarized as:
1. Within Jenkins setup an SSH server that hosts the HTTP Server where the package BAR file will be hosted. This requires the *Publish over SSH* plugin to be installed on the Jenkins server.     
   ![](docs/SSHJenkinsSetup.png)

1. Create a new Jenkins Item as a Freestyle project:         
   ![](docs/JenkinsItem.png)

1. In the General section specify:    
   * Discard old builds after 2 days and 2 maximum builds
   * Github project is http//github.com/ibm-cloud-architecture/refarch-integration-esb  
   ![](docs/JenkinsJobPart1.png)

1. In the Source Code Management section specify:
   * Git
   * Repository: http//github.com/ibm-cloud-architecture/refarch-integration-esb       
   ![](docs/JenkinsJobPart2SourceCode.png)    

1. In the build section, select *Execute shell* and enter:     
   ```
       chmod a+x $WORKSPACE/deploy/buildIIB.sh
       $WORKSPACE/deploy/buildIIB.sh
   ```
   ![](docs/JenkinsJobPart3Build.png)

1. In the Post-build Actions section specify:
   * Send build artifacts over SSH
   * Source files: iibApp.bar
   ![](docs/JenkinsJobPart4PostBuildAction.png)


# Application Performance Management

To get visibility into the IIB runtime and server performance metrics, a APM agent is installed on the server.
[The instructions are here](https://www.ibm.com/support/knowledgecenter/SSHLNR_8.1.4/com.ibm.pm.doc/install/iib_linux_aix_config_agent.htm#iib_linux_aix_config_agent)

# Compendium
* [See the global compendium](https://github.com/ibm-cloud-architecture/refarch-integration/blob/master/docs/compendium.md)
* [Developing a REST API service lab](https://developer.ibm.com/integration/docs/ibm-integration-bus/self-study-labs/iib10-lab-2-developing-a-rest-api-service/)
