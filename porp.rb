#!/usr/bin/env ruby
#
# Porp - The Prototype open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'rubygems'
require 'redis'

# Make redis available everywhere
def redis
 $redis ||= Redis.new
end

# Namespace for all redis keys
ns_app = 'porp'
ns_site = 'mysite'
ns_deployment = 'dev'
def ns
  $ns ||= "#{ns_app}:#{ns_site}:#{ns_deployment}"
end

class OrpModel
  attr_reader :id

  def initialize(id)
    @id = id
  end
  
  def ==(other)
    @id.to_s == other.id.to_s
  end
  
  # Fetch the next available id for new record. This method sets a record key
  # with this id so effectively creates the record  
  def self.new_id
    klass = self.name.downcase
    id = redis.incr("#{ns}:#{klass}:uid")
    redis.set("#{ns}:#{klass}:id:#{id.to_s}:created", 1)
    id
  end

  # Find a record by id
  def self.find_by_id(id)
    klass = self.name.downcase
    if redis.key?("#{ns}:#{klass}:id:#{id.to_s}:created")
    self.new(id)
  end

  # Create accessor methods for attributes stored as simple values in the db
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

  # Create a new StockEntity record
  def self.create(description)
    new_stock_entity = self.new(self.new_id)
    new_stock_entity.description = description
    new_stock_entity
  end
  
end

test = StockEntity.create("Pie")

puts test.description
puts test.id

test_retrieve = StockEntity.find_by_id(test.id)
puts test_retrieve.description
