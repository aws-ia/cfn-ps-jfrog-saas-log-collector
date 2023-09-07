#!/bin/bash

errorJfrog() {
    echo
    echo -e "\033[31m** ERROR: $1\033[0m"
    echo
    exit 1
}

checkRoot() {
    curUser=
    if [ -x "/usr/xpg4/bin/id" ]
    then
        curUser=$(/usr/xpg4/bin/id -nu)
    else
        curUser=$(id -nu)
    fi
    if [ "$curUser" != "root" ]
    then
        errorJfrog "Only root user can install service"
    fi

    if [ "$0" = "." ] || [ "$0" = "source" ]; then
        errorJfrog "Cannot execute script with source $0"
    fi
}

createJfrogGroup() {
    [ "jfrog" == "" ] && return 0;
    echo -n "Creating Group jfrog..."
    groupName=$(getent group jfrog | awk -F: '{print $1}')
    if [ "$groupName" = "jfrog" ]; then
        echo -n "already exists..."
    else
        echo -n "creating..."
        groupadd jfrog
        if [ ! $? ]; then
            errorJfrog "Could not create Group jfrog"
        fi
    fi
    echo " DONE"
}

createJfrogUser() {
    echo -n "Creating user jfrog..."
    userName=$(getent passwd jfrog | awk -F: '{print $1}')
    if [ "$userName" = "jfrog" ]; then
        echo -n "already exists..."
    else
        echo -n "creating..."
        useradd -r -d "/home/jfrog" -g "jfrog" -M -s /usr/sbin/nologin jfrog
        if [ ! $? ]; then
            errorJfrog "Could not create user jfrog"
        fi
    fi
    echo " DONE"
}

setPermissions() {
    echo
    echo "Setting file permissions..."
    chown -RL jfrog:jfrog /opt/jfrog/jfrog_saas_log_collector || errorJfrog "Could not set permissions"
}

checkRoot
createJfrogGroup
createJfrogUser
setPermissions

cp /opt/jfrog/jfrog_saas_log_collector/saas-log-collector.service /lib/systemd/system/
cp /opt/jfrog/jfrog_saas_log_collector/saas-log-collector-fluentd.service /lib/systemd/system/
chmod a+x /lib/systemd/system/saas-log-collector.service
chmod a+x /lib/systemd/system/saas-log-collector-fluentd.service

echo -n "Initializing service with systemctl..."
systemctl daemon-reload &>/dev/null
systemctl enable saas-log-collector &>/dev/null
systemctl enable saas-log-collector-fluentd &>/dev/null
systemctl list-unit-files --type=service | grep saas-log-collector.service &>/dev/null || errorJfrog "Could not install service"
systemctl list-unit-files --type=service | grep saas-log-collector-fluentd.service &>/dev/null || errorJfrog "Could not install service"
systemctl start saas-log-collector
systemctl start saas-log-collector-fluentd
echo -e " DONE"