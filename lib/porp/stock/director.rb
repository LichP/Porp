#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockDirector class mediates the complex interactions between the various
stock related classes, in particular the StockHolding class, which represents
the actual stock, and the StockEntity, StockHolder, and StockStatus classes,
which between them represent the three orthogonal concepts of what that stock
is, where does it belong, and what state is it in.

The model of stock in Orp is of holdings of stock moving though various
states and holders, with each combination of entity, holder, and status being
represented by a StockHolding. Thus when the holder or status of a holding of
stock changes, the stock moves from one holding to another by way of a
StockMovement. Stock enters and leaves the system of stock holdings by way of
movements from and to non-stock MovementTargets.

The model is sharded based on entity: any given stock entity requires at least
one holder in which holdings can exist, and at least one state of 'in stock'
e.g. the state stock is in when it exists in your retail outlet and available
for purchase by your customers. However, the precise model is dependent on
the requirements of a particular retail operation and their application for
any given entity or collection of entities.

It therefore falls to the StockDirector class to take the model specified by
user configuration and apply it on a product group, stock entity, and default
basis as appropriate.
=end
class Stock
  class Director

    def self.ensure_holders(holders)
      raise Orp::NoHoldersSpecified if holders.nil?
    end

    def self.ensure_statuses(statuses)
      raise Orp::NoStatusesSpecified if holders.nil?
    end

    # Build a stock entity and dependencies from passed options
    def self.build_from_options(description, opts)
            
    end
  end
end
#end
  
