#!/usr/bin/env bash
source /etc/profile.d/rvm.sh
jfrog-saas-log-collector -c /opt/jfrog/jfrog_saas_log_collector/config.yaml 2>&1 > /opt/jfrog/jfrog_saas_log_collector/jfrog_saas_log_collector.log