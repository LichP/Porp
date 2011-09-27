#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

# The PLU class provides Product Look Ups. The Lookup can be a barcode number
# or any other string identifier. Each lookup can be associated with exactly
# one Stock, Sale, or Purchase Entity
class PLU < Orp::Model
  attribute :value
  index     :value
  reference :stock_entity, Stock::Entity
  
  def self.lookup(lookup_value)
    find(value: lookup_value.to_s).first
  end
  
  def validate
    assert_unique :value
  end
  
  def to_s
    value.to_s
  end
end

