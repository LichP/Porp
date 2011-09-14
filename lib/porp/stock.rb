#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

require File.join(File.dirname(__FILE__), 'stock', 'director')
require File.join(File.dirname(__FILE__), 'stock', 'entity')
require File.join(File.dirname(__FILE__), 'stock', 'holder')
require File.join(File.dirname(__FILE__), 'stock', 'movement')
require File.join(File.dirname(__FILE__), 'stock', 'movementtarget')
require File.join(File.dirname(__FILE__), 'stock', 'holding')
require File.join(File.dirname(__FILE__), 'stock', 'sourcedest')
require File.join(File.dirname(__FILE__), 'stock', 'status')

=begin
The Stock class provides the high level interface for interacting with stock.
=end
  class Stock
    attr_reader :entity
  
    # Return a Stock instance for the stock entity identified by id
    def self.[](id)
      entity = Entity[id]
      if !entity.nil?
        self.new(Entity[id])
      else
        nil
      end
    end

    # Creates a new item of stock, including the entity and all holdings,
    # ensuring all dependencies are met i.e. all targets, holders, and statuses
    def self.create(description = "", opts = {})
      raise Orp::NoHoldersSpecified if opts[:holders].nil?
      raise Orp::NoStatusesSpecified if opts[:statuses].nil?

      self.new(Director.build_from_options(description, opts)
    end

    def initialize(entity = nil)
      @entity = entity
    end
  end
#end
  
