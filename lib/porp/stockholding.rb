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
    property :stock_entity
  
    # Creates a new StockHolding record linked to StockEntity with id stke_id
    def self.create(stke_id)
      if StockEntity.exists?(stke_id)
        new_stock_holding = self.new(self.new_id)
        new_stock_holding.stock_entity = stke_id
        stock_entity = StockEntity.new(stke_id)
        stock_entity.add_stock_holding(new_stock_holding.id)
        new_stock_holding
      else
        false
      end
    end
  end
end
  
