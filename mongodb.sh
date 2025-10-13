#!/bin/bash

USERID=$(id -u)
R='\e[31m' # Red
G='\e[32m' # Green
B='\e[34m' # Blue
Y='\e[33m' # Yellow
N='\e[0m'  # No Color
LOGS_FOLDER=/var/log/shell-roboshop
SCRIPT_NAME=$(echo $0 | cut  -d'.' -f1).log
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "starting the script execution at: $(date)"

    if [ "$USERID" -ne 0 ]; then
       echo "Error::Please run this script with root or privelege."
       exit 1 # failure is other than 0
    fi
VALIDATE() {  # Functions receivd input through args just shell script args
     if [ $? -ne 0 ]; then
        echo -e "$2 ... $R is failure $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2.... $G is successful $N" | tee -a $LOGS_FILE
    fi
    }
    cp mongodb.repo /etc/yum.repos.d/mongodb.repo
    VALIDATE $? "adding mongodb repo file"

    dnf install -y mongodb-org >>$LOGS_FILE 2>&1
    VALIDATE $? "installing mongodb"

    systemctl enable mongod >>$LOGS_FILE 2>&1
    VALIDATE $? "enabling mongodb"

    systemctl start mongod >>$LOGS_FILE 2>&1    
    VALIDATE $? "starting mongodb"
