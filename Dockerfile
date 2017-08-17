FROM centos:latest
MAINTAINER troll nlapchenko@determine.com
RUN yum install -y mc
RUN yum install -y nano
RUN yum install -y unzip
RUN yum install -y glibc.i686
RUN yum install -y wget
RUN yum install -y openssh-server
RUN /bin/ssh-keygen -A
RUN /bin/sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN /bin/sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN /bin/echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config
RUN /bin/bash -c 'useradd user'
RUN /bin/passwd -d user
RUN /bin/bash -c ' mkdir /home/user/Download'
RUN wget -P /opt http://10.100.1.138/downloads/sel_installer/2_2_0/determine.installer.gtk.linux.x86.zip
RUN /bin/bash -c 'chmod 777 -R /home/user/'
RUN /usr/bin/unzip '/opt/determine.installer.gtk.linux.x86.zip'
RUN yum install -y python-setuptools
RUN /bin/easy_install pip
RUN /bin/pip install supervisor
RUN /usr/bin/echo_supervisord_conf > /etc/supervisord.conf
RUN mkdir /etc/supervisord.d
RUN /bin/echo "[include]" >> /etc/supervisord.conf
RUN /bin/echo "files = /etc/supervisord.d/*.conf" >> /etc/supervisord.conf
RUN /bin/echo -e '\n #!/bin/sh \n\
#\n\
# /etc/rc.d/init.d/supervisord\n\
#\n\
# Supervisor is a client/server system that\n\
# allows its users to monitor and control a\n\
# number of processes on UNIX-like operating\n\
# systems.\n\
#\n\
# chkconfig: - 64 36\n\
# description: Supervisor Server\n\
# processname: supervisord\n\
\n\
# Source init functions\n\
. /etc/rc.d/init.d/functions\n\
\n\
prog="supervisord"\n\

prefix="/usr/"\n\
exec_prefix="${prefix}"\n\
prog_bin="${exec_prefix}/bin/supervisord"\n\
PIDFILE="/var/run/$prog.pid"\n\
\n\
start()\n\
{\n\
       echo -n $"Starting $prog: "\n\
       daemon $prog_bin --pidfile $PIDFILE\n\
       [ -f $PIDFILE ] && success $"$prog startup" || failure $"$prog startup"\n\
       echo\n\
}\n\

stop()\n\
{\n\
       echo -n $"Shutting down $prog: "\n\
       [ -f $PIDFILE ] && killproc $prog || success $"$prog shutdown"\n\
       echo\n\
}\n\

case "$1" in\n\

 start)\n\
   start\n\
 ;;\n\

 stop)\n\
   stop\n\
 ;;\n\

 status)\n\
       status $prog\n\
 ;;\n\

 restart)\n\
   stop\n\
   start\n\
 ;;\n\

 *)\n\
   echo "Usage: $0 {start|stop|restart|status}"\n\
 ;;\n\

esac\n ' >> /etc/rc.d/init.d/supervisord
RUN /bin/echo -e '[supervisord]\n\
nodaemon=true\n\
loglevel=debug\n\
[program:sshd]\n\
command=/usr/sbin/sshd -D\n\
[program:clm]\n\
command=/Selectica/CLM/config/bin/startSCLM.sh\n\
autorestart=true\n\
user=user' >> /etc/supervisord.d/start.conf
RUN /bin/chmod +x /etc/rc.d/init.d/supervisord
#RUN /sbin/chkconfig --add supervisord
#RUN /sbin/chkconfig supervisord on
#CMD [/bin/supervisord]
EXPOSE 22 8081 
