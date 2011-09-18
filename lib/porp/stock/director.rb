#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The Director class mediates the complex interactions between the various
stock related classes, in particular the Holding class, which represents the
actual stock, and the Entity, Holder, and Status classes, which between them
represent the three orthogonal concepts of what that stock is, where does it
belong, and what state is it in.

The model of stock in Orp is of holdings of stock moving though various
states and holders, with each combination of entity, holder, and status
being represented by a Holding.  Thus when the holder or status of a holding
of stock changes, the stock moves from one holding to another by way of a
Movement.  Stock enters and leaves the system of stock holdings by way of
movements from and to non-stock MovementTargets.

The model is sharded based on entity: any given stock entity requires at least
one holder in which holdings can exist, and at least one state of 'in stock'
e.g. the state stock is in when it exists in your retail outlet and available
for purchase by your customers. However, the precise model is dependent on
the requirements of a particular retail operation and their application for
any given entity or collection of entities.

It therefore falls to the Director class to take the model specified by user
configuration and apply it on a product group, stock entity, and default
basis as appropriate.
=end
  class Director

    # Build a stock entity and dependencies from passed options
    #
    # @param [String] description: A description for the entity
    # @param [Hash] opts: Options specifying names of holders and statuses
    # to create holdings for
    # @returns The newly created entity
    def self.build_from_options(description, opts)

      # Ensure holders and statuses exist
      ensure_holders(opts[:holders])
      ensure_statuses(opts[:statuses])
      
      # Create the entity
      entity = Entity.create(description: description)
      
      # Create holdings for every permutation of entity, holder, and status
      holding_permutations(entity, opts[:holders], opts[:statuses]) do |entity, holder, status|
        Holding.create(entity: entity, holder: holder, status: status)
      end
      
      # Return the entity
      entity
    end
    
    protected
    
    def self.ensure_holders(holder_names)
      raise Orp::NoHoldersSpecified if holder_names.nil?
      Holder.ensure_extant(holder_names)
    end

    def self.ensure_statuses(status_names)
      raise Orp::NoStatusesSpecified if status_names.nil?
      Status.ensure_extant(status_names)
    end

    def self.holding_permutations(entity, holder_names, status_names)
      holders  = Holder.find_union(name: holder_names)
      statuses = Status.find_union(name: status_names)
      holders.each do |holder|
        statuses.each do |status|
          yield entity, holder, status
        end
      end
    end
  end
end
  
