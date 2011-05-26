#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockStatus class represents different states can hold, such as 'in stock',
'on order', etc
=end
  class StockStatus < Ohm::Model
    attribute  :description
    index      :description
    collection :stock_holdings, StockHolding, :status
  end
#end
  
