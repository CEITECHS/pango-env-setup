# pango-env-setup
Respository for pango environment setup scripts

### Install mongo and docker

Setps to install mongo and docker on pango ec2 instances:

1) Login to ec2 instance

2) Run the following command to install and setup mongo database  for pango usage
   ( NOTE : this step installs mongo ,creates users and then add some test data )
   
    wget -qO- https://raw.githubusercontent.com/CEITECHS/pango-env-setup/master/scripts/pango-mongodb-setup.sh | sh

3) Run the following command to install docker on the ec2 instance

     wget -qO- https://get.docker.com/ | sh
     sudo service docker  start


