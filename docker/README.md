# Build docker image for IIB

The project includes two directories under docker folder:
* mq - provides a Dockerfile for building an MQ image suitable for IIB internal usage.
* iib - provides a Dockerfile for building an IIB image using the above mq image as a base but add IIB

This instructions were created by using a base Ubuntu 14.04, with docker already installed. This work is based on the following article: [IBM Integration Bus and Docker: Tips and Tricks](https://developer.ibm.com/integration/blog/2017/04/04/ibm-integration-bus-docker-tips-tricks/) and the base iib github project [IIB docker](https://github.com/ot4i/iib-docker).

## Creating the MQ base and IIB docker images
We assume this project was clone via git clone or the script [clonePeers.sh](https://github.com/ibm-cloud-architecture/refarch-integration/blob/master/clonePeers.sh)
The docker folder includes a clone of the iib-docker github repository under the docker/iib/10.0.0.10.
The goals of this set of build is to build an image with IBM MQ and Integration Bus in the same container. The docker install specific scripts to manage the products. It is using the developer image of the products, if you wish to run their own licensed editions may wish to source the images from a local repository,

1. Run Docker build command to create the docker image named `mqbas:904` using the local dockerfile definition in the mq folder. This download the mq product and configure it. It adds also some important tools like curl.

 ```
 cd refarch-integration-esb/docker/mq/
 docker build -t mqbase:904 .
 docker images

REPOSITORY                                      TAG                 IMAGE ID            CREATED             SIZE
mqbase                                          904              1a21da1592c2        2 minutes ago          868MB
 ```



1. Run the Docker build command to create the `iib:100010` docker runtime image locally:
 ```
 cd refarch-integration-esb/docker/iib/10.0.0.10/runtime
 docker build -t iib:100010 .
 docker images


 ```
 When needed you can start the runtime image execute the command:
 ```
 docker run –name devNode -e LICENSE=accept -e QMGRNAME=QMGR1 -p 1414:1414 -v mqdata:/var/mqm -e NODENAME=NODE1 -e SVRNAME=server1 -p 4414:4414 -p 7800:7800 -v iibdata:/var/mqsi iib:100010
 ```
It is very important to use docker volume to persist the state of the MQ queue manager data directory and potentially for the Integration node as well. The host folder `mqdata` is mapped to the container /var/mqm directory used by the queue manager. The integration node is NODE1 and the host folder `iibdata` is map to the /var/mqsi volume.

Once started you can execute administrative task using commands like:
```
 docker exec -ti devNode /bin/bash -c dspmq

 docker exec -ti devNode /bin/bash -c mqsilist
```


 1. Run the last Docker build to include the IIB toolkit.
 As there is not IIB toolkit in the runtime docker image, we add it in a separate image leveraging the incremental layers supported by docker. So from the IIB runtime image the docker in the `toolkit` folder adds the development IDE. It is possible to run the Integration Toolkit in Docker, with or without a full GUI.
 ```
 cd ../toolkit
 docker build -t iibtk:100010 .
 docker images

 ```

## Start the container for developing integration application

```
docker run –-name devNode -e LICENSE=accept -e QMGRNAME=QMGR1 -p 1414:1414 -v mqdata:/var/mqm -e NODENAME=NODE1 -e SVRNAME=server1 -p 4414:4414 -p 5901:5901 -p 7800:7800 -v iibdata:/var/mqsi iibtk:100010
```
