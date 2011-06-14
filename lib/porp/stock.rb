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
  
    def self.[](id)
      entity = Entity[id]
      if !entity.nil?
        self.new(Entity[id])
      else
        nil
      end
    end

    def initialize(entity = nil)
      @entity = entity
    end
  end
#end
  
