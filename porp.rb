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

  def initialize
    klass = self.class.to_s.downcase
    @id = redis.incr("#{ORPNS}:#{klass}:uid")
    redis.set("#{ORPNS}:#{klass}:id:#{id.to_s}", 1)
  end
  
  def ==(other)
    @id.to_s == other.id.to_s
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

  def initialize(description)
    super()
    self.description = description
  end  
end

test = StockEntity.new("Pie")

puts test.description
