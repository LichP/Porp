#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The Holding class represents a collection of holdings of physical stock.
A Holding is a queue of HoldingEntries, each of which represents a
quantity of Entities. HoldingEntries are created and altered by
Movements, and are never destroyed. The lifetime of a HoldingEntry
will start with a receipt of stock (e.g. a GRN against a PO), and over time
the stock represented by the HoldingEntry will be reduced by issues (e.g. 
sales). Once a holding reaches zero it will normally be archived as part of
the stock movement audit trail.

HoldingEntries can be effectively merged by performing Movements from
the original HoldingEntries to a new HoldingEntry, and can likewise
be split in similar fashion.
=end
  class Holding < MovementTarget
    reference :entity,          ->(id) {Entity[id]}
    reference :holder,          ->(id) {Holder[id]}
    reference :status,          ->(id) {Status[id]}
    list      :entries,         HoldingEntry
    list      :defunct_entries, HoldingEntry
    attribute :name
    index     :name
    
    def initialize(attrs)
      super(attrs)
      self.name ||= self.holder.name + "_" + self.status.name
    end
    
    
    # Calculates the total quantity of stock held in this holding from the holding
    # entries
    #
    # @return [Integer] quantity of stock in the holding
    def quantity
      entries.all.inject(0) do |sum, entry|
        sum += entry.amount_remaining.int_qty
      end
    end

    # (see #quantity)
    def qty
      quantity
    end

    # Calculates the total value of stock held in this holding from the holding
    # entries
    #
    # @return [Rational] value of stock in the holding
    def value
      entries.all.inject(Rational(0)) do |sum, entry|
        sum += entry.amount_remaining.value
      end
    end
    
    # @return [String] string representation of the holding
    def to_s
      "Holding: %s; H: %s; S: %s; N: %s; Qty: %s; Value: %s" % [
        id, holder_id, status_id, name, quantity, value
      ]
    end

    # Issue stock from this holding. The issue proceeds as follows:
    #
    # 1) Issue stock from first entry. If there is sufficient stock, finish.
    # 2) If there is insufficient stock on the first entry, continue issue
    #    from the second entry, and so on until the issue is complete
    # 3) If there is insufficient stock on all entries, create a negative
    #    stock entry for the remainder
    def issue(movement)
      movement_amount_remaining = movement.source_amount
      issued_value = 0
      
      while movement_amount_remaining.int_qty > 0 do
        unless entries.empty?
          current_entry = entries.first
          if current_entry.amount_remaining.int_qty >= movement_amount_remaining.int_qty
            current_entry.amount_out.int_qty += movement_amount_remaining.int_qty
            issued_value += movement_amount_remaining.value
            current_entry.save
            #defunct_entries << entries.shift if current_entry.eol?
            # The below is equivalent to the above but avoids instantiating the
            # intermediate entry
            defunct_entries.key.rpush(entries.key.lpop) if current_entry.eol?
            break
          else
            movement_amount_remaining.int_qty -= current_entry.amount_remaining.int_qty
            issued_value += current_entry.amount_remaining.value
            current_entry.amount_out = current_entry.amount_in            
            current_entry.save
            defunct_entries.key.rpush(entries.key.lpop)
          end
        else
          # Negative stock entry territory
          # We'll have a go at this later
          warn("Can't handle negatives!")
          break
        end
      end
      
      # Recalculate source amount unit cost
      movement.source_amount.ucost = issued_value / movement.source_amount.qty
      
      # Return qty issued
      movement.source_amount.qty
    end

    # Can't do this yet. Your receipts better not fail :-)
    def reverse_issue(movement)
      false
    end
    
    # Receive stock on to this holding. For the moment, we simply create a new
    # entry each time - this may change to allow modifying entries in place
    def receive(movement)
      entry = HoldingEntry.create(amount_in: movement.dest_amount, stock_holding_id: id)
      entries << entry
      entry.amount_in.qty
    end

    def self.const_missing(name)
      Stock.const_get(name)
    end
  end
  
  class HoldingEntry < Ohm::Model
    include Ohm::Callbacks
    include Ohm::Struct
    
    before    :save, :mtime_update
  
    reference :stock_holding, Holding
    attribute :ctime
    attribute :mtime
    struct    :amount_in,  Amount
    struct    :amount_out, Amount
    
    def initialize(attrs = {})
      attrs.delete(:ctime)  # ctime can never be overruled)
      super(attrs)
#      binding.pry
      self.ctime ||= Time.now.to_f
      self.amount_in ||= Amount.new(0, 0)
      self.amount_out ||= Amount.new(0, self.amount_in.ucost)
    end
    
    # Returns the amount remaining as an Amount struct
    # The unit cost can only ever be as per amount_in
    def amount_remaining
      Amount.new(Integer(amount_in.qty) - Integer(amount_out.qty), amount_in.ucost)
    end

    # Returns whether the Holding is end of life. True when quantity is
    # zero (and Movements > 0?)
    def eol?
      !self.amount_in.nil? &&self.amount_in.int_qty == self.amount_out.int_qty
    end
    
    # Updates the mtime attribute to the current time
    def mtime_update
      self.mtime = Time.now.to_f
    end

    def self.const_missing(name)
      Stock.const_get(name)
    end
  end
end
  
