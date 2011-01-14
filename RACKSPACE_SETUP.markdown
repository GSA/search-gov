# Rackspace setup procedure

These are the steps I took to get the staging, production, and disaster recovery (DR) machines set up and running at Rackspace.

## Initial changes/tweaks to Redhat5.4

Install XML parsing libraries

    sudo yum install -y libxml2 libxml2-devel libxslt libxslt-devel curl-devel

Comment out these lines with visudo, or Capistrano won't work (it has no tty, and it needs to inherit PATH from the parent environment):

    #Defaults    requiretty
    #Defaults    env_reset
    #Defaults    env_keep = "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR \
                            #LS_COLORS MAIL PS1 PS2 QTDIR USERNAME \
                            #LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION \
                            #LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC \
                            #LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS \
                            #_XKB_CHARSET XAUTHORITY"

Add this line at the bottom so Capistrano can run without the password being typed for each machine on each deployment for user 'search':

    search    ALL = NOPASSWD: ALL

## Upgrading MySQL to 5.1 using RPM

    rm dd
    su -
    cd /tmp
    wget http://dl.iuscommunity.org/pub/ius/stable/Redhat/5/x86_64/ius-release-1-4.ius.el5.noarch.rpm
    wget http://dl.iuscommunity.org/pub/ius/stable/Redhat/5/x86_64/epel-release-1-1.ius.el5.noarch.rpm
    rpm -Uvh ius-release*.rpm epel-release*.rpm
    /etc/init.d/mysqld stop
    yum shell
      remove mysql mysql-server mysql-devel mysqlclient15 mysqlclient15-devel
      install mysql51 mysql51-server mysql51-devel perl-DBD-MySQL
      transaction solve
      install perl-DBD-MySQL
      transaction solve
      transaction run
    > y
    > y
    >  quit

    /etc/init.d/mysqld start
    mysql_upgrade -t /tmp
    mysqladmin -u root password "usa.gov"
    mysql -u root -pusa.gov
      GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'usa.gov';
      flush privileges;
      exit

Update /etc/my.cnf (use master or a slave as a guide, depending on what you are setting up) to have sensible parameters

Edit ~/.bashrc

    alias db='mysql -u root -pusa.gov'
    alias dbu='mysql -u root -pusa.gov usasearch_production'

Restart mysqld

    sudo /sbin/service mysqld restart

##Git/Ruby/RubyGems/Rails

Install Git and send github key

    sudo yum -y install git-core
    ssh-keygen -t rsa

Add the id_rsa.pub to github account and test that it works:

    ssh git@github.com

Install Ruby 1.8.7

    cd
    mkdir downloads
    cd ~/downloads
    sudo yum -y install readline readline-devel

    wget ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p174.tar.gz
    tar xvfz ruby-1.8.7-p174.tar.gz
    cd ruby-1.8.7-p174
    ./configure
    make
    sudo make install
    ruby -v

Install Rubygems

    cd ..
    wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
    tar xvfz rubygems-1.3.5.tgz
    cd rubygems-1.3.5
    sudo ruby setup.rb
    which gem
    gem -v
    sudo gem sources -a http://gems.github.com
    sudo gem sources -a http://gemcutter.org
    cd
    sudo chown search:search .gemrc

Edit ~search/.gemrc and add this line:

    gem: --no-ri --no-rdoc

Verify everything looks sane

    gem environment

Get rails (could take several minutes)

    sudo gem install rails -v=2.3.4

Compile mysql gem

    sudo gem install mysql

Install some other gems that seem to require manual installation

    sudo gem install hoptoad_notifier rspec rspec-rails capistrano capistrano-ext ruby-debug calais
    sudo gem install cucumber -v=0.6.1
    sudo gem install sunspot --version '=1.1.0'
    sudo gem install sunspot_rails --version '=1.1.0'

Setup usa/usalog helper aliases for ‘search’ user in ~/.bashrc

    alias usa='cd ~/usasearch/current'
    alias usalog='tail -900f ~/usasearch/current/log/production.log'


## Setting up search.usa.gov Rails application

### Staging

Get database dump of usasearch_production and load onto target staging DB

    time mysqldump --defaults-file=/home/xcet_admin/.my.cnf --add-drop-database --databases usasearch_production | gzip > ~/files/prod.sql.gz
    scp ~/files/prod.sql.gz search@173.203.40.160:~

On Rackspace staging server

    gunzip prod.sql.gz
    time dbu < prod.sql

Make sure staging.rb is configured properly and then on local dev workstation run

    cap deploy:setup

Then on staging

    cd /home/jwynne/usasearch/shared/log
    touch production.log

Then on local dev workstation run

    cap deploy


### Production

Get database dump of usasearch_production and load onto target master DB

    time mysqldump -h10.153.8.231  --add-drop-database --databases usasearch_production | gzip > /var/lib/mysql/prod.sql.gz
    scp !$ search@173.203.40.161:~
    gunzip prod.sql.gz
    time dbm < prod.sql

Make sure staging's public key is in authorized_keys file on all deployment target nodes.

On staging server, type

    cap production deploy:setup

On each node, type:

    touch ~/usasearch/shared/log/production.log

Make sure database.yml and sunspot.yml are in place on each node in shared/system

On staging server, type

    cap production deploy

This could take a while the first time it runs, as many gems are installed/built.

## Installing Redis

A Redis instance runs on staging, the production cron machine, and the ROR machine (drweb) in the disaster recovery environment. These instructions show how it got installed as a service on the cron machine.

Get configuration file and init.d file from staging server:

    scp /etc/redis/redis.conf search@cron:/tmp
    scp /etc/init.d/redis-server !$

on cron:

    cd downloads
    curl http://redis.googlecode.com/files/redis-2.0.4.tar.gz | tar xz
    cd redis-2.0.4/
    make
    sudo cp redis-server /usr/local/sbin
    sudo cp redis-cli /usr/local/bin
    sudo mkdir /var/lib/redis /etc/redis
    sudo mv /tmp/redis.conf /etc/redis/redis.conf
    chmod 755 /tmp/redis-server
    sudo mv /tmp/redis-server /etc/init.d
    sudo /sbin/chkconfig --add redis-server
    sudo /sbin/chkconfig --level 345 redis-server on
    sudo /sbin/service redis-server start
    tail /var/log/redis.log

Verify it's working:

    ./redis-cli set mykey somevalue
    ./redis-cli get mykey
    ./redis-cli del mykey
    ./redis-cli get mykey
    ./redis-cli info

## Resque workers

The cron machine should have 5 Resque processes ready to work through the Calais related search work queue.

To see how many are there, run this from cron:

    ps wax | grep resque

To start/stop/restart the workers, do this:

    sudo service resque_workers (start|stop|restart)

## Installing Solr

These instructions assume you've got the search.usa.gov codebase deployed via Capistrano to the machine you're going to install Solr on.

Make sure a recent java 1.6 runtime is installed

    java -version

As user 'search', get the version of Solr you need

    cd ~/downloads
    wget http://apache.opensourceresources.org/lucene/solr/1.4.1/apache-solr-1.4.1.tgz
    tar xvfz apache-solr-1.4.1.tgz
    mv apache-solr-1.4.1/example ~search/solr

Copy these three files (retaining their permissions) from a working solr machine

    /etc/default/jetty
    /etc/rc.d/init.d/jetty
    ~/solr/etc/jetty-logging.xml

Note that /etc/default/jetty probably points at a solr config directory in the deployment directory,
so if you aren't deploying the search.usa.gov app to your solr server via Capistrano,
you will need to copy over the lib/configuration directories from another server.

Start it up

    sudo service jetty start

Ensure it starts on reboot

    sudo chkconfig --level 345 jetty on

Make sure Solr is listening on 8983:

    sudo netstat -tlnp | grep java

Make sure the logs don't have errors

    cd ~/solr/logs
    more *stderrout.log

##Installing Phusion Passenger on Apache

    sudo yum -y install gcc-c++ httpd-devel apr-devel lynx
    sudo gem install passenger
    sudo passenger-install-apache2-module

Follow instructions when editing httpd.conf

    sudo vi /etc/httpd/conf/httpd.conf

Setup HTTP Basic Authentication if you need it:

    sudo htpasswd -c /etc/httpd/passwords demo

For SSL: edit /etc/httpd/conf.d/ssl.conf accordingly

Put these files in place

    SSLCertificateFile /etc/pki/tls/certs/usa.gov.crt
    SSLCertificateKeyFile /etc/pki/tls/private/usagov.key
    SSLCertificateChainFile  /etc/pki/tls/certs/gd_bundle.crt

Make log files readable

    sudo chmod a+rx /var/log/httpd

Restart apache

    sudo service httpd restart

Setup log rotation for apache and rails/passenger in /etc/logrotate.d/{httpd,passenger}
