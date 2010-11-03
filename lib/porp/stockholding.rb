#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

class Porp

=begin
The StockHolding class represents holdings of physical stock in the form of
quantities of StockEntities. StockHoldings are created and altered by
StockMovements, and are never destroyed. The lifetime of a StockMovement
will start with a receipt of stock (e.g. a GRN against a PO), and over time
the stock represented by the StockEntity will be reduced by issues (e.g. 
sales). Once a holding reaches zero it will normally be archived as part of
the stock movement audit trail.

StockHoldings can be effectively merged by performing StockMovements from
the original StockHoldings to a new StockHolding, and can likewise be split
in similar fashion.
=end
  class StockHolding < OrpModel
    property :stock_entity_id
    property :quantity
    property :unit_cost
  
    # Creates a new StockHolding record linked to StockEntity stke
    def self.create(stke, quantity, unit_cost)
      new_stkh = self.new(self.new_id)
      new_stkh.stock_entity_id = stke.id
      new_stkh.quantity = quantity
      new_stkh.unit_cost = unit_cost
      new_stkh
    end
    
    def stock_entity
      Porp::StockEntity.new(stock_entity_id)
    end
    
    # Returns whether the StockHolding is end of life. True when quantity is
    # zero (and StockMovements > 0?)
    def eol?
      quantity == 0
    end
  end
end
  
