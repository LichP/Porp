#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockMovement class represents movements of physical stock by moving quantities
and cost value from one StockHolding to another.
=end
  class StockMovement < Ohm::Model
    reference :source_stkh, StockHolding
    reference :dest_stkh, StockHolding

    # Creates a new StockHolding record linked to StockEntity stke
#    def self.create(stke, quantity, unit_cost)
#      new_stkh = self.new(self.new_id)
#      new_stkh.stock_entity_id = stke.id
#      new_stkh.quantity = quantity
#      new_stkh.unit_cost = unit_cost
#      new_stkh
#    end
  end
#end
  
