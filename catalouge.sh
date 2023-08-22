#!/bin/bash
DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "Setting up Nodejs Repos"
yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Nodejs"
useradd roboshop
VALIDATE $? "Created User roboshop"
mkdir /app &>> $LOGFILE
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE 
VALIDATE $? "Downoaded the Application code"
cd /app &>> $LOGFILE
unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipped Application code"
cd /app 
npm install &>> $LOGFILE
VALIDATE $? "npm packages installed"


cp catalogue.service etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Created config file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reloaded"
systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enabled on boot"
systemctl start catalogue &>> $LOGFILE
VALIDATE $? "service started"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "repo loaded"

yum install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Package have been instaled"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Schema have been loaded"






