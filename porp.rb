#!/usr/bin/env ruby
#
# Porp - The Prototype open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'rubygems'
require 'redis'

def redis
 $redis ||= Redis.new
end

ORPNS = 'porp'

class OrpModel
  attr_reader :id

  def initialize(id)
    @id = id
  end
  
  def ==(other)
    @id.to_s == other.id.to_s
  end
  
  def self.new_id
    klass = self.name.downcase
    id = redis.incr("#{ORPNS}:#{klass}:uid")
    redis.set("#{ORPNS}:#{klass}:id:#{id.to_s}", 1)
    id
  end
  
  def self.property(name)
    klass = self.name.downcase
    self.class_eval <<-EOCE
      def #{name}
        _#{name}
      end
      
      def _#{name}
        redis.get("#{ORPNS}:#{klass}:id:" + id.to_s + ":#{name}")
      end

      def #{name}=(val)
        redis.set("#{ORPNS}:#{klass}:id:" + id.to_s + ":#{name}", val)
      end
    EOCE
  end
end

class StockEntity < OrpModel
  property :description

  def self.create(description)
    new_stock_entity = self.new(self.new_id)
    new_stock_entity.description = description
    new_stock_entity
  end  
end

test = StockEntity.create("Pie")

puts test.description
