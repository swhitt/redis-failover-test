require "rubygems"
require "bundler/setup"

require "redis_failover"

client = RedisFailover::Client.new(:zkservers => '192.168.50.10:2181')
