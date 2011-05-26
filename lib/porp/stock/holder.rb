#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockHolder class represents holders of stock, such as outlets, stock rooms,
warehouses, etc.
=end
class Stock
  class Holder < Ohm::Model
    attribute  :description
    index      :description
    collection :stock_holdings, StockHolding, :holder
  end
end
#end
  
