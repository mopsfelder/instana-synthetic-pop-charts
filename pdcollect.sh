#!/bin/bash
# IBM Confidential
# PID 5737-N85, 5900-AG5
# Copyright IBM Corp. 2022
#

CWD=$(dirname $0)
[ "${CWD}" = "." ] && CWD=$(pwd -P)

namespace=${2-default}

usage()
{
    echo "usage: pdcollect.sh -n <namespace>. By default, namespace is 'default'"
}


echo "collecting synthetic pod information and logging files from namespace $namespace" 
TIMESTAMP="$(date +%Y%m%d%H%M)"
LOG_FOLDER="syntheticpop_logs_${TIMESTAMP}"  
mkdir /tmp/${LOG_FOLDER}

cd /tmp/${LOG_FOLDER}
helm list -n $namespace | grep synthetic-pop >> helm_deploy.log 2>&1
for line in $(kubectl get po -n $namespace | grep 'synthetic-pop' | awk {'print$1'}); do
    kubectl describe po $line -n $namespace >> ${line}_describe.log 2>&1
    case $line in
        *"controller"*)
           kubectl exec $line -n $namespace -- printenv | grep -i POP_VER  >> version.log 2>&1
           kubectl cp ${line}:logs ./controller-log -n $namespace >> mountdir.log 2>&1
           ;;
        *"http"*)
           kubectl exec $line -n $namespace -- printenv | grep -i HTTP_ENGINE_VERSION  >> version.log 2>&1
           kubectl cp ${line}:logs ./http-engine-log -n $namespace >> mountdir.log 2>&1
           ;;
        *"javascript"*)
           kubectl exec $line -n $namespace -- printenv | grep -i JAVASCRIPT_ENGINE_VERSION  >> version.log 2>&1
           kubectl cp ${line}:logs ./javascript-engine-log -n $namespace >> mountdir.log 2>&1
           ;;
        *"browserscript"*)
           kubectl exec $line -n $namespace -- printenv | grep -i BROWSERSCRIPT_ENGINE_VERSION  >> version.log 2>&1
           kubectl cp ${line}:logs ./browserscript-engine-log -n $namespace >> mountdir.log 2>&1
           ;;
        *)
          ;;
    esac
done

if [ -d "/tmp/${LOG_FOLDER}" ] && [ -n "$(ls -A "/tmp/${LOG_FOLDER}")" ]; then
    tar -rf /tmp/${LOG_FOLDER}.tar -C /tmp/${LOG_FOLDER} .
    gzip /tmp/${LOG_FOLDER}.tar
    rm -rf /tmp/${LOG_FOLDER}
 
   echo "logging files are packaged successfully, see /tmp/${LOG_FOLDER}.tar.gz"
else
   echo "No logging files. Please check your resources in $namespace namespace"
   exit -1
fi

cd ${CWD}
