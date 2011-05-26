#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockSourceDest class represents movement targets which create or
destroy stock. Class implements a default source/destination issue and receipt
behaviour
=end
class Stock
  class SourceDest < MovementTarget
    include Ohm::Locking

    attribute :net_stock_qty
    attribute :net_stock_value    

    # Set defaults for attributes if not supplied
    def initialize(attrs = {})
      super(attrs)
      self.net_stock_qty ||= 0
      self.net_stock_value ||= 0
    end
    
    # Issue stock from this target
    def issue(movement)
      # Lock while we update the attributes
      mutex(0.01) do
        self.net_stock_qty = Integer(self.net_stock_qty) - Integer(movement.source_amount.qty)
        self.net_stock_value = Rational(self.net_stock_value) - Rational(movement.source_amount.value)
      end
      self.save

      # Return the quantity issued
      movement.source_amount.qty
    end
    
    # Reverse an issue
    def reverse_issue(movement)
      # Lock while we update the attributes
      mutex(0.01) do
        self.net_stock_qty = Integer(self.net_stock_qty) + Integer(movement.source_amount.qty)
        self.net_stock_value = Rational(self.net_stock_value) + Rational(movement.source_amount.value)
      end
      self.save

      # Return the quantity issued (negated as we're reversing)
      -movement.source_amount.qty
    end

    # Receive stock to this target
    def receive(movement)
      # Lock while we update the attributes
      # The stock value change is calculated on source qty and source unit
      # to ensure conservation of value. The destination unit cost can be
      # calculated by dividing out the dest qty
      mutex(0.01) do
        self.net_stock_qty = Integer(self.net_stock_qty) + Integer(movement.dest_amount.qty)
        self.net_stock_value = Rational(self.net_stock_value) + Rational(movement.source_amount.value)
      end
      self.save
      
      # Return the quantity received
      movement.dest_amount.qty
    end    
  end

  # Misc target uses the default net quantity and net value scheme. It maintains
  # a single instance primarily intended for testing.  
  class MiscTarget < SourceDest
    @@misc_singleton = Hash.new
  
    def self.acquire
      @@misc_singleton[self] ||= self.create
    end
    
    def self.reinit(*args)
      @@misc_singleton[self] = self.create(*args)
    end

    # Ensure only one instance in the database by overriding id creation and
    # only ever allowing the first id
    def initialize_id
      @id = "1"
    end
  end
  
  # Null target literally does nothing. Intended for testing only.
  class NullTarget < MiscTarget
    def issue(movement)
      true
    end

    def reverse_issue(movement)
      true
    end

    def receive(movement)
      true
    end
  end
end
#end
