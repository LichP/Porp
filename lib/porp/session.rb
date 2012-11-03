#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'log4r'
require 'redis/spawn'

module Orp

# The session class manages the configuration, database configuration,
# and logging for the application.
class Session
  @@current = nil

  attr_reader :config, :logger, :redis

  # @return the current session
  def self.current
    @@current || raise(SessionNotStarted)
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
    @logger = Log4r::Logger.new(Process.pid.to_s)
    logger.add(Log4r::Outputter.stdout) # Use config at some point
    
    # If we need to spawn our own redis-server instance, do so now
    if config[:redis][:spawn]
      # May need to trap exceptions here
      @spawned_server = Redis.spawn(:server_opts => config[:redis][:server_opts])
    end
    
    # Connect to redis
    @redis = Redis.connect(config[:redis][:options])
  end
end

# A modification to Ohm::Model to hook in the Orp managed redis server
class Model < Ohm::Model
  def self.db
    Ohm.threaded[self] || Orp::Session.current.redis || raise(RedisNotConnected)
  end
end

# Convenience method for accessing the logger in the current session
def self.logger
  Orp::Session.current.logger
end

end
