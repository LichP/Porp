#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

# Structs and other lightweight classes

# Amount: simple struct to hold a quantity and a unit cost with forced
# type convertion
Amount = Struct.new(:qty, :ucost) do
  def int_qty
    Integer(self.qty)
  end
  
  def int_qty=(integer)
    self.qty = integer
  end
  
  def rat_ucost
    Rational(self.ucost)
  end
  
  def rat_ucost=(rational)
    self.ucost = rational
  end

  def value
    Integer(qty) * Rational(ucost)
  end
  
  def nil?
    qty.nil? && ucost.nil?
  end
end
