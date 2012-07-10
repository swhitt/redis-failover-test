# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
  config.vm.box = "lucid32"

  config.vm.define :zookeeper do |zk_config|
    zk_config.vm.network :hostonly, "192.168.50.10"
    zk_config.vm.provision(:chef_solo) { |chef| chef.add_recipe("zookeeperbox") }
  end

  config.vm.define :redis_master do |master_config|
    master_config.vm.network :hostonly, "192.168.50.20"
    master_config.vm.provision(:chef_solo) { |chef| chef.add_recipe("redisbox") }
  end

  config.vm.define :redis_slave do |slave_config|
    slave_config.vm.network :hostonly, "192.168.50.21"
    slave_config.vm.provision(:chef_solo) do |chef| 
      chef.json = {
        :redis => {
          :slave => '192.168.50.20'
        }
      }
      chef.add_recipe("redisbox")
    end
  end

end
