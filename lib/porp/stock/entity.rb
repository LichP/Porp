#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockEntity class represents physical stock. Quantities of StockEntities
are represented by StockHoldings.
=end
class Stock
  class Entity < Ohm::Model
    attribute  :description
    index      :description
    #set :sale_entities, SaleEntity
    collection :stock_holdings, StockHolding, :entity
    list       :stock_movements, StockMovement

    def create_holdings
      
    end
    
    def holding(name)
      stock_holdings.find(:name => name).first || StockHolding.create(name: name, entity: self)
    end
  
    def move(source_target, dest_target, qty, ucost)
      movement = StockMovement.move_no_cleanup(source_target:    source_target,
                                               source_stke_id:   id,
                                               source_amount:    Amount.new(qty, ucost),
                                               dest_target:      dest_target,
                                               dest_stke_id:     id)
      # Return the completion status of the movement
      stock_movements << movement
      movement.completed
    end
  end
end
#end
  
