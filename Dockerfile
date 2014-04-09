FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Runit
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#TokuMX
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 505A7412 && \
    echo "deb [arch=amd64] http://s3.amazonaws.com/tokumx-debs $(lsb_release -cs) main" > /etc/apt/sources.list.d/tokumx.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tokumx
RUN mkdir -p /data/db

#Configuration
ADD . /docker
RUN ln -sf /docker/etc/mongodb.conf /etc/

#Runit Automatically setup all services in the sv directory
RUN for dir in /docker/sv/*; do echo $dir; chmod +x $dir/run $dir/log/run; ln -s $dir /etc/service/; done

ENV HOME /root
WORKDIR /root
EXPOSE 22
