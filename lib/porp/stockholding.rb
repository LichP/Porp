#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockHolding class represents a collection of holdings of physical stock.
A StockHolding is a queue of StockHoldingEntries, each of which represents a
quantity of StockEntities. StockHoldingEntries are created and altered by
StockMovements, and are never destroyed. The lifetime of a StockHoldingEntry
will start with a receipt of stock (e.g. a GRN against a PO), and over time
the stock represented by the StockHoldingEntry will be reduced by issues (e.g. 
sales). Once a holding reaches zero it will normally be archived as part of
the stock movement audit trail.

StockHoldingEntries can be effectively merged by performing StockMovements from
the original StockHoldingEntries to a new StockHoldingEntry, and can likewise
be split in similar fashion.
=end
  class StockHolding < Ohm::Model
    reference :stock_entity, StockEntity
    attribute :quantity
    attribute :unit_cost
    collection :stock_issues, StockMovement, :source_stkh
    collection :stock_receipts, StockMovement, :dest_stkh

    # + doesn't work - need a union 
    def stock_movements
      StockMovement.find(:source_stkh_id => self.id, :dest_stkh_id => self.id)
    end

    # Creates a new StockHolding record linked to StockEntity stke
#    def self.create(stke, quantity, unit_cost)
#      new_stkh = self.new(self.new_id)
#      new_stkh.stock_entity_id = stke.id
#      new_stkh.quantity = quantity
#      new_stkh.unit_cost = unit_cost
#      new_stkh
#    end
    
    # Returns whether the StockHolding is end of life. True when quantity is
    # zero (and StockMovements > 0?)
    def eol?
      quantity == 0
    end
  end
#end
  
