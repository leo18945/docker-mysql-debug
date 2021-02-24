FROM docker.io/bitnami/minideb:buster

WORKDIR /work

COPY ./sources.list /etc/apt/sources.list
RUN apt-get update --allow-unauthenticated --allow-insecure-repositories
RUN apt-get install -y --assume-yes libncurses5-dev libncursesw5-dev openssl libssl-dev libatomic1 gdb procps wget
RUN apt-get install -y --assume-yes build-essential cmake bison pkg-config

RUN wget https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-5.7.29.tar.gz
RUN tar -zxf mysql-boost-5.7.29.tar.gz

WORKDIR /work/mysql-5.7.29

RUN cmake \
-DCMAKE_INSTALL_PREFIX=/work/mysql \
-DMYSQL_DATADIR=/work/mysql/data \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_unicode_ci \
-DEXTRA_CHARSETS=all \
-DENABLED_LOCAL_INFILE=1 \
-DDOWNLOAD_BOOST=0 \
-DWITH_BOOST=/work/mysql-5.7.29/boost/boost_1_59_0 \
-DWITH_DEBUG=1 \
-DWITH_EMBEDDED_SERVER=0 \
-DWITH_EMBEDDED_SHARED_LIBRARY=0
# https://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html
# https://dev.mysql.com/doc/internals/en/miscellaneous-options.html
# https://dev.mysql.com/doc/refman/5.6/en/mysql-install-db.html

RUN make && make install
RUN rm -rf /work/mysql/mysql-test


FROM docker.io/bitnami/minideb:buster
LABEL maintainer "leo18945 <leo18945@qq.com>"

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

WORKDIR /work
ARG MYSQL_HOME=/work/mysql

COPY ./sources.list /etc/apt/sources.list
COPY --from=0 ${MYSQL_HOME} ${MYSQL_HOME}
COPY --from=0 /work/mysql-boost-5.7.29.tar.gz .
COPY ./my.cnf /etc/my.cnf
COPY ./docker-entrypoint.sh .
COPY ./bcview ./innblock ./

# Install required system packages and dependencies
RUN apt-get update --allow-unauthenticated --allow-insecure-repositories && \
apt-get install -y --assume-yes libncurses5-dev libncursesw5-dev openssl libssl-dev libatomic1 gdb procps && \
rm -rf /var/lib/apt/lists/* && \
tar -zxf mysql-boost-5.7.29.tar.gz && \
rm -rf mysql-boost-5.7.29.tar.gz && \
groupadd mysql && \
useradd -s /sbin/nologin -M -g mysql mysql && \
bash -c 'mkdir -p /work/mysql/{tmp,log}' && \
chown -R mysql:mysql /work/mysql && \
echo 'alias ll="ls -laFh"' >> /etc/bash.bashrc && \
echo 'alias lls="ll -S"' >> /etc/bash.bashrc && \
echo 'alias envs="env -0 | sort -z | tr '\0' '\n'"' >> /etc/bash.bashrc

ENV BITNAMI_IMAGE_VERSION="mysql-version: 5.7.29" \
    PATH="${MYSQL_HOME}/bin:/work:$PATH" \
    BASH_ALIAS="/etc/bash.bashrc; alias ll='ls -laFh'; alias lls='ll -S'" \
    MYSQL_HOME="${MYSQL_HOME}" \
    MYSQL_DATA_DIR="${MYSQL_HOME}/data" \
    MYSQL_CONF_DIR="/etc/my.cnf" \
    MYSQL_GREP_ROOT_PASSWORD="grep 'temporary password' /work/mysql/log/mysqld.log" \
    MYSQL_START_CLIENT="mysql -u root -p" \
    MYSQL_CHANGE_PASSWORD="alter user 'root'@'localhost' identified by 'pass';" \
    GDB_BREAKPOINT="gdb breakpoint handle_query do_select do_command JOIN::exec JOIN::get_end_select_func st_select_lex_unit::execute st_select_lex_unit::set_limit st_select_lex_unit::cleanup st_select_lex_unit::first_select Materialized_cursor::send_result_set_metadata JOIN::make_join_plan Optimize_table_order::choose_table_order Optimize_table_order::greedy_search" \
    GDB_COMMAND="gdb -p <mysqld-pid> -ex 'p dict_sys->row_id=281474976710656' -batch" \
    GDB_LOAD_BREAKPOINT="source /work/mysql-breakpoints.txt" \
    INNBLOCK_COMMAND="innblock table.ibd scan 16" \
    BCVIEW_COMMAND="bcview table.ibd 16 94 200" \
    MYSQL_PAGE_COPY_COMMAND="dd if=table.ibd of=new.hex skip=4 bs=16k count=1"

EXPOSE 3306

USER 1001
ENTRYPOINT [ "/work/docker-entrypoint.sh" ]

