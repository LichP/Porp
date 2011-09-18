#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

require File.join(File.dirname(__FILE__), 'stock', 'director')
require File.join(File.dirname(__FILE__), 'stock', 'entity')
require File.join(File.dirname(__FILE__), 'stock', 'holder')
require File.join(File.dirname(__FILE__), 'stock', 'movementtarget')
require File.join(File.dirname(__FILE__), 'stock', 'movement')
require File.join(File.dirname(__FILE__), 'stock', 'holding')
require File.join(File.dirname(__FILE__), 'stock', 'sourcedest')
require File.join(File.dirname(__FILE__), 'stock', 'status')

# The Stock class provides the high level interface for interacting with stock.
class Stock
  attr_reader :entity
  
  # @return A Stock instance for the stock entity identified by id
  def self.[](id)
    entity = Entity[id]
    if !entity.nil?
      self.new(Entity[id])
    else
      nil
    end
  end
  
  # Find an item of stock by PLU
  def self.find_by_plu(plu_value)
    entity = Entity.find_by_plu(plu_value)
    if !entity.nil?
      self.new(entity)
    else
      nil
    end
  end

  # Creates a new item of stock, including the entity and all holdings,
  # ensuring all dependencies are met i.e. all targets, holders, and statuses
  # 
  # @param [String] description description of the stock
  # @param [Hash] opts stock creation options
  #
  # @return [Stock] the newly created item of stock
  def self.create(description = "", opts = {})
    raise Orp::NoHoldersSpecified if opts[:holders].nil?
    raise Orp::NoStatusesSpecified if opts[:statuses].nil?

    self.new(Director.build_from_options(description, opts))
  end

  def initialize(entity = nil)
    @entity = entity
  end
  
  # @return The ID of the associated entity
  def id
    entity.id
  end
end

