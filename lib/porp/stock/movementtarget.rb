#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
  The MovementTarget class represents everything that can be the target of a
  stock movement. It is subclassed by StockSourceDest, which represents
  targets which create and destroy stock, and by StockHolding, which
  represents physical stock holdings.
=end
  class MovementTarget < Orp::Model
  
    # If inherited ensure the child gets attributes defined in higher classes
    def self.inherited(subclass)
      subclass.attributes.concat(self.attributes).uniq!
    end

    # Stub for issue method: needs to be implemented by subclasses
    def issue(movement)
      false
    end

    # Stub for reverse_issue method: needs to be implemented by subclasses
    def reverse_issue(movement)
      false
    end

    # Stub for receive method: needs to be implemented by subclasses
    def receive(movement)
      false
    end

    # Clear locally cached attributes, forcing reload from redis on next
    # access. Looses any unsaved changes
    def reload_attributes
      @_attributes.clear
    end
  end
end
  
