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
    set :sale_entities, SaleEntity
    collection :stock_holdings, StockHolding
  
  end
#end
  
