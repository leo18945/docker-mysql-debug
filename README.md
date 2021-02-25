# docker-mysql-debug
从源码编译的mysql服务器，带debug信息，已安装gdb，便于学习和调试mysql功能及源码。

[![automated](https://badgen.net/badge/icon/docker?icon=docker&label)](https://hub.docker.com/r/leo18945/mysql-debug "Go to Docker hub")
![](https://img.shields.io/github/last-commit/leo18945/docker-mysql-debug.svg)
![](https://badgen.net/docker/size/leo18945/mysql-debug/5.7.29)
[![](https://images.microbadger.com/badges/image/leo18945/mysql-debug:5.7.29.svg)](https://microbadger.com/images/leo18945/mysql-debug:5.7.29 "Get your own image badge on microbadger.com")

![](https://img.shields.io/badge/debian-10-green.svg?logo=debian)
![](https://img.shields.io/badge/mysql-5.7.29-green.svg?logo=mysql)
![](https://img.shields.io/badge/mysql-source_code_attached-green.svg?logo=mysql)
![](https://img.shields.io/badge/gdb-8.2.1-green.svg?logo=gdb)

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/leo18945/docker-mysql-debug/master/docker-compose.yml)


#### 启动容器

```shell
> wget https://raw.githubusercontent.com/leo18945/docker-mysql-debug/master/docker-compose.yml

> docker-compose run -u root --name mysql-debug --service-ports mysql-debug
root@1d1e15b4c637:/work#
```

#### 操作系统版本

```shell
root@1d1e15b4c637:/work# cat /etc/*release
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
NAME="Debian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

#### mysql源码版本

```shell
wget https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-5.7.29.tar.gz
```

#### mysql编译参数

```shell
cmake \
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
```

#### 查看mysqld进程

```shell
root@9d80e46284e8:/work# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   3868  3044 pts/0    Ss   12:40   0:00 /bin/bash /work/docker-entrypoint.sh
root        47  0.0  0.0   2388  1484 pts/0    S    12:41   0:00 /bin/sh /work/mysql/bin/mysqld_safe --datadir=/work/mysql/data --pid-file=/work/mysql/data/9d80e46284e8.pid
mysql      297  0.4  4.9 2120556 211104 pts/0  Sl   12:41   0:00 /work/mysql/bin/mysqld --basedir=/work/mysql --datadir=/work/mysql/data --plugin-dir=/work/mysql/lib/plugin --use
root       342  0.0  0.0   3868  3132 pts/0    S    12:41   0:00 bash
root       344  0.0  0.0   7640  2680 pts/0    R+   12:42   0:00 ps aux
```

#### 查看环境变量

```shell
root@9d80e46284e8:/work# envs
BASH_ALIAS=/etc/bash.bashrc; alias ll='ls -laFh'; alias lls='ll -S'
BCVIEW_COMMAND=bcview table.ibd 16 94 200
BITNAMI_IMAGE_VERSION=mysql-version: 5.7.29
GDB_BREAKPOINT=gdb breakpoint handle_query do_select do_command JOIN::exec JOIN::get_end_select_func st_select_lex_unit::execute st_select_lex_unit::set_limit st_select_lex_unit::cleanup st_select_lex_unit::first_select Materialized_cursor::send_result_set_metadata JOIN::make_join_plan Optimize_table_order::choose_table_order Optimize_table_order::greedy_search
GDB_COMMAND=gdb -p <mysqld-pid> -ex 'p dict_sys->row_id=281474976710656' -batch
HOME=/
GDB_LOAD_BREAKPOINT=source /work/mysql-breakpoints.txt
HOSTNAME=9d80e46284e8
INNBLOCK_COMMAND=innblock table.ibd scan 16
MYSQL_CHANGE_PASSWORD=alter user 'root'@'localhost' identified by 'pass';
MYSQL_CONF_DIR=/etc/my.cnf
MYSQL_DATA_DIR=/work/mysql/data
MYSQL_GREP_ROOT_PASSWORD=grep 'temporary password' /work/mysql/log/mysqld.log
MYSQL_HOME=/work/mysql
MYSQL_SOURCE_DIR=/work/mysql-5.7.29
MYSQL_PAGE_COPY_COMMAND=dd if=table.ibd of=new.hex skip=4 bs=16k count=1
MYSQL_START_CLIENT=mysql -u root -p
OS_ARCH=amd64
OS_FLAVOUR=debian-10
OS_NAME=linux
PATH=/work/mysql/bin:/work:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/work
SHLVL=1
TERM=xterm
_=/usr/bin/env
```

#### 查看mysql启动配置文件

```ini
> cat /etc/my.cnf
[mysqld]
# 不解析客户端主机名，这样就只能在mysql的授权表中对客户端IP授权，不能对主机名授权
skip_name_resolve	=	true

bind_address	=	0.0.0.0
port			=	3306

max_allowed_packet	=	16M
explicit_defaults_for_timestamp	=	1

# 1-表名等全转为小写存储，查询等也转为小写对比
lower_case_table_names	=	1

#############################################################
# 设置mysql运行的各级目录
basedir		=	/work/mysql
datadir		=	/work/mysql/data
tmpdir		=	/work/mysql/tmp
pid_file	=	/work/mysql/tmp/mysqld.pid
socket		=	/work/mysql/tmp/mysql.sock

#############################################################
# 数据库默认字符集，utf8mb4符集支持表情符号（表情符号占4个字节）
character_set_server	=	utf8mb4
collation_server		=	utf8mb4_unicode_ci

# 是否允许客户端设置会话的字符集，此处允许
# skip-character-set-client-handshake = off
character-set-client-handshake	=	on
# init_connect	=	'SET NAMES utf8mb4'

#############################################################
# The locale to use for error messages. The default is en_US.
# lc_messages_dir	=	/work/mysql/share
lc_messages			=	en_US

#############################################################
# 开启系统日志
log_error					=	/work/mysql/log/mysqld.log
# 开启查询日志
general_log				=	on
general_log_file	=	/work/mysql/log/general.log

# 开启慢查询日志功能
# slow_query_log			=	on
# slow_query_log_file	=	/work/mysql/log/slow_query.log
# 查询超过多长时间的SQL才会记录到慢查询日志文件(默认时间为10秒)
# long_query_time			=	10
# log_queries_not_using_indexes	= on
#############################################################

# 用来限制LOAD DATA, SELECT ... OUTFILE, and LOAD_FILE()传到哪个指定目录的，或者system ls /可以访问哪个目录
secure_file_priv	=	/

# 设置mysql服务器id，为了在使用binlog功能时区分不同的服务器
server-id	=	1

# 开启binlog，并设置log_bin_index前缀为mysql-bin
log_bin		=	mysql-bin

# 是否信任创建存储过程的创建者，信任他们在创建存储过程时不会修改库中表的数据，否则容易导致主从复制时数据不一致，此处信任
log_bin_trust_function_creators	=	on

[client]
port	=	3306
socket	=	/work/mysql/tmp/mysql.sock
default_character_set	=	utf8mb4

[mysql]
default-character-set	=	utf8mb4

# https://gist.github.com/rhtyd/d59078be4dc88123104e
# https://fromdual.com/mysql-configuration-file-sample
```

#### 查看 mysql root 初始密码

```shell
root@9d80e46284e8:/work# grep 'temporary password' /work/mysql/log/mysqld.log
2021-02-23T12:41:00.778375Z 1 [Note] A temporary password is generated for root@localhost: sfUr7ha2qg,5
```

#### 使用 mysql-cli 客户端构造数据

```mysql
root@9d80e46284e8:/work# mysql -u root -p
Enter password: sfUr7ha2qg,5
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.29-debug

mysql> alter user 'root'@'localhost' identified by 'pass';

mysql> create database test;

mysql> use test;

mysql> create table test1(name varchar(20));

mysql> insert into test1 values('AAA');

mysql> select * from test1;
+------+
| name |
+------+
| AAA  |
+------+

mysql> create table test2(name varchar(20));

mysql> insert into test2 values('BBB');

mysql> select * from test2;
+------+
| name |
+------+
| BBB  |
+------+
```

#### 查看 test1 表字节数据
```mysql
mysql> system bcview /work/mysql/data/test/test1.ibd 16 94 100
current block:00000003--Offset:00094--cnt bytes:100--data is:010002001c696e66696d756d0002000b000073757072656d756d0300000010fff1000000000200000000000507a70000011b0110414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# block:00000003字节码分析如下
      rcd_header row_id       trx_id       ptr_id         name
03 00 000010fff1 000000000200 000000000507 a70000011b0110 414141
mysql> select conv('200', 16, 10);
+---------------------+
| conv('200', 16, 10) |
+---------------------+
| 512                 |
+---------------------+
# 可以看出，rowid从512开始
```

#### 查看 test2 表字节数据
```mysql
mysql> system bcview /work/mysql/data/test/test2.ibd 16 94 100
current block:00000003--Offset:00094--cnt bytes:100--data is:010002001c696e66696d756d0002000b000073757072656d756d0300000010fff100000000020100000000050cac000001200110424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# block:00000003字节码分析如下
      rcd_header row_id       trx_id       ptr_id         name
03 00 000010fff1 000000000201 00000000050c ac000001200110 424242
mysql> select conv('201', 16, 10);
+---------------------+
| conv('201', 16, 10) |
+---------------------+
| 513                 |
+---------------------+
# 可以看出，rowid从513开始
# 多个表共用一个dict_sys.row_id变量值
```

#### 使用 gdb 修改 dict_sys.row_id 的值

```mysql
# 查看使用gdb修改mysql rowid的命令
mysql> system echo $GDB_COMMAND
gdb -p <mysqld-pid> -ex 'p dict_sys->row_id=281474976710656' -batch

# 使用ps查看mysqld的进程ID
mysql> system ps aux | grep 3306
mysql      297  0.1  5.1 2186352 221700 pts/0  Sl   13:07   0:01 /work/mysql/bin/mysqld --basedir=/work/mysql --datadir=/work/mysql/data --plugin-dir=/work/mysql/lib/plugin --user=mysql --log-error=/work/mysql/log/mysqld.log --pid-file=/work/mysql/data/cb76697ed1bf.pid --socket=/work/mysql/tmp/mysql.sock --port=3306
root       371  0.0  0.0   2388   692 pts/0    S+   13:22   0:00 sh -c  ps aux | grep 3306
root       373  0.0  0.0   3084   888 pts/0    S+   13:22   0:00 grep 3306

# 执行gdb命令修改mysql dict_sys->row_id 的值为10000
# 即没主键的表插入数据时从dict_sys->row_id处取值
mysql> system gdb -p 297 -ex 'p dict_sys->row_id=10000' -batch
[New LWP 298]
...
[New LWP 346]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
0x00007f4b561e2819 in __GI___poll (fds=0x556d880cabd0, nfds=2, timeout=-1) at ../sysdeps/unix/sysv/linux/poll.c:29
29	../sysdeps/unix/sysv/linux/poll.c: No such file or directory.
$1 = 10000
[Inferior 1 (process 297) detached]
```

#### 再次向表中插入数据，看 rowid 是否变化

```mysql
# 再向test1表中插入数据，看新的rowid是多少
mysql> insert into test1 values('CCC');
Query OK, 1 row affected (0.00 sec)

mysql> insert into test2 values('DDD');
Query OK, 1 row affected (0.00 sec)

# 读取test1表中page3的字节码分析
mysql> system bcview /work/mysql/data/test/test1.ibd 16 94 100
current block:00000003--Offset:00094--cnt bytes:100--data is:010002001c696e66696d756d0003000b000073757072656d756d0300000010001d000000000200000000000507a70000011b01104141410300000018ffd400000000271000000000050dad00000121011043434300000000000000000000000000000000

# block:00000003字节码分析如下
      rcd_header row_id       trx_id       ptr_id         name
03 00 000010001d 000000000200 000000000507 a70000011b0110 414141
03 00 000018ffd4 000000002710 00000000050d ad000001210110 434343
mysql> select conv('2710', 16, 10);
+----------------------+
| conv('2710', 16, 10) |
+----------------------+
| 10000                |
+----------------------+
# test1 表已使用新的 rowid

mysql> system bcview /work/mysql/data/test/test2.ibd 16 94 100
current block:00000003--Offset:00094--cnt bytes:100--data is:010002001c696e66696d756d0003000b000073757072656d756d0300000010001d00000000020100000000050cac0000012001104242420300000018ffd4000000002711000000000512b000000124011044444400000000000000000000000000000000

# block:00000003字节码分析如下
      rcd_header row_id       trx_id       ptr_id         name
03 00 000010001d 000000000201 00000000050c ac000001200110 424242
03 00 000018ffd4 000000002711 000000000512 b0000001240110 444444
mysql> select conv('2711', 16, 10);
+----------------------+
| conv('2711', 16, 10) |
+----------------------+
| 10001                |
+----------------------+
# test2 表已使用新的 rowid
```



------

#### gdb 调试 mysql

#### 准备数据

```
CREATE TABLE emp (
  empno decimal(4,0) NOT NULL,
  ename varchar(10),
  job varchar(9),
  mgr decimal(4,0),
  hiredate date,
  sal decimal(7,2),
  comm decimal(7,2),
  deptno decimal(2,0)
);

CREATE TABLE dept (
  deptno decimal(2,0),
  dname varchar(14),
  loc varchar(13)
);

INSERT INTO emp VALUES 
('7369','SMITH','CLERK','7902','1980-12-17','800.00',NULL,'20'),
('7499','ALLEN','SALESMAN','7698','1981-02-20','1600.00','300.00','30'),
('7521','WARD','SALESMAN','7698','1981-02-22','1250.00','500.00','30'),
('7566','JONES','MANAGER','7839','1981-04-02','2975.00',NULL,'20'),
('7654','MARTIN','SALESMAN','7698','1981-09-28','1250.00','1400.00','30'),
('7698','BLAKE','MANAGER','7839','1981-05-01','2850.00',NULL,'30'),
('7782','CLARK','MANAGER','7839','1981-06-09','2450.00',NULL,'10'),
('7788','SCOTT','ANALYST','7566','1982-12-09','3000.00',NULL,'20'),
('7839','KING','PRESIDENT',NULL,'1981-11-17','5000.00',NULL,'10'),
('7844','TURNER','SALESMAN','7698','1981-09-08','1500.00','0.00','30'),
('7876','ADAMS','CLERK','7788','1983-01-12','1100.00',NULL,'20'),
('7900','JAMES','CLERK','7698','1981-12-03','950.00',NULL,'30'),
('7902','FORD','ANALYST','7566','1981-12-03','3000.00',NULL,'20'),
('7934','MILLER','CLERK','7782','1982-01-23','1300.00',NULL,'10');

INSERT INTO dept VALUES 
('10','ACCOUNTING','NEW YORK'),
('20','RESEARCH','DALLAS'),
('30','SALES','CHICAGO'),
('40','OPERATIONS','BOSTON');
```

#### 启动 gdb

```shell
# 启动 gdb
root@1d1e15b4c637:/work/mysql# gdb
GNU gdb (Debian 8.2.1-2+b3) 8.2.1

Type "apropos word" to search for commands related to "word".

# attch 进 mysqld 进程
(gdb) attach 1400
Attaching to process 1400
[New LWP 1401]
...
[New LWP 1430]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
0x00007eff45352819 in __GI___poll (fds=0x55582c637fe0, nfds=2, timeout=-1) at ../sysdeps/unix/sysv/linux/poll.c:29
29	../sysdeps/unix/sysv/linux/poll.c: No such file or directory.
```

#### 加载 breakpoint

```shell
(gdb) source /work/mysql-breakpoints.txt
Breakpoint 1 at 0x564cacb3121f: file /work/mysql-5.7.29/sql/sql_select.cc, line 107.
Breakpoint 2 at 0x564caca9be4b: file /work/mysql-5.7.29/sql/sql_executor.cc, line 885.
Breakpoint 3 at 0x564cacadca77: file /work/mysql-5.7.29/sql/sql_parse.cc, line 907.
Breakpoint 4 at 0x564caca99b6b: file /work/mysql-5.7.29/sql/sql_executor.cc, line 106.
Breakpoint 5 at 0x564cacac7045: file /work/mysql-5.7.29/sql/sql_optimizer.cc, line 5021.
Breakpoint 6 at 0x564cacb007bb: file /work/mysql-5.7.29/sql/sql_planner.cc, line 1832.
Breakpoint 7 at 0x564cacb0133b: file /work/mysql-5.7.29/sql/sql_planner.cc, line 2216.
```

#### 查看 breakpoint

```shell
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000564cacb3121f in handle_query(THD*, LEX*, Query_result*, unsigned long long, unsigned long long) at /work/mysql-5.7.29/sql/sql_select.cc:107
2       breakpoint     keep y   0x0000564caca9be4b in do_select(JOIN*) at /work/mysql-5.7.29/sql/sql_executor.cc:885
3       breakpoint     keep y   0x0000564cacadca77 in do_command(THD*) at /work/mysql-5.7.29/sql/sql_parse.cc:907
4       breakpoint     keep y   0x0000564caca99b6b in JOIN::exec() at /work/mysql-5.7.29/sql/sql_executor.cc:106
5       breakpoint     keep y   0x0000564cacac7045 in JOIN::make_join_plan() at /work/mysql-5.7.29/sql/sql_optimizer.cc:5021
6       breakpoint     keep y   0x0000564cacb007bb in Optimize_table_order::choose_table_order() at /work/mysql-5.7.29/sql/sql_planner.cc:1832
7       breakpoint     keep y   0x0000564cacb0133b in Optimize_table_order::greedy_search(unsigned long long) at /work/mysql-5.7.29/sql/sql_planner.cc:2216
```

#### 设置 breakpoint

```shell
(gdb) b handle_query
Breakpoint 1 at 0x564cacb3121f: file /work/mysql-5.7.29/sql/sql_select.cc, line 107.
(gdb) b do_select
Breakpoint 2 at 0x564caca9be4b: file /work/mysql-5.7.29/sql/sql_executor.cc, line 885.
(gdb) b do_command
Breakpoint 3 at 0x564cacadca77: file /work/mysql-5.7.29/sql/sql_parse.cc, line 907.
(gdb) b JOIN::exec
Breakpoint 4 at 0x564caca99b6b: file /work/mysql-5.7.29/sql/sql_executor.cc, line 106.
(gdb) b JOIN::make_join_plan
Breakpoint 5 at 0x564cacac7045: file /work/mysql-5.7.29/sql/sql_optimizer.cc, line 5021.
(gdb) b Optimize_table_order::choose_table_order
Breakpoint 6 at 0x564cacb007bb: file /work/mysql-5.7.29/sql/sql_planner.cc, line 1832.
(gdb) b Optimize_table_order::greedy_search
Breakpoint 7 at 0x564cacb0133b: file /work/mysql-5.7.29/sql/sql_planner.cc, line 2216.
```

#### 保存 breakpoint

```shell
(gdb) save breakpoints /work/mysql-breakpoints.txt
Saved to file '/work/mysql-breakpoints.txt'.
```

#### mysql 客户端发起查询

```mysql
mysql> select a.empno, a.ename, b.dname, a.job, a.mgr, a.hiredate, a.sal, a.comm from emp a join dept b on b.deptno = a.deptno;
# 此处查询挂起，等待gdb执行
```

#### 进入gdb调试

```shell
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 1, handle_query (thd=0x7fac3c000dd0, lex=0x7fac3c0030f0, result=0x7fac3c958248, added_options=0, removed_options=0)
    at /work/mysql-5.7.29/sql/sql_select.cc:107
107	  DBUG_ENTER("handle_query");
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 5, JOIN::make_join_plan (this=0x7fac3c958fe0) at /work/mysql-5.7.29/sql/sql_optimizer.cc:5021
5021	  DBUG_ENTER("JOIN::make_join_plan");
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 6, Optimize_table_order::choose_table_order (this=0x7facb0040f70) at /work/mysql-5.7.29/sql/sql_planner.cc:1832
1832	  DBUG_ENTER("Optimize_table_order::choose_table_order");
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 7, Optimize_table_order::greedy_search (this=0x7facb0040f70, remaining_tables=3) at /work/mysql-5.7.29/sql/sql_planner.cc:2216
2216	  uint      idx= join->const_tables; // index into 'join->best_ref'

# 打印调用栈
(gdb) bt
#0  Optimize_table_order::greedy_search (this=0x7facb0040f70, remaining_tables=3) at /work/mysql-5.7.29/sql/sql_planner.cc:2216
#1  0x0000564cacb00c69 in Optimize_table_order::choose_table_order (this=0x7facb0040f70) at /work/mysql-5.7.29/sql/sql_planner.cc:1910
#2  0x0000564cacac7431 in JOIN::make_join_plan (this=0x7fac3c958fe0) at /work/mysql-5.7.29/sql/sql_optimizer.cc:5091
#3  0x0000564cacabbe29 in JOIN::optimize (this=0x7fac3c958fe0) at /work/mysql-5.7.29/sql/sql_optimizer.cc:375
#4  0x0000564cacb32d70 in st_select_lex::optimize (this=0x7fac3c005be0, thd=0x7fac3c000dd0) at /work/mysql-5.7.29/sql/sql_select.cc:1016
#5  0x0000564cacb314f6 in handle_query (thd=0x7fac3c000dd0, lex=0x7fac3c0030f0, result=0x7fac3c958248, added_options=0, removed_options=0)
    at /work/mysql-5.7.29/sql/sql_select.cc:171
#6  0x0000564cacae791b in execute_sqlcom_select (thd=0x7fac3c000dd0, all_tables=0x7fac3c956bf0) at /work/mysql-5.7.29/sql/sql_parse.cc:5155
#7  0x0000564cacae10f1 in mysql_execute_command (thd=0x7fac3c000dd0, first_level=true) at /work/mysql-5.7.29/sql/sql_parse.cc:2826
#8  0x0000564cacae8829 in mysql_parse (thd=0x7fac3c000dd0, parser_state=0x7facb0042650) at /work/mysql-5.7.29/sql/sql_parse.cc:5584
#9  0x0000564cacade006 in dispatch_command (thd=0x7fac3c000dd0, com_data=0x7facb0042df0, command=COM_QUERY) at /work/mysql-5.7.29/sql/sql_parse.cc:1491
#10 0x0000564cacadcf22 in do_command (thd=0x7fac3c000dd0) at /work/mysql-5.7.29/sql/sql_parse.cc:1032
#11 0x0000564cacc0c241 in handle_connection (arg=0x564caf501a00) at /work/mysql-5.7.29/sql/conn_handler/connection_handler_per_thread.cc:313
#12 0x0000564cad28e598 in pfs_spawn_thread (arg=0x564caf2c4d50) at /work/mysql-5.7.29/storage/perfschema/pfs.cc:2197
#13 0x00007facbd318fa3 in start_thread (arg=<optimized out>) at pthread_create.c:486
#14 0x00007facbcb584cf in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95

# 查看源码
(gdb) list
2211	  @return false if successful, true if error
2212	*/
2213
2214	bool Optimize_table_order::greedy_search(table_map remaining_tables)
2215	{
2216	  uint      idx= join->const_tables; // index into 'join->best_ref'
2217	  uint      best_idx;
2218	  POSITION  best_pos;
2219	  JOIN_TAB  *best_table; // the next plan node to be added to the curr QEP
2220	  DBUG_ENTER("Optimize_table_order::greedy_search");
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 4, JOIN::exec (this=0x7fac3c958fe0) at /work/mysql-5.7.29/sql/sql_executor.cc:106
106	  Opt_trace_context * const trace= &thd->opt_trace;
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 2, do_select (join=0x7fac3c958fe0) at /work/mysql-5.7.29/sql/sql_executor.cc:885
885	  int rc= 0;
(gdb) c
Continuing.

Thread 28 "mysqld" hit Breakpoint 3, do_command (thd=0x7fac3c000dd0) at /work/mysql-5.7.29/sql/sql_parse.cc:907
907	    (thd->get_protocol()->type() == Protocol::PROTOCOL_TEXT ||
(gdb) c
Continuing.
```

#### mysql返回执行结果

```mysql
mysql> select a.empno, a.ename, b.dname, a.job, a.mgr, a.hiredate, a.sal, a.comm from emp a join dept b on b.deptno = a.deptno;
+-------+--------+------------+-----------+------+------------+---------+---------+
| empno | ename  | dname      | job       | mgr  | hiredate   | sal     | comm    |
+-------+--------+------------+-----------+------+------------+---------+---------+
|  7369 | SMITH  | RESEARCH   | CLERK     | 7902 | 1980-12-17 |  800.00 |    NULL |
|  7499 | ALLEN  | SALES      | SALESMAN  | 7698 | 1981-02-20 | 1600.00 |  300.00 |
|  7521 | WARD   | SALES      | SALESMAN  | 7698 | 1981-02-22 | 1250.00 |  500.00 |
|  7566 | JONES  | RESEARCH   | MANAGER   | 7839 | 1981-04-02 | 2975.00 |    NULL |
|  7654 | MARTIN | SALES      | SALESMAN  | 7698 | 1981-09-28 | 1250.00 | 1400.00 |
|  7698 | BLAKE  | SALES      | MANAGER   | 7839 | 1981-05-01 | 2850.00 |    NULL |
|  7782 | CLARK  | ACCOUNTING | MANAGER   | 7839 | 1981-06-09 | 2450.00 |    NULL |
|  7788 | SCOTT  | RESEARCH   | ANALYST   | 7566 | 1982-12-09 | 3000.00 |    NULL |
|  7839 | KING   | ACCOUNTING | PRESIDENT | NULL | 1981-11-17 | 5000.00 |    NULL |
|  7844 | TURNER | SALES      | SALESMAN  | 7698 | 1981-09-08 | 1500.00 |    0.00 |
|  7876 | ADAMS  | RESEARCH   | CLERK     | 7788 | 1983-01-12 | 1100.00 |    NULL |
|  7900 | JAMES  | SALES      | CLERK     | 7698 | 1981-12-03 |  950.00 |    NULL |
|  7902 | FORD   | RESEARCH   | ANALYST   | 7566 | 1981-12-03 | 3000.00 |    NULL |
|  7934 | MILLER | ACCOUNTING | CLERK     | 7782 | 1982-01-23 | 1300.00 |    NULL |
+-------+--------+------------+-----------+------+------------+---------+---------+
14 rows in set (9 min 44.61 sec)
```

## Have fun.

#### mysql 源码学习参考

> Mysql优化器源码  
> https://blog.csdn.net/huoyuanshen/article/details/50420315  
> MySQL确定JOIN表顺序  
> https://zhuanlan.zhihu.com/p/102655586  
