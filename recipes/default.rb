#
# Cookbook:: zookeeper
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# installing java package temporarily
########################################
package 'java-1.8.0-openjdk.x86_64' do
  action :install
end


execute "Set Java home" do
    command <<-EOF
        echo "export JAVA_HOME=/etc/alternatives/jre_openjdk" >> /etc/profile
        export JAVA_HOME=/etc/alternatives/jre_openjdk
    EOF
    only_if { `grep "^export JAVA_HOME=/etc/alternatives/jre_openjdk" /etc/profile` == "" }
end

execute "sourcing /etc/profile" do
    command <<-EOF
        source /etc/profile
    EOF
end

###########################################


# Creating zookeeper group
group node['zookeeper']['GROUP'] do
  gid node['zookeeper']['USER_GID']
end


# Creating zookeeper user
user node['zookeeper']['USER'] do
  comment 'zookeeper service user'
  uid node['zookeeper']['USER_UID']
  gid node['zookeeper']['USER_GID']
  home node['zookeeper']['USER_HOME']
  shell node['zookeeper']['USER_SHELL']
end

directory node['zookeeper']['USER_HOME'] do
  owner node['zookeeper']['USER']
  group node['zookeeper']['GROUP']
  action :create
end


# Copy zookeeper package to root home folder
cookbook_file "/tmp/"+node['zookeeper']['INSTALL_PACKAGE'] do
  source node['zookeeper']['INSTALL_PACKAGE']
  owner 'root'
  group 'root'
  mode '0700'
end


# Removing existing zookeeper
execute 'Removing old zookeeper' do
  user 'root'
  cwd '/root'
  command <<-EOF
       systemctl stop #{node['zookeeper']['SERVICE']}
       rm -rf #{node['zookeeper']['INSTALL_PATH']}/zookeeper*
       rm -rf /etc/systemd/system/zookeeper
       rm -rf /var/zookeeper
  EOF
end

zookeeperFolderName = node['zookeeper']['INSTALL_PACKAGE'].chomp('.tgz')
zookeeperFolderPath = node['zookeeper']['INSTALL_PATH']+"/"+zookeeperFolderName

# Installing zookeeper
execute 'Installing zookeeper' do
  user 'root'
  cwd node['zookeeper']['INSTALL_PATH']
  command <<-EOF
       tar -xvzf /tmp/#{node['zookeeper']['INSTALL_PACKAGE']}
       mv #{zookeeperFolderName} #{node['zookeeper']['INSTALL_PATH']}/
       ln -s #{zookeeperFolderPath} zookeeper
  EOF
end


# Zookeeper main configuration file
cookbook_file zookeeperFolderPath+"/conf/zoo.cfg" do
  source 'zoo.cfg'
end

# Zookeeper jvm config file
template zookeeperFolderPath+"/conf/java.env" do
  source 'java.env.erb'
end

# Zookeeper Env file for changing the log path
cookbook_file zookeeperFolderPath+"/bin/zkEnv.sh" do
  source 'zkEnv.sh'
end

# Zookeeper installation folder permissions
execute 'Setting permissions for Zookeeper installation folder' do
  user 'root'
  cwd node['zookeeper']['INSTALL_PATH']
  command  <<-EOF
    chown -R #{node['zookeeper']['USER']}:#{node['zookeeper']['group']} #{zookeeperFolderPath}
    chown -R #{node['zookeeper']['USER']}:#{node['zookeeper']['group']} /usr/local/zookeeper
  EOF
end

# Zookeeper data folder nad log folder
execute 'Making zookeeper data and log folders' do
  user 'root'
  cwd '/var'
  command  <<-EOF
    mkdir zookeeper
    mkdir zookeeper/data
    mkdir zookeeper/log
    echo "#{node['zookeeper']['SERVER_ID']}" > zookeeper/data/myid
    chown -R #{node['zookeeper']['USER']}:#{node['zookeeper']['group']} /var/zookeeper
  EOF
end



# Zookeeper service file
cookbook_file "/etc/systemd/system/zookeeper.service" do
  source 'zookeeper.service'
  owner 'root'
  group 'root'
  mode '755'
end

# Zookeeper service enabling and starting
execute 'Enabling Zookeeper service' do
  user 'root'
  command <<-EOF
    systemctl daemon-reload
    systemctl start zookeeper
    systemctl enable zookeeper
  EOF
end
