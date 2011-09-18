#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The StockEntity class represents physical stock. Quantities of StockEntities
are represented by StockHoldings.
=end
  class Entity < Ohm::Model
    attribute  :description
    index      :description
    #set :sale_entities, SaleEntity
    collection :holdings,  Holding, :entity
    list       :movements, Movement

    # Look up a holding corresponding to the passed attributes
    #
    # @params [Hash] attrs: attributes of the holding
    # @returns the corresponding holding or nil
    def holding(attrs)
      if attrs.kind_of?(Hash)
        holdings.find(name: attrs[:holder].to_s + "_" + attrs[:status].to_s).first
      else
        nil
      end
    end
    
    # Check the supplied target is a MovementTarget. If a hash is passed,
    # attempt to find a corresponding holding on this entity
    #
    # @param target: The target to check / hash to look up
    def lookup_target(target)
      if target.kind_of?(Hash)
        target = holding(target)
      end
      
      unless target.kind_of?(MovementTarget)
        raise Orp::MovementInvalidTarget, "#{target} is not a valid MovementTarget"
      end
      target
    end
    
    # Move stock represented by this entity
    #
    # @param [MovementTarget, Hash] source_target: The source of the stock
    #   to be moved, represented by a MovementTarget. Alternatively, if a
    #   Hash is passed, a Holding corresponsing to to the passed attributes
    #   will be used as the target.
    # @param [MovementTarget, Hash] dest_target: The destination of stock to
    #   be mover, either as a MovementTarget or Hash specifying Holding as
    #   above.
    # @param [Integer] qty: The number of units of stock being moved.
    # @param [Rational] ucost: The cost price per unit of stock. This can be
    #   overrided by the source_target if the value of stock is already known.
    # @return The completion status of the Movement
    def move(source_target, dest_target, qty, ucost)
      # Make sure the supplied target information is valid, looking up holdings
      # as appropriate
      source_target = lookup_target(source_target)
      dest_target = lookup_target(dest_target)

      # Create and conduct movement
      movement = Movement.move_no_cleanup(source_target:    source_target,
                                          source_entity_id: id,
                                          source_amount:    Amount.new(qty, ucost),
                                          dest_target:      dest_target,
                                          dest_entity_id:   id)

      # Return the completion status of the movement
      movements << movement
      movement.completed
    end

    def self.const_missing(name)
      Stock.const_get(name)
    end
  end  
end
  
