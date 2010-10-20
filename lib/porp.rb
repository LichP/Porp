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

class Porp

  # Namespace for all redis keys
  NS_APP = 'porp'
  NS_SITE = 'mysite'
  NS_DEPLOYMENT = 'dev'
  def self.ns
    @@ns ||= "#{ns_app}:#{ns_site}:#{ns_deployment}"
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
      self.exists?(id) ? self.new(id) : nil
    end

    # Check if a record exists
    def self.exists?(id)
      klass = self.name.downcase
      redis.key?("#{ns}:#{klass}:id:#{id.to_s}:created")
    end

    # Create accessor methods for attributes stored as simple values in the db
    def self.property(*names)
      klass = self.name.downcase
      names.each do |name|
        self.class_eval <<-EOCE
          def #{name}
            _#{name}
          end
      
          def _#{name}
            redis.get("#{ns}:#{klass}:id:" + id.to_s + ":#{name}")
          end

          def #{name}=(val)
            redis.set("#{ns}:#{klass}:id:" + id.to_s + ":#{name}", val)
          end
        EOCE
      end
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
  
    def add_sale_entity(sale_id)
      if SaleEntity.exists?(sale_id)
        redis.sadd("#{ns}:stockentity:id:#{id}:saleentities", sale_id)
      else
        false
      end
    end

    def rem_sale_entity(sale_id)
      redis.srem("#{ns}:stockentity:id:#{id}:saleentities", sale_id) 
    end

    def sale_entities
      redis.smembers("#{ns}:stockentity:id:#{id}:saleentities)")
    end
  end

  class SaleEntity < OrpModel
    property :description, :long_desc
  
    # Create a new StockEntity record
    def self.create(description)
      new_sale_entity = self.new(self.new_id)
      new_sale_entity.description = description
      new_sale_entity
    end
  
    def add_stock_entity(stock_id)
      if StockEntity.exists?(stock_id)
        redis.sadd("#{ns}:saleentity:id:#{id}:stockentities", stock_id)
      else
        false
      end
    end

    def rem_stock_entity(stock_id)
      redis.srem("#{ns}:saleentity:id:#{id}:stockentities", stock_id) 
    end

    def sale_entities
      redis.smembers("#{ns}:saleentity:id:#{id}:stockentities)")
    end  
  end
end
  
