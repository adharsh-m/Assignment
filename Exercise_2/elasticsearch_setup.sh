#!/bin/bash

install_docker()
{
    sudo apt-get install -y curl
    curl -fsSL get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $(whoami)
    sudo chmod 666 /var/run/docker.sock
    echo "Docker installation is Completed"
}

check_dependencies()
{
    docker --version
    if [ $? -gt 0 ]
    then
        echo "Docker is not installed! Installing Docker...."
        install_docker
    else
        echo "Docker is already installed! Skipping installation"
    fi
    sudo apt-get install -y jq
}

setup_elasticsearch()
{   
    docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.8.1
    sleep 10
    status=$(curl http://localhost:9200/_cluster/health | jq --raw-output '.status')
    if [ "$status" = "green" ]
    then
        echo "Elasticsearch health Check passed"
    else
        count=1
        while [ $count -lt 6 ]
        do
            status=$(curl http://localhost:9200/_cluster/health | jq --raw-output '.status')
            if [ "$status" = "green" ]
            then
                echo "Elasticsearch health Check passed"
                break
            fi
            sleep 10
            count=`expr $count + 1`
        done
        if [ $count -eq 6 ]
        then
            echo "Elasticsearch health Check failed!"
        fi
    fi
}

check_dependencies
setup_elasticsearch