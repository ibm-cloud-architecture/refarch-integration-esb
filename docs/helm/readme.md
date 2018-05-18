# Build IBM Integration Bus Helm Chart suitable for IBM Cloud Private

This article documents the process to combine the provided helm chart for IIB and application for installing to
IBM Cloud Private environment. It has been built based on the docker image
provided [here](../docker/README.md), and therefore you should have completed
these steps.

## Pre-requisites
* As a pre-req to create a new helm chart, you need to install **helm client 2.4.1**, this can be found [here](https://github.com/kubernetes/helm/releases). The instructions assume this has been installed to /opt/helm/linux-amd64/helm
* You need to have a HTTP server for file sharing
* It is assumed that you have already cloned the git repository to the following location: /iibmqDocker

## Building and Installing the Helm Chart into an IBM Cloud Private environment

1. Helm provides the ability to valid the helm chart prior to package and deploy it to a server. Run the following commands:
   ```
   /opt/helm/linux-amd64/helm lint /iibmqDocker/refarch-integration-esb/helm/iib      

      ==> Linting /iibmqDocker/refarch-integration-esb/helm/iib
      [INFO] Chart.yaml: icon is recommended

      1 chart(s) linted, no failures
    ```

1. The Helm chart needs to be packaged for deployment, run the following command:
  ```
   /opt/helm/linux-amd64/helm package /iibmqDocker/refarch-integration-esb/helm/iib
  ```
1. This will generate a file in the current directory called **iib-0.1.2.tgz**, this needs to be uploaded to a HTTP server, so it can be referenced by a Helm repository. Use whatever mechanism you like to upload the file to the HTTP server, we used `scp`:
   ```     
   scp iib-0.1.2.tgz callumj@9.19.34.117:/storage/CASE/refarch-privatecloud
   ```
1. Now that the helm chart is available on a HTTP server, we need to update the helm repository to be aware of the new helm chart. This is completed by updating the index.yaml associated with the helm repository. The helm client provides a utility to simply this process. The first stage is to download the existing index.yaml:
   ```
   wget http://172.16.0.5/storage/CASE/local-charts/index.yaml
   ```
1. This file will then be updated using the helm command:
   ```
   /opt/helm/linux-amd64/helm repo index --merge index.yaml --url http://9.19.34.117/storage/CASE/refarch-privatecloud ./
   ```

   The command should add the following entry into the index.yaml file:      
   ```
   apiVersion: v1
   entries:
     iib:
     - apiVersion: v1
       created: 2017-08-31T06:26:56.056012356-04:00
       description: IBM Integration Bus node with local MQ Queue Manager associated
       digest: bb89fdec4a080c505c6b14760a5983fcfb7315470999fc4799021fbb91611615
       name: iib
       urls:
       - http://9.19.34.117/storage/CASE/refarch-privatecloud/iib-0.1.2.tgz
       version: 0.1.2
   ```

1. The index.yaml file now needs to be uploaded to the Helm repository. Use whatever mechanism you like to upload the file to the Helm repository, I used scp:
   ```
   scp index.yaml callumj@172.16.0.5:/storage/CASE/local-charts
   ```
