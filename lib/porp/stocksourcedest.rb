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
  class StockSourceDest < MovementTarget
    attribute :net_stock_qty
    attribute :net_stock_value    

    # Set defaults for attributes if not supplied
    def initialize(attrs = {})
      super(attrs)
      net_stock_qty ||= 0
      net_stock_value ||= 0
    end
    
    # Issue stock from this target
    def issue(movement_id)
      movement = StockMovement[movement_id]
      
      # Lock while we update the attributes
      mutex do
        binding.pry
        self.net_stock_qty = Integer(self.net_stock_qty) - Integer(movement.source_qty)
        self.net_stock_value = Rational(self.net_stock_value) - Integer(movement.source_qty) * Rational(movement.source_unit_cost)
        self.save
      end

      # Return the quantity issued
      movement.source_qty
    end
    
    # Reverse an issue
    def reverse_issue(movement_id)
      movement = StockMovement[movement_id]
      
      # Lock while we update the attributes
      mutex do
        self.net_stock_qty = Integer(self.net_stock_qty) + Integer(movement.source_qty)
        self.net_stock_value = Rational(self.net_stock_value) + Integer(movement.source_qty) * Rational(movement.source_unit_cost)
        self.save
      end

      # Return the quantity issued (negated as we're reversing)
      -movement.source_qty
    end

    # Receive stock to this target
    def receive(movement_id)
      movement = StockMovement[movement_id]
      
      # Lock while we update the attributes
      # The stock value change is calculated on source qty and source unit
      # to ensure conservation of value. The destination unit cost can be
      # calculated by dividing out the dest qty
      mutex do
        self.net_stock_qty = Integer(self.net_stock_qty) + Integer(movement.dest_qty)
        self.net_stock_value = Rational(self.net_stock_value) + Integer(movement.source_qty) * Rational(movement.source_unit_cost)
        self.save
      end
      
      # Return the quantity received
      movement.dest_qty
    end    
  end

  # Misc target uses the default net quantity and net value scheme. It maintains
  # a single instance primarily intended for testing.  
  class MiscTarget < StockSourceDest
    @@misc_singleton = nil
  
    def self.acquire
      @@misc_singleton ||= self.new(id: 1)
      @@misc_singleton.save
    end
    
    def self.reinit(*args)
      @@misc_singleton ||= self.new(id: 1)
      @@misc_singleton.update(*args)
    end
  end
  
  # Null target literally does nothing. Intended for testing only.
  class NullTarget < StockSourceDest
    @@misc_singleton = nil
  
    def self.acquire
      @@null_singleton ||= self.new(id: 1)
      @@null_singleton.save
    end
    
    def self.reinit(*args)
      @@null_singleton ||= self.new(id: 1)
      @@null_singleton.update(*args)
    end

    def issue(movement_id)
      true
    end

    def reverse_issue(movement_id)
      true
    end

    def receive(movement_id)
      true
    end
  end
#end
  
