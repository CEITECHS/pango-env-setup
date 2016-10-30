#!/bin/bash
###########################################################################################
# name: pango-mongodb-setup.sh
# description: installs  mongo database and then configures the mongo for pango usage
#
############################################################################################
#Environment
environment=preprod

#Initialize the admin Users for MongoDB
pango_admin_users=("pangoRootAdmin" "pangoUserAdmin")

#Initialize the Read Only Users for MongoDB
pango_read_users=("pangoReadUser" "pangoVerifyReadUser")

#Initialize the Read Write Users for MongoDB
pango_rw_users=("pangoWriteUser" "pangoVerifyWriteUser")

#####Password Section for Users in Mongodb ###############

#Initialize the Passwords for admin Users in PREPROD
pango_admin_pwd=("pangoRootAdminPass10" "pangoUserAdminPass10")

#Initialize the Passwords for Read Only Users in MongoDB in PREPROD
pango_read_pwd=("pangoPreprodReadUsrPass10" "pangoPreprodVerifyReadUsrPass10")

#Initialize the Passwords for Read Write Users in MongoDB in PREPROD
pango_rw_pwd=("pangoPreprodWriteUsrPass10" "pangoPreprodVerifyWriteUsrPass10")

# Get the operating system
OPERATING_SYSTEM=`cat /etc/os-release |grep ^ID=| cut -d "=" -f2|sed -e 's/^"//' -e 's/"$//'`

# Main method which installs mongo and then configures the mongo for pango usage
main(){
install_mongo
setup_pango_users
setup_pango_collections
}

install_mongo() {
if [[ $OPERATING_SYSTEM == "unix" ]];
then
	 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	 echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
	 apt-get update
     apt-get install -y mongodb-org
	 service mongod start
elif [[ ${OPERATING_SYSTEM} == "rhel"  || ${OPERATING_SYSTEM} == "amzn" ]];
then
	create_yum_mongo_repo_file
	yum install -y mongodb-org
	service mongod start
	chkconfig mongod on
else
 echo " Unsupported os version: " ${OPERATING_SYSTEM}
fi
}


create_yum_mongo_repo_file(){
    yum_file=/etc/yum.repos.d/mongodb-org-3.0.repo
	echo "[mongodb-org-2.6]" > ${yum_file}
	echo "name=MongoDB 2.6 Repository" >> ${yum_file}
	echo "baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/" >> ${yum_file}
	echo "gpgcheck=0" >> ${yum_file}
	echo "enabled=1" >> ${yum_file}
}



setup_pango_users(){
#Check if Mongo DB node is Primary
`mongo --eval 'db.isMaster().ismaster' | grep true 2>/dev/null`
result=$?

#Run this script only on MongoDB node
if [ $result -eq 0 ]; then
   
    echo "================Creating Admin users in MongoDB========================================================"

     mongo admin --eval 'db.createUser({ user: "'${pango_admin_users[0]}'",  pwd: "'${pango_admin_pwd[0]}'",  roles: [ { role: "root", db: "admin" } , { role: "userAdminAnyDatabase", db: "admin" } ] } );' 2>/dev/null 
	 
     mongo pango --eval 'db.createUser( { user: "'${pango_admin_users[1]}'", pwd: "'${pango_admin_pwd[1]}'", roles: [ { role: "userAdmin", db: "pango" } ] } );' 2>/dev/null
	 
     mongo pango-verification --eval 'db.createUser( { user: "'${pango_admin_users[1]}'", pwd: "'${pango_admin_pwd[1]}'", roles: [ { role: "userAdmin", db: "pango-verification" } ] } );' 2>/dev/null


    echo "================Creating Read Only users in Mongo DB========================================================"
    
    mongo pango --eval 'db.createUser( { user: "'${pango_read_users[0]}'", pwd: "'${pango_read_pwd[0]}'", roles: [{ role: "read", db: "pango" }] } );' 2>/dev/null
	
	 mongo pango-verification --eval 'db.createUser( { user: "'${pango_read_users[1]}'", pwd: "'${pango_read_pwd[1]}'", roles: [{ role: "read", db: "pango-verification" }] } );' 2>/dev/null
  
	echo "==================== Completed Read Only users creation in Mongo DB !!!========================================"

	echo "==================================Creating Read Write users in Mongo DB======================================= "

    mongo pango --eval 'db.createUser( { user: "'${pango_rw_users[0]}'", pwd: "'${pango_rw_pwd[0]}'", roles: [{ role: "readWrite", db: "pango" }] } );' 2>/dev/null
	
	mongo pango-verification --eval 'db.createUser( { user: "'${pango_rw_users[1]}'", pwd: "'${pango_rw_pwd[1]}'", roles: [{ role: "readWrite", db: "pango-verification" }] } );' 2>/dev/null

	echo "================Completed Read Write users creation in Mongo DB=================================================="
else
    echo "This script need to run on Mongo Primary node"
    exit 1      
fi
}

setup_pango_collections(){
	wget https://raw.githubusercontent.com/CEITECHS/pango-env-setup/master/data/propertyunit-data.json
	wget https://raw.githubusercontent.com/CEITECHS/pango-env-setup/master/data/user-data.json
	mongoimport --db pango --collection user --file user-data.json
	mongoimport --db pango --collection propertyunit --file propertyunit-data.json	
	rm user-data.json
	rm propertyunit-data.json
}

# Main starts here ......
main