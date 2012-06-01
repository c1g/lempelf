#!/bin/sh
log_dir=/opt/nginx/logs
yesterday=`date +%Y%m%d`
lastday=`date +%Y%m%d -d '1 month ago'`
/bin/rm ${log_dir}/access.${lastday}.log.gz
/bin/rm ${log_dir}/nginx_error.${lastday}.log.gz

/bin/mv ${log_dir}/access.log ${log_dir}/access.${yesterday}.log
/bin/mv ${log_dir}/nginx_error.log ${log_dir}/nginx_error.${yesterday}.log

kill -USR1 `cat /dev/shm/nginx.pid`
/bin/gzip ${log_dir}/access.${yesterday}.log &
/bin/gzip ${log_dir}/nginx_error.${yesterday}.log &
