#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockEntity class represents physical stock. StockEntities are
associated with one or more BuyingEntities, and one or more
SellingEntities. Quantities of stock are represented by StockHoldings.
=end
  class StockEntity < Ohm::Model
    attribute :description
    #set :sale_entities, SaleEntity
    collection :stock_holdings, StockHolding
    list :stock_movements, StockMovement
  
    def move(source_target, dest_target, qty, unit_cost)
      stock_movements << StockMovement.move_no_cleanup(source_target:    source_target,
                                                       source_stke_id:   id,
                                                       source_qty:       Integer(qty),
                                                       source_unit_cost: Rational(unit_cost),
                                                       dest_target:      dest_target,
                                                       dest_stke_id:     id)
      # Return the completion status of the movement
      stock_movements[-1].completed
    end
  end
#end
  
