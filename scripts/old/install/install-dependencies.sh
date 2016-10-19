#!/usr/bin/env bash

sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update

sudo apt-get -y install default-jdk
sudo apt-get -y install default-jre
sudo apt-get -y install python-pip
sudo apt-get -y install python-software-properties python g++ make
sudo apt-get -y install nodejs
sudo apt-get -y install npm

cd ~/sw/

wget https://nodejs.org/dist/v6.7.0/node-v6.7.0-linux-x64.tar.xz
tar xf node-v6.7.0-linux-x64.tar.xz
rm node-v6.7.0-linux-x64.tar.xz


sudo pip install flask
sudo pip install SPARQLWRAPPER
