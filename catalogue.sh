#!/bin/bash

# Exit if any command fails
set -e

# Color codes
R="\033[31m"
G="\033[32m"
B="\033[34m"
Y="\033[33m"
N="\033[0m"

# Log setup
USERID=$(id -u)
LOGS_FOLDER=/var/log/shell-roboshop
SCRIPT_NAME=$(basename $0 .sh)
MONGODB_HOST="mongodb-dev.madhan66.store"
LOGS_FILE="$LOGS_FOLDER/${SCRIPT_NAME}.log"

mkdir -p $LOGS_FOLDER
echo "Starting the script execution at: $(date)" | tee -a $LOGS_FILE

# Check for root privileges
if [ "$USERID" -ne 0 ]; then
    echo -e "${R}Error: Please run this script as root or with sudo privileges.${N}"
    exit 1
fi

# Validation function
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... ${R}FAILURE${N}" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... ${G}SUCCESS${N}" | tee -a $LOGS_FILE
    fi
}

#### NODEJS ####
dnf module disable nodejs -y >>$LOGS_FILE 2>&1
VALIDATE $? "Disabling NodeJS "

dnf module enable nodejs -y >>$LOGS_FILE 2>&1
VALIDATE $? "Enabling NodeJS "

dnf install nodejs -y >>$LOGS_FILE 2>&1
VALIDATE $? "Installing NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding roboshop user"

mkdir /app >>$LOGS_FILE 2>&1
VALIDATE $? "Creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATE $? "Downloading catalogue application"

cd /app >>$LOGS_FILE 2>&1
VALIDATE $? "Changing directory to /app"

unzip /tmp/catalogue.zip >>$LOGS_FILE 2>&1
VALIDATE $? "Extracting catalogue application"

cd catalogue >>$LOGS_FILE 2>&1
VALIDATE $? "Changing directory to /app/catalogue"

npm install >>$LOGS_FILE 2>&1
VALIDATE $? "Installing NodeJS dependencies"

cp catalogue/etc/systemd/system/catalogue.service /etc/systemd/system/catalogue.service.bak >>$LOGS_FILE 2>&1
VALIDATE $? "Backing up existing catalogue service file"
systemctl daemon-reload
systemctl enable catalogue >>$LOGS_FILE 2>&1
VALIDATE $? "Enable catalogue service"

cp mongo.repo /etc/yum.repos.d/mongo.repo >>$LOGS_FILE 2>&1
VALIDATE $? "copying mongo repo file"

dnf install mongodb-mongos -y >>$LOGS_FILE 2>&1
VALIDATE $? "installing mongo client"

mongo --host $MONGODB_HOST </app/catalogue/schema/catalogue.js >>$LOGS_FILE 2>&1
VALIDATE $? "loading catalogue product "

system ctl restart catalogue >>$LOGS_FILE 2>&1
VALIDATE $? "Restarting catalogue service"


# MongoDB client installation