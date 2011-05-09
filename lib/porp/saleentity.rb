#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

  # The SaleEntity class represents goods on sale. A SaleEntity consists of
  # some combination of StockEntities, usually one-to-one, but can be e.g.
  # a multiple of one item, or a bundle of several.
  class SaleEntity < Ohm::Model
    attribute :description
    attribute :long_desc
  
    set :stock_entities, StockEntity

    # Associates the SaleEntity with the supplied StockEntity. When there is a
    # SaleMovement for this SaleEntity, there will be a corresponding
    # StockMovement for quantity units of StockEntity
#    def add_stock_entity(stock_id, quantity) # How to implement this?
#      if StockEntity.exists?(stock_id)
#        redis.sadd("#{Porp.ns}:saleentity:id:#{id}:stockentities", stock_id)
#        redis.hset("#{Porp.ns}:saleentity:id:#{id}:stkequantities", stock_id, quantity)
#      else
#        false
#      end
#    end

    # Disassociates the sale entity with the supplied stock identity
#    def rem_stock_entity(stock_id)
#      redis.srem("#{Porp.ns}:saleentity:id:#{id}:stockentities", stock_id) 
#      redis.hdel("#{Porp.ns}:saleentity:id:#{id}:stkequantities", stock_id)
#    end
  end
#end
  
