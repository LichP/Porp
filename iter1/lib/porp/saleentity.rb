#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

class Porp

  # The SaleEntity class represents goods on sale. A SaleEntity consists of
  # some combination of StockEntities, usually one-to-one, but can be e.g.
  # a multiple of one item, or a bundle of several.
  class SaleEntity < OrpModel
    property :description, :long_desc
  
    # Creates a new SaleEntity record
    def self.create(description)
      new_sale_entity = self.new(self.new_id)
      new_sale_entity.description = description
      new_sale_entity
    end

    # Associates the SaleEntity with the supplied StockEntity. When there is a
    # SaleMovement for this SaleEntity, there will be a corresponding
    # StockMovement for quantity units of StockEntity
    def add_stock_entity(stock_id, quantity) # How to implement this?
      if StockEntity.exists?(stock_id)
        redis.sadd("#{Porp.ns}:saleentity:id:#{id}:stockentities", stock_id)
        redis.hset("#{Porp.ns}:saleentity:id:#{id}:stkequantities", stock_id, quantity)
      else
        false
      end
    end

    # Disassociates the sale entity with the supplied stock identity
    def rem_stock_entity(stock_id)
      redis.srem("#{Porp.ns}:saleentity:id:#{id}:stockentities", stock_id) 
      redis.hdel("#{Porp.ns}:saleentity:id:#{id}:stkequantities", stock_id)
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
  
