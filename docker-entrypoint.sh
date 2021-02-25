#!/bin/bash
mysqld --defaults-file=/work/my.cnf --initialize --user=mysql && \
mysqld --defaults-file=/work/my.cnf --debug      --user=mysql
