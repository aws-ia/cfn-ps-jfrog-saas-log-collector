#!/usr/bin/env bash
source /etc/profile.d/rvm.sh
fluentd -c /opt/jfrog/jfrog_saas_log_collector/fluentd_splunk.conf  2>&1 > /opt/jfrog/jfrog_saas_log_collector/jfrog_saas_log_collector_fluentd.log