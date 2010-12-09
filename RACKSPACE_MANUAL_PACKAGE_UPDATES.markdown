# Rackspace kernel/MySQL/etc update procedure

These are the steps to take in order to upgrade the non-automatically-updating packages without any site downtime.

## Schedule an hour of suspended monitoring in Rackspace
<https://my.rackspace.com/portal/home/index>

## Schedule an hour of suspended monitoring in OpsView

<http://173.203.40.164/status/hostgroup>

## Disaster Recovery (DR)

### Update each of the DR machines
    sudo su -
    yum upgrade --disableexcludes=all

### If everything upgraded cleanly, you can reboot them
    shutdown -r now

### Verify that the new kernel took effect
    uname -a

## Staging

### Update the staging machine
    sudo su -
    yum upgrade --disableexcludes=all

### If everything upgraded cleanly, you can reboot it
    shutdown -r now

### Verify that the new kernel took effect
    uname -a

## Production

### Shunt traffic over to DR
    ssh web1
    sudo service httpd stop
    ssh web2
    sudo service httpd stop

### Verify traffic has started on dr-web (and is getting search results) and has stopped on web1/web2
    rlog

### Update each of the production machines (web1, web2, slave1, slave2, master, CRON)
    sudo su -
    yum upgrade --disableexcludes=all

### If everything upgraded cleanly, you can reboot them. Ideally, run the reboot command on the databases and cron first, so they are available when the app servers come up
    shutdown -r now

### Verify that the new kernel took effect
    uname -a

### Verify traffic has started on web1/web2 and stopped on dr-web
    rlog

### Verify that the slave DB's on slave1/slave2/drmaster all are updating properly
    show slave status\G

### Restart five Resque workers on CRON
    cd /home/jwynne/usasearch/current
    RAILS_ENV=production QUEUE=calais_related_search nohup rake environment resque:work &
