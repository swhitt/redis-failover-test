redis-failover-test
===================

This setup will start up 3 separate VMs using vagrant in order to simulate a 2-server Redis installation and a single-server Apache ZooKeeper installation in order to test the `redis-failover` gem in a non-trivial configuration.

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
    <td>192.168.50.10</td><td>zookeeper</td>
  </tr>
  <tr>
    <td>192.168.50.20</td><td>redis_master</td>
  </tr>
    <tr>
    <td>192.168.50.21</td><td>redis_slave</td>
  </tr>
</table>

Using `redis_node_manager`
--------------------------
To set up Redis Node Manager (this handles the actual failing-over and provides a view at the console of what's going on in the entire system), `vagrant ssh zookeper` and run the following from the home directory:

    redis_node_manager -C redis_node_manager.yml

This will check all of the Redis instances in the list provided by the YAML file and periodically poll them to ensure that they are up. If the master goes down, it will promote one of the slaves to master.

Connecting to redis using RedisFailover
---------------------------------------
```ruby
require 'rubygems'
require 'bundler/setup'

require 'redis-failover'
client = RedisFailover::Client.new(:zkservers => '192.168.50.10:2181')
```
You'll now have a `client` object that has the same interface as a normal `redis`-gem client object that always communicates directly with the current master redis instance. 

If you'd like to use Resque with our failover-friendly Redis client, you can set the Redis client that Resque uses like this:

```ruby
failover_client = RedisFailover::Client.new(:zkservers => '192.168.50.10:2181')
Resque.redis = failover_client
```

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

