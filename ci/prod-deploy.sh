#! /bin/bash
set -x

docker pull telesoftdevops/devops:telesoft-parkings-app-base
docker pull telesoftdevops/devops:telesoft-parkings-app-prod

echo "Remove app-1 from LB-Pool"
sed -e '/server 127.0.0.1:8071/ s/^#*/#/' -i /etc/nginx/sites-enabled/parkings.conf
nginx -s reload
docker stop $1
docker rm $1
docker run -it -d --restart=always --name $1 -p 8071:80 -p 9834:22 -v psad_nas:/opt/parkings/storage -e APP_VERSION=`curl "http:/146.177.0.220:8088/deployments/amount/psad_backend/master"` telesoftdevops/devops:telesoft-parkings-app-prod
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
echo "Add back app-1 to the pool"
sed -i 's/#    server 127.0.0.1:8071;/    server 127.0.0.1:8071;/g' /etc/nginx/sites-enabled/parkings.conf
nginx -s reload
sleep 5
echo "Remove app-2 from LB Pool"
sed -e '/server 127.0.0.1:8072/ s/^#*/#/' -i /etc/nginx/sites-enabled/parkings.conf
nginx -s reload
docker stop $2
docker rm $2
docker run -it -d --restart=always --name $2 -p 8072:80 -p 9835:22 -v psad_nas:/opt/parkings/storage -e APP_VERSION=`curl "http:/146.177.0.220:8088/deployments/amount/psad_backend/master"` telesoftdevops/devops:telesoft-parkings-app-prod
check_2=$(docker logs $2 | grep Compiled | cut -f1 -d " ")
until [ "$check_2" = "Compiled" ]
do
    check_1=$(docker ps | grep $2 | grep Paused | wc -l)
    until [[ $check_1 = 0 ]]
    do 
        echo "Container ($2) is Paused, restarting it ..."
        docker unpause $2
        check_1=$(docker ps | grep $2 | grep Paused | wc -l)
        sleep 10
    done
    check_2=$(docker logs $2 | grep Compiled | cut -f1 -d " ")
    echo "Still deploying ..."
    sleep 10
done
echo "Add back app-2 to pool"
sed -i 's/#    server 127.0.0.1:8072;/    server 127.0.0.1:8072;/g' /etc/nginx/sites-enabled/parkings.conf
nginx -s reload
docker container ls -a | grep parkings-app-prod