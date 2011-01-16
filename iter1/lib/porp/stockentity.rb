#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

class Porp

=begin
The StockEntity class represents physical stock. StockEntities are
associated with one or more BuyingEntities, and one or more
SellingEntities. Quantities of stock are represented by StockHoldings.
=end
  class StockEntity < OrpModel
    property :description
  
    # Creates a new StockEntity record
    def self.create(description)
      new_stock_entity = self.new(self.new_id)
      new_stock_entity.description = description
      new_stock_entity
    end
  
    # Associates the StockEntity with a SaleEntity of id sale_id
    def add_sale_entity(sale_id)
      if SaleEntity.exists?(sale_id)
        redis.sadd("#{Porp.ns}:stockentity:id:#{id}:saleentities", sale_id)
      else
        false
      end
    end

    # Disassociates the StockEntity from a SaleEntity of id sale_id
    def rem_sale_entity(sale_id)
      redis.srem("#{Porp.ns}:stockentity:id:#{id}:saleentities", sale_id) 
    end

    # Returns a list of all associated SaleEntity ids
    def sale_entities
      redis.smembers("#{Porp.ns}:stockentity:id:#{id}:saleentities)")
    end
    
    # Associates the StockEntity with a StockHolding
    def add_new_stock_holding(quantity, cost)
      stkh = Porp::StockHolding.create(self, quantity, cost)
      redis.sadd("#{Porp.ns}:stockholding:id:#{id}:stockholdings", stkh.id)
    end
    
    # Archive an end-of-life StockHolding
    def archive_stock_holding(stkh)
      redis.smove("#{Porp.ns}:stockholding:id:#{id}:stockholdings",
                  "#{Porp.ns}:stockholding:id:#{id}:archivestockholdings", stkh.id)
    end
  end
end
  
