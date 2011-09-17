#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The StockEntity class represents physical stock. Quantities of StockEntities
are represented by StockHoldings.
=end
  class Entity < Ohm::Model
    attribute  :description
    index      :description
    #set :sale_entities, SaleEntity
    collection :holdings,  Holding, :entity
    list       :movements, Movement

    def create_holdings
      
    end
    
    def move(source_target, dest_target, qty, ucost)
      movement = StockMovement.move_no_cleanup(source_target:    source_target,
                                               source_entity_id:   id,
                                               source_amount:    Amount.new(qty, ucost),
                                               dest_target:      dest_target,
                                               dest_entity_id:     id)
      # Return the completion status of the movement
      stock_movements << movement
      movement.completed
    end

    def self.const_missing(name)
      Stock.const_get(name)
    end
  end  
end
  
