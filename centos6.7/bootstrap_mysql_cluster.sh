#!/usr/bin/env bash
# $1 is role for this server, monitor or agent

HN=$(hostname)
monitor=(c6703)
agent=(c6701 c6702)
agent_ip=(192.168.67.101 192.168.67.102)
# the virtual ip for mysql server
mysql_server_ip=192.168.67.254
master=(c6701 c6702)
# hive meta server host
hive_meta='c6705,c6706,192.168.67.1'
monitor_user='mmm_monitor'
monitor_passwd='b2fj8710A0Ip0$'
agent_user='mmm_agent'
agent_passwd='fj827F091syT*'
replication_user='replication'
replication_passwd='2Opf12fjlkf@'
hive_meta_user='hive_meta'
hive_meta_db='hive_meta'
hive_meta_passwd='n8Mt41#opA*'
mysql_root_passwd='jJ8f$38*iu'


array_has() {
  A=$1
  K=$2
  echo ${A[@]}
  for i in ${A[@]};do
   if [ "$i" == "$K" ];then
     echo $i, $k
     return 1
   fi
  done
}

for i in ${monitor[@]};do
if [ "$i" == "$HN" ];then
  is_monitor=1
fi
done
for i in ${agent[@]};do
if [ "$i" == "$HN" ];then
  is_agent=1
fi
done
for i in ${master[@]};do
  if [ "$i" == "$HN" ];then
    is_master=1
  fi
  if [ "$i" != "$HN" ];then
    replica_master=$i
  fi
done

echo -n "is_monitor="
echo $is_monitor
echo -n "is_agent="
echo $is_agent
echo -n "is_master="
echo $is_master

# install essential packages
yum -y install vim
rpm -U https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm


if [ "$is_agent" == "1" ]; then
yum -y install mysql-server mysql-client
mkdir /var/log/mysql
chown mysql:mysql /var/log/mysql
cat > /etc/my.cnf <<EOF
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
symbolic-links=0
server_id=1
binlog_format="row"
log_bin=/var/log/mysql/mysql-bin.log
log_bin_index=/var/log/mysql/mysql-bin.log.index
relay_log=/var/log/mysql/mysql-relay-bin.log
relay_log_index=/var/log/mysql/mysql-relay-bin.index
expire_logs_days=10
max_binlog_size=100M
log_slave_updates=1
auto_increment_increment=2
auto_increment_offset=1
bind-address=0.0.0.0
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
sed -i 's/^server_id=1/server_id='${HN:4:1}'/' /etc/my.cnf
service mysqld start
mysqladmin --verbose -u root password $mysql_root_passwd
mysqladmin --verbose -u root -h $HN password $mysql_root_passwd
cat > /tmp/mysql_setup.sql <<EOF
GRANT REPLICATION CLIENT                                   ON *.* TO '$monitor_user'@'${monitor[0]}' IDENTIFIED BY '$monitor_passwd';
GRANT SUPER, REPLICATION CLIENT, PROCESS                   ON *.* TO '$agent_user'@'$replica_master'   IDENTIFIED BY '$agent_passwd';
GRANT REPLICATION SLAVE                                    ON *.* TO '$replication_user'@'$replica_master' IDENTIFIED BY '$replication_passwd';
GRANT INSERT, DELETE, UPDATE, SELECT, ALTER, CREATE, DROP  ON $hive_meta_db.* TO '$hive_meta_user'@'$hive_meta' IDENTIFIED BY '$hive_meta_passwd';
FLUSH PRIVILEGES;
EOF
mysql --verbose --user=root --password=$mysql_root_passwd --verbose < /tmp/mysql_setup.sql
fi

if [ "$is_master" == "1" ]; then
cat > /tmp/mysql_setup.sql <<EOF
CHANGE MASTER TO master_host='$replica_master', master_port=3306, master_user='$replication_user', master_password='$replication_passwd', master_log_file='mysql-bin.000001', master_log_pos=0;
START SLAVE;
EOF
mysql --verbose --user=root --password=$mysql_root_passwd --verbose < /tmp/mysql_setup.sql
fi

# install mysql-mmm-monitor
if [ "$is_monitor" == "1" ]; then
yum -y install mysql-mmm-monitor
cat > /etc/mysql-mmm/mmm_common.conf <<EOF
active_master_role      writer
<host default>
        cluster_interface               eth1
        pid_path                        /var/run/mysql-mmm/mmm_agentd.pid
        bin_path                        /usr/libexec/mysql-mmm/
        replication_user                $replication_user
        replication_password            $replication_passwd
        agent_user                      $agent_user
        agent_password                  $agent_passwd
</host>
<host db1>
        ip                              ${agent_ip[0]}
        mode                            master
        peer                            db2
</host>
<host db2>
        ip                              ${agent_ip[1]}
        mode                            master
        peer                            db1
</host>
<role writer>
        hosts                           db1, db2
        ips                             $mysql_server_ip
        mode                            exclusive
</role>
EOF
cat > /etc/mysql-mmm/mmm_mon.conf <<EOF
include mmm_common.conf
<monitor>
        ip                              127.0.0.1
        pid_path                        /var/run/mysql-mmm/mmm_mond.pid
        bin_path                        /usr/libexec/mysql-mmm/
        status_path                     /var/lib/mysql-mmm/mmm_mond.status
        ping_ips                        ${agent_ip[0]}, ${agent_ip[1]}
        auto_set_online                 10
</monitor>
<host default>
        monitor_user                    $monitor_user
        monitor_password                $monitor_passwd
</host>
debug 0
EOF
chmod 640 /etc/mysql-mmm/mmm_mon.conf
chmod 640 /etc/mysql-mmm/mmm_common.conf
chkconfig mysql-mmm-monitor on
service mysql-mmm-monitor start
fi

# install mysql-mmm-agent
if [ "$is_agent" == "1" ]; then
yum -y install mysql-mmm-agent
cat > /etc/mysql-mmm/mmm_common.conf <<EOF
active_master_role      writer
<host default>
        cluster_interface               eth1
        pid_path                        /var/run/mysql-mmm/mmm_agentd.pid
        bin_path                        /usr/libexec/mysql-mmm/
        replication_user                $replication_user
        replication_password            $replication_passwd
        agent_user                      $agent_user
        agent_password                  $agent_passwd
</host>
<host db1>
        ip                              ${agent_ip[0]}
        mode                            master
        peer                            db2
</host>
<host db2>
        ip                              ${agent_ip[1]}
        mode                            master
        peer                            db1
</host>
<role writer>
        hosts                           db1, db2
        ips                             $mysql_server_ip
        mode                            exclusive
</role>
EOF
sed -i 's/^this db1/this db'${HN:4:1}'/' /etc/mysql-mmm/mmm_agent.conf
chmod 640 /etc/mysql-mmm/mmm_agent.conf
chmod 640 /etc/mysql-mmm/mmm_common.conf
chkconfig mysql-mmm-agent on
service mysql-mmm-agent start
fi
