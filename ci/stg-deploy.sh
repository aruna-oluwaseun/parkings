#! /bin/bash
set -x

docker pull telesoftdevops/devops:telesoft-parkings-app-base
docker pull telesoftdevops/devops:telesoft-parkings-app-stg

if [[ $(docker ps -a | grep $1 | grep 8070 | wc -l)  = 1 ]]
then 
  [[ $(docker stop $1 && docker rm $1) ]]
fi
docker run -it -d --restart=always --name $1 -h $1 -p 8070:80 -p 9833:22 -v psad_nas:/opt/parkings/storage -e APP_VERSION=`curl "http:/172.26.16.220:8088/deployments/amount/psad_backend/stg"` telesoftdevops/devops:telesoft-parkings-app-stg
# wait untill in the container log you will see "Compilied", which means container successfully was deployed
check_2=$(docker logs $1 | grep Compiled | cut -f1 -d " ")
until [ "$check_2" = "Compiled" ]
do
    check_1=$(docker ps | grep $1 | grep Paused | wc -l)
    until [[ $check_1 = 0 ]]
    do 
        echo "Container ($1) is Paused, restarting it ..."
        docker unpause $1
        check_1=$(docker ps | grep $1 | grep Paused | wc -l)
        sleep 10
    done
    check_2=$(docker logs $1 | grep Compiled | cut -f1 -d " ")
    echo "Still deploying ..."
    sleep 10
done
curl_out=$(curl -w "%{http_code}" -s -o /dev/null "https://parkings.telesoftmobile.com/")
if [ "$curl_out" != "302" ]
then
  exit 1
fi