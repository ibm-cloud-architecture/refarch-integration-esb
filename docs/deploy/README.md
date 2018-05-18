# Deploying IIB Application using Docker locally

This article documents how to build a deployable BAR file for the Integration
application which will run in IIB, as a container locally.

## Prerequisite
As a prerequisite, IBM Integration Bus needs to be installed on the machine. See instructions
in [main readme](https://github.com/ibm-cloud-architecture/refarch-integration-esb#on-premise)  
* It is assumed that you have already cloned the git repository


## Building the IBM Integration Bus Application

1. Run the mqsiprofile command to setup the environment:
```
   . /opt/ibm/iib-10.0.0.9/server/bin/mqsiprofile
```
1. Run the following command to generate the BAR file:
```
   mqsipackagebar -a iibApp.bar -w /iibmqDocker/refarch-integration-esb/integration -k RESTAPI
```
1. Upload the BAR file to an HTTP Server (9.19.34.xxx in command below) so it can be available to the docker engine during start-up. Use whatever mechanism you like to upload the file to the HTTP server, I used scp:     
```
   scp iibApp.bar callumj@9.19.34.xxx:/storage/CASE/refarch-privatecloud   
```

## Run the application locally

1. Run the following command to run the docker container referencing the HTTP server end point for the bar:
```
  docker run -d --name iibrest2soap -h iibrest2soap -e LICENSE=accept -e MQ_QMGR_NAME=IIBQM -p 1414:1414 -p 9443:9443 -v mqdata:/var/mqm -e IIB_LICENSE=accept -e NODENAME=iibrest2soap -e SVRNAME=default -e IIB_APP_LOCATION=http://9.19.34.xxx/storage/CASE/refarch-privatecloud/iibApp.bar -p 4414:4414 -p 7080:7080 iib10009
```   

1. To verify that the API is working run the following on the local machine on a browser: http://localhost:7080/iib-inventory-api/items
