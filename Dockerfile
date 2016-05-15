#FROM centos:6
FROM jdeathe/centos-ssh
MAINTAINER NILANJAN email: roy.nilanjan@gmail.com

# First time need to update the box with repo
RUN yum update -y

# wget is required to update repo with apache 2.4
RUN yum install wget -y

# Install my favourite editor.
RUN yum install vim-X11.x86_64 vim-common.x86_64 vim-enhanced.x86_64 vim-minimal.x86_64 -y

# Building repo

# For apache Centos -7/RHEL 7
#RUN cd /etc/yum.repos.d/ ; wget https://copr-fe.cloud.fedoraproject.org/coprs/rhscl/httpd24/repo/epel-7/rhscl-httpd24-epel-7.repo

# For PHP below provides from remi or webtatic, although above distro of docker IUS already have updated versions.
#RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm ; rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

# For MySQL
#RUN rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
# Need this repo for apache 2.2.24
RUN rpm -U http://powerstack.org/powerstack-release.rpm
# Building repo ends here


# Installation of the LAMP packages.

# Apache Installation.

#RUN yum --disablerepo="*" --enablerepo="ius" install apr15u.x86_64 apr15u-util.x86_64 -y
RUN yum --enablerepo="base" install apr.x86_64 apr-util.x86_64 -y

# Dependency resolved for apache need to fix.
RUN yum install mailcap redhat-logos-60.0.14-12.el6.centos.noarch -y
#RUN yum --disablerepo="*" --enablerepo="ius" install httpd24u.x86_64 httpd24u-tools.x86_64 -y 
RUN yum --enablerepo="powerstack" install httpd.x86_64  httpd-tools.x86_64 -y

# Allow the htaccess to interpret from apache.
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# PHP Installation
RUN yum  install mod_php70u.x86_64 php70u-common.x86_64 php70u-cli.x86_64 php70u-mysqlnd.x86_64 php70u-pdo.x86_64 php70u-pear.noarch php70u-gd.x86_64 php70u-fpm.x86_64 php70u-mcrypt.x86_64 php70u-mbstring.x86_64 php70u-json.x86_64 php70u-opcache.x86_64 php70u-xml.x86_64 php70u-xmlrpc.x86_64 php70u-bcmath.x86_64 php70u-pgsql.x86_64 php70u-ldap.x86_64 -y

# TAR install
RUN yum install tar -y

# Composer Installation
RUN curl -sS https://getcomposer.org/installer | php

# Create a softlink for Composer & Drush
RUN cd /usr/bin ; ln -s /composer.phar composer

# Hope composer can execution within this period no time-out again
RUN composer --global config process-timeout 2000

# Mysql Server Installation
RUN yum install mysql56u-server.x86_64 -y
# End of Installation of LAMP packages

# git installation & configuration
RUN yum install git -y
# We may add the steps to configure .ssh and global config
# git installation & configuration


# Checkout latest version of Drupal
ADD composer.json /
RUN mkdir -p /opt/drupal

RUN mv /composer.json /opt/drupal
RUN composer update --working-dir=/opt/drupal --prefer-dist --profile

# Checkout a mock branch which consists basic struture of Drupal excluding core.
RUN cd /opt/drupal/docroot ; git init ; git remote add origin https://github.com/nilanjanray/drupal-newsite-1.git ; git fetch origin ; git checkout mock-branch


# Add the soft link for drupal console and drush.
RUN cd /usr/bin ; ln -s /opt/drupal/vendor/drupal/console/bin/drupal drupal ; ln -s /opt/drupal/vendor/drush/drush/drush drush

# Run individual composer for drush & drupal-console as well.
RUN composer update --working-dir=/opt/drupal/vendor/drupal/console --prefer-dist --profile ; composer update --working-dir=/opt/drupal/vendor/drush/drush --prefer-dist --profile
#RUN cd /opt/drupal/docroot ; git clone -b git@github.com:nilanjanray/drupal-newsite-1.git 
RUN cd /var/www/html ; ln -s /opt/drupal/docroot drupal

# Vendor's for Drupal
RUN composer update --working-dir=/opt/drupal/docroot --prefer-dist --profile
# @TODO: We may need to softlink to the docroot of apache, lets see first.

# Drush specific operations.
# Add all the bash scripts of drush to ~/.bashrc & generate ~/.drush.
RUN drush init -y

# Add alias to .drush.
ADD aliases.drushrc.php /
RUN mv /aliases.drushrc.php /root/.drush


# Install the ssh server to run the sshd daemon.
#RUN yum -y install openssh-server
#RUN mkdir /var/run/sshd
#RUN echo 'root:screencast' | chpasswd
#RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile

#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]
