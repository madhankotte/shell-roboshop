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

# Check if mongodb.repo exists
if [ ! -f mongodb.repo ]; then
    echo -e "${R}Error: mongodb.repo file not found in the current directory!${N}"
    exit 1
fi

# Setup MongoDB
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding MongoDB repo file"

dnf install mongodb-org -y >>$LOGS_FILE 2>&1
VALIDATE $? "Installing MongoDB"

systemctl enable mongod >>$LOGS_FILE 2>&1
VALIDATE $? "Enabling MongoDB service"

systemctl start mongod >>$LOGS_FILE 2>&1    
VALIDATE $? "Starting MongoDB service"
