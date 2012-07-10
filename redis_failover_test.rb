#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"

require "redis_failover"
require "resque"
require "pry"

puts "Make sure you've started up redis_node_manager on the zookeeper instance!"

failover_client = RedisFailover::Client.new(:zkservers => '192.168.50.10:2181')
Resque.redis = failover_client

binding.pry
