# pango-env-setup
Respository for pango environment setup scripts

### Install mongo and docker

Steps to install mongo and docker on pango ec2 instances:

1) Login to ec2 instance

2) Run the following command to install and setup mongo database  for pango usage
   ( NOTE : this step installs mongo ,creates users and then add some test data )
   
    wget -qO- https://raw.githubusercontent.com/CEITECHS/pango-env-setup/master/scripts/pango-mongodb-setup.sh |sudo sh

3) Run the following command to install docker on the ec2 instance

     wget -qO- https://get.docker.com/ |sudo sh
     sudo service docker  start
     
Running Services in QA: 

sudo docker run -d -p 8888:8888 -e spring.cloud.config.server.git.uri=https://github.com/CEITECHS/pango-configs -e spring.cloud.config.server.git.searchPaths={profile} --name config-server iamiddy/pango-config-server 

sudo docker run -d  -p 8090:8090 -e spring.cloud.config.uri=http://<<EC2_HOSTNAME>>:8888 -e spring.profiles.active=qa -e pango.domain.service.db.host.name=<<EC2_HOSTNAME>>:27017 --name pago-api-server  iamiddy/pango-service-apis




