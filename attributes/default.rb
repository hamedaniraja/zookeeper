default['zookeeper']['USER'] = 'zookeeper'
default['zookeeper']['GROUP'] = 'zookeeper'
default['zookeeper']['SERVICE'] = 'zookeeper'
default['zookeeper']['USER_UID'] = 1011
default['zookeeper']['USER_GID'] = 1011
default['zookeeper']['USER_HOME'] = '/home/zookeeper'
default['zookeeper']['USER_SHELL'] = '/bin/bash'

default['zookeeper']['INSTALL_PACKAGE'] = 'zookeeper-3.4.6.tgz'
default['zookeeper']['INSTALL_PATH'] = '/usr/local'
default['zookeeper']['SERVER_ID'] = node['hostname'][-1,1]

xmx = (node['memory']['total'].to_i*0.75/(1024*1024)).round
xms = (node['memory']['total'].to_i*0.50/(1024*1024)).round
default['zookeeper']['JAVA_MEM'] = "-Xms#{xms}g -Xmx#{xmx}g"
