############################################################
# Dockerfile to build a Nagios/Adagios server
############################################################

# Set the base image to Centos Latest Base
FROM centos:latest

# File Author / Maintainer
MAINTAINER sk8r776

#*************************
#*       Versions        *
#*************************


#**********************************
#* Override Enabled ENV Variables *
#**********************************
ENV APP_NAME home.local
ENV APP_USER admin
ENV APP_PASS P@$$w0rd

#*************************
#*  Update and Pre-Reqs  *
#*************************
RUN rpm -ihv http://opensource.is/repo/ok-release.rpm && \
	yum clean all && \
	yum -y update && \
	rm -fr /var/cache/*


#*************************
#*  Application Install  *
#*************************
# Install Nagios, adagios
RUN yum --enablerepo=ok-testing install -y pnp4nagios mk-livestatus nagios git adagios okconfig nagios-plugins-all.x86_64 postfix wget

#**************************
#*   Add Required Files   *
#**************************
RUN wget https://raw.githubusercontent.com/sk8r776/docker-nagios/master/runconfig.sh -O /tmp/runconfig.sh
ADD wget https://raw.githubusercontent.com/sk8r776/docker-nagios/master/index.html -O /tmp/index.html

# Add HTML Index file for check_http check
RUN mv /tmp/index.html /var/www/html/

# Turn on SSH for SSH Check, only listen on 127.0.0.1
RUN sed -ie 's/#ListenAddress\ 0\.0\.0\.0/ListenAddress\ 127\.0\.0\.1/g' /etc/ssh/sshd_config

# Check all permissions
RUN chown -R nagios /etc/nagios/* && \
	chmod -R 775 /etc/nagios

# Adgios will write to /etc/nagios/adagios, ensure directory exists and nagios.cfg knows about it.
RUN mkdir -p /etc/nagios/adagios && \
pynag config --append cfg_dir=/etc/nagios/adagios

# Status view needs broker modules livestatus and pnp4nagios, so configure nagios.cfg
RUN pynag config --append "broker_module=/usr/lib64/nagios/brokers/npcdmod.o config_file=/etc/pnp4nagios/npcd.cfg" && \
	pynag config --append "broker_module=/usr/lib64/mk-livestatus/livestatus.o /var/spool/nagios/cmd/livestatus" && \
	pynag config --set "process_performance_data=1"

# Add nagios to apache group 
RUN usermod -G apache nagios

#**************************
#*  Config Startup Items  *
#**************************
RUN chmod +x /tmp/runconfig.sh && \
	echo "/tmp/./runconfig.sh" >> ~/.bashrc && \
	echo "service sshd start" >> ~/.bashrc

CMD /bin/bash


#****************************
#* Expose Applicatoin Ports *
#****************************
# Expose ports to other containers only
EXPOSE 80