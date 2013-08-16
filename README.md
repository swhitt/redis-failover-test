redis-failover-test
===================

This setup will start up 3 separate VMs using [Vagrant](http://vagrantup.com/) in order to simulate a 2-server Redis installation and a single-server Apache ZooKeeper installation in order to test the [`redis_failover`](https://github.com/ryanlecompte/redis_failover) gem in a non-trivial configuration. All configuration management of the virutal machines is done using [Chef](http://www.opscode.com/chef/) cookbooks.

How to Start
------------

To download the base box and start/configure the 3 VMs, run `vagrant up` in the root of the project. It may take a while the first time you start it as it has to compile ruby and redis as well as install a few packages.

Once this is finished, you can connect to the different boxes using the `vagrant ssh` command:

    vagrant ssh zookeeper
    vagrant ssh redis_master
    vagrant ssh redis_slave

Or, you can access the machines individually by using the host-only IP addresses given by vagrant (which are completely accessible to the host machine with no firewall):

<table>
  <tr>
    <th>IP</th><th>Machine</th>
  </tr>
  <tr>
    <td><code>192.168.50.10</code></td><td><code>zookeeper</code></td>
  </tr>
  <tr>
    <td><code>192.168.50.20</code></td><td><code>redis_master</code></td>
  </tr>
    <tr>
    <td><code>192.168.50.21</code></td><td><code>redis_slave</code></td>
  </tr>
</table>

If for some reason these IPs do not work for your network configuration you can change them by modifying the `Vagrantfile`'s 'hostonly' and chef 'slave' lines, as well as the `redis_node_manager.yml.erb` file under the `zookeeperbox` chef recipe.

Using `redis_node_manager`
--------------------------
To set up Redis Node Manager (this handles the actual failing-over and provides a view at the console of what's going on in the entire system), `vagrant ssh zookeeper` and run the following from the home directory:

    redis_node_manager -C redis_node_manager.yml

This will check all of the Redis instances in the list provided by the YAML file and periodically poll them to ensure that they are up. If the master goes down, it will promote one of the slaves to master.

Connecting to redis using RedisFailover
---------------------------------------
You can now connect to the `redis_failover` managed farm from your host machine. You can do this by creating an instance of the `RedisFailover::Client` class and specifying the zookeper virtual machine's IP.

```ruby
require 'rubygems'
require 'bundler/setup'

require 'redis-failover'
client = RedisFailover::Client.new(:zkservers => '192.168.50.10:2181')
```
This `client` object is now an instance of `RedisFailover::Client` which has the magical property of having the same interface of the standard `redis-rb`-gem client object. The only difference is that it now automatically switches to communicate directly with the current master Redis instance. 

Resque
------
If you'd like to use Resque with our failover-friendly Redis client, you can set the Redis client that Resque uses like this:

```ruby
failover_client = RedisFailover::Client.new(:zkservers => '192.168.50.10:2181')
Resque.redis = failover_client
```

The `RedisFailover::Client` class has the same interface as the regular `redis` and is completely drop-in compatible. 

Testing Failover
----------------
You can shutdown individual instances of Redis in order to verify that the failover configuration is working. Replace `redis_master` with `redis_slave` in the following example if you'd like to shutdown the slave.

    host$ vagrant ssh redis_master
    ...
    ...
    vagrant@lucid32:~$ sudo initctl stop redis
    redis stop/waiting
    vagrant@lucid32:~$ 

You can bring the instance up with `sudo initctl start redis`.

