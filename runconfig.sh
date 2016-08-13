#!/bin/bash
sed -ie 's/#ServerName\ www\.example\.com\:80/ServerName\ www\.'$APP_NAME'\:80/g' /etc/httpd/conf/httpd.conf

# Set Adagios Login Password
htpasswd -c -b /etc/nagios/passwd $APP_USER $APP_PASS

# Set Postfix Options
sed -ie 's/#mydomain\ =\ domain\.tld/mydomain\ =\ '$APP_NAME'/g' /etc/postfix/main.cf
echo "service postfix start" >> ~/.bashrc
service postfix start

# Patch the cgi.cfg file and add the new user to have access to the nagios panel
sed -ie 's/authorized_for_system_information=nagiosadmin/authorized_for_system_information=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg
sed -ie 's/authorized_for_configuration_information=nagiosadmin/authorized_for_configuration_information=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg
sed -ie 's/authorized_for_system_commands=nagiosadmin/authorized_for_system_commands=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg
sed -ie 's/authorized_for_all_services=nagiosadmin/authorized_for_all_services=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg
sed -ie 's/authorized_for_all_hosts=nagiosadmin/authorized_for_all_hosts=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg
sed -ie 's/authorized_for_all_service_commands=nagiosadmin/authorized_for_all_service_commands=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg
sed -ie 's/authorized_for_all_host_commands=nagiosadmin/authorized_for_all_host_commands=nagiosadmin,'$APP_USER'/g' /etc/nagios/cgi.cfg

# Start Services
echo "service httpd start" >> ~/.bashrc
echo "service nagios start" >> ~/.bashrc
echo "service npcd start" >> ~/.bashrc
service httpd start
service nagios start
service npcd start

# Remove the runconfig line
sed -ie 's/\/tmp\/\.\/runconfig.sh/#\/tmp\/\.\/runconfig.sh/g' ~/.bashrc