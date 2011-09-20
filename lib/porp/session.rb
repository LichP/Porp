#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'log4r'
require 'redis'

module Orp

# The session class manages the configuration, database configuration,
# and logging for the application.
class Session
  @@current = nil

  attr_reader :config, :logger, :redis

  # @return the current session
  def self.current
    @@current
  end
  
  # Start a new session
  #
  # @param attrs: attributes to initialize the new session with
  # @return [Session] the new session object
  def self.start(attrs)
    @@current = self.new(attrs)
  end
  
  # Load a config from file and start a session with it
  #
  # @param [String] filename: name of the config file to load
  # @return [Session] the new session using the loaded config
  def self.load_file(filename)
    @@current = self.new(YAML.load_file(filename))
  end
  
  # Initialize a new session object
  #
  # @param [Hash] attrs: the configuration for the session
  def initialize(attrs)
    @config = attrs
    
    # Initialize logger
    @logger = Log4r::Logger.new(config.to_s)
    logger.add(Log4r::Outputter.stdout) # Use config at some point
    
    # If we need to spawn our own redis-server instance, do so now
    if config[:redis][:spawn]
      # May need to trap exceptions here
      spawn_redis(config[:redis][:config])
    end
    
    # Connect to redis
    @redis = Redis.connect(config[:redis][:options])
  end
  
  protected
  
  # Spawn a redis server instance for use with this session
  # @param [String] config_fn: the name of the config file
  # @return [Int or nil] PID of the child running redis-server
  def spawn_redis(config_fn)    
    # Make sure we clean up after our children and avoid a zombie invasion
    trap("CLD") do
      pid = Process.wait
    end
    # @todo sanity check config_fn
    pid = fork { exec("redis-server #{config_fn}") }
    logger.info("Spawned redis server with PID #{pid}")
    at_exit { Process.kill("TERM", pid) } # Maybe make this configurable to allow the server to continue after exit
    pid
  end
end

# A modification to Ohm::Model to hook in the Orp managed redis server
class Model < Ohm::Model
  def self.db
    Ohm.threaded[self] || Orp::Session.current.redis || raise(RedisNotConnected)
  end
end
end
