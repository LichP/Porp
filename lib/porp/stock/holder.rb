#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The StockHolder class represents holders of stock, such as outlets, stock rooms,
warehouses, etc.
=end
  class Holder < Orp::Model
    include Ohm::FindAdditions
  
    attribute  :name
    index      :name
    attribute  :description
    collection :holdings, ->(id) {Holding[id]}, :holder
    
    def validate
      assert_unique :name
    end
    
    # Ensure that a holder object corresponding to each passed string or symbol
    # exists, creating it if not
    #
    # @param holders Collection of strings or symbols corresponding
    #   to names of holders
    def self.ensure_extant(holders)
      holders = [holders] unless holders.kind_of?(Array)
      holders.each {|name| find_or_create(name: name)}
    end
  end
end
  
