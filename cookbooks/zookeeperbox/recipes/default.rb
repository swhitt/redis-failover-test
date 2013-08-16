require_recipe "rvm::system"
require_recipe "rvm::vagrant"

rvm_gem "redis_failover" do
  ruby_string "ruby-1.9.3-p327"
  action      :install
end

package "openjdk-6-jre-headless" do
  action :install
end

remote_file "#{Chef::Config[:file_cache_path]}/zookeeper.tar.gz" do
  source "http://apache.deathculture.net/zookeeper/zookeeper-3.3.5/zookeeper-3.3.5.tar.gz"
  action :create_if_missing
end

bash "open_zookeeper_up" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf zookeeper.tar.gz
    mv zookeeper-3.3.5 /home/vagrant/zookeeper
  EOH
  creates "/home/vagrant/zookeeper"
end

service "zoo" do
  provider Chef::Provider::Service::Upstart
  subscribes :restart, resources(:bash => "open_zookeeper_up")
  supports :restart => true, :start => true, :stop => true
end

template "zoo.cfg" do
  path "/home/vagrant/zookeeper/conf/zoo.cfg" 
  source "zoo.cfg.erb"
  owner "vagrant"
  group "vagrant"
  mode "0644"
end

directory "/tmp/zookeeper" do
  owner "vagrant"
  group "vagrant"
  mode "0755"
  action :create
end

template "redis_node_manager.yml" do
  path "/home/vagrant/redis_node_manager.yml" 
  source "redis_node_manager.yml.erb"
  owner "vagrant"
  group "vagrant"
  mode "0644"
end

template "zoo.upstart.conf" do
  path "/etc/init/zoo.conf"
  source "zoo.upstart.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "zoo")
end

service "zoo" do
  action [:enable, :start]
end
