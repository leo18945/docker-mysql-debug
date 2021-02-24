#!/bin/bash
/work/mysql/bin/mysqld --defaults-file=/etc/my.cnf --initialize --user=mysql && \
/work/mysql/support-files/mysql.server start --debug --console && \
bash
