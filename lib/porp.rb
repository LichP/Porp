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
  @@options = {
    :ns_app        => 'porp',
    :ns_site       => 'mysite',
    :ns_deployment => 'dev'
  }

  def self.options
    @@options
  end

  def self.set_options(options = {})
    @@options.merge!(options)
  end

  # Namespace for all redis keys. By default compiles the string once only,
  # but can be forced to rebuild if necessary
  def self.ns(params = {:force_rebuild => false})
    @@ns = compile_ns_string if params[:force_rebuild]
    @@ns ||= compile_ns_string
  end

  def self.compile_ns_string
    "#{options[:ns_app]}:#{options[:ns_site]}:#{options[:ns_deployment]}"
  end

  # List all keys in the current namespace
  def self.ns_keys
    [redis.keys("#{ns}*")].flatten
  end  

  # Deletes all keys in the current namespace. This is intended primarily
  # for unit tests. The namespace string is explicitly rebuilt to ensure
  # any changes to the namespace options are picked up
  def self.purge_current_namespace!
    ns(:force_rebuild => :true)
    ns_keys.each { |key| redis.del(key) } unless ns_keys.nil?
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
      id = redis.incr("#{Porp.ns}:#{klass}:uid")
      redis.set("#{Porp.ns}:#{klass}:id:#{id.to_s}:created", 1)
      id
    end

    # Find a record by id
    def self.find_by_id(id)
      self.exists?(id) ? self.new(id) : nil
    end

    # Check if a record exists
    def self.exists?(id)
      klass = self.name.downcase
      redis.key?("#{Porp.ns}:#{klass}:id:#{id.to_s}:created")
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
            redis.get("#{Porp.ns}:#{klass}:id:" + id.to_s + ":#{name}")
          end

          def #{name}=(val)
            redis.set("#{Porp.ns}:#{klass}:id:" + id.to_s + ":#{name}", val)
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
        redis.sadd("#{Porp.ns}:stockentity:id:#{id}:saleentities", sale_id)
      else
        false
      end
    end

    def rem_sale_entity(sale_id)
      redis.srem("#{Porp.ns}:stockentity:id:#{id}:saleentities", sale_id) 
    end

    def sale_entities
      redis.smembers("#{Porp.ns}:stockentity:id:#{id}:saleentities)")
    end
  end

  class SaleEntity < OrpModel
    property :description, :long_desc
  
    # Create a new SaleEntity record
    def self.create(description)
      new_sale_entity = self.new(self.new_id)
      new_sale_entity.description = description
      new_sale_entity
    end

    # Associates the sale entity with the supplied stock identity   
    def add_stock_entity(stock_id)
      if StockEntity.exists?(stock_id)
        redis.sadd("#{Porp.ns}:saleentity:id:#{id}:stockentities", stock_id)
      else
        false
      end
    end

    # Disassociates the sale entity with the supplied stock identity
    def rem_stock_entity(stock_id)
      redis.srem("#{Porp.ns}:saleentity:id:#{id}:stockentities", stock_id) 
    end

    # Returns a list of all stock entity ids associated with the sale entity
    def stock_entities
      redis.smembers("#{Porp.ns}:saleentity:id:#{id}:stockentities")
    end

    # Adds a tag 
    def add_tag(new_tag)
      new_tag.downcase!  # Also need to strip whitespace
      redis.sadd("#{Porp.ns}:saleentity:id:#{id}:tags", new_tag)
      redis.sadd("#{Porp.ns}:saleentities:tags:#{new_tag}", id)
    end

    # Removes a tag 
    def remove_tag(dead_tag)
      dead_tag.downcase!  # Also need to strip whitespace
      redis.srem("#{Porp.ns}:saleentity:id:#{id}:tags", dead_tag)
      redis.srem("#{Porp.ns}:saleentities:tags:#{dead_tag}", id)
    end
  end
end
  
