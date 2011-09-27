#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The StockMovement class represents movements of physical stock by moving
quantities and cost value from one MovementTarget to another.
=end
  class Movement < Orp::Model
    include Ohm::Looseref
    include Ohm::Struct
    include Ohm::Locking
  
    looseref  :source_target, MovementTarget
    reference :source_entity, Entity
    struct    :source_amount, Amount

    looseref  :dest_target, MovementTarget
    reference :dest_entity, Entity
    struct    :dest_amount, Amount
    
    attribute :creation_time
    attribute :issue_committed
    attribute :issue_time
    attribute :rcpt_committed
    attribute :rcpt_time
    attribute :completed
    attribute :completion_time
    attribute :narrative
    
    # Create a new movement and commit it 
    def self.move(*args)
      movement = create(*args)
      movement.move()
      movement
    end
    
    # Create a new movement and commit it. If the commit fails, the uncommitted
    # movement remains in the database.
    def self.move_no_cleanup(*args)
#      movement = create(*args)
      movement = new(*args)
      movement.move_no_cleanup()
    end
    
    # Set defaults for attributes
    def initialize(attrs = {})
      super(attrs)
      self.creation_time ||= Time.now.to_f

      # Source quantity and unit cost default to one and zero if not supplied. It is
      # expected that unit cost will be determined by the source
      # (may want to raise here in future if zero qty passed in)
      self.source_amount ||= Amount.new(1, 0)
      
      # Destination stock entity is assumed to be the same as the source
      # stock entity if not supplied
      self.dest_entity_id ||= self.source_entity_id
      
      # Destination quantity is assumed to be the same as the source
      # quantity if not supplied.
      # Destination unit cost is always calculated such that
      # source_amount.value == dest_amount.value
      self.dest_amount ||= Amount.new(self.source_amount.qty, 0)      
      self.dest_amount.ucost = Rational(source_amount.value) / Integer(dest_amount.qty)
    end
    
    # Validation. A movement must specify the following:
    #  * Source target
    #  * Destination target
    #  * Source stock entity
    def validate
      assert_present :source_target_id
      assert_present :source_target_class
      assert_present :dest_target_id
      assert_present :dest_target_class
      assert_present :source_entity_id
    end

    # Commit the movement. If the movement fails, destroy the inconsistent
    # movement and reraise. Wraps move_no_cleanup
    def move(*args)
      begin
        move_no_cleanup(*args)
      rescue Orp::MovementAlreadyComplete
        warn "Attempted to complete already completed movement"
        nil
      rescue
        delete
        raise
      end
    end

    # Commit the movement. If the movement fails, the uncommitted movement will
    # be left in the database for inspection
    def move_no_cleanup(*args)
      # Abort if the movement is already complete
      raise Orp::MovementAlreadyComplete if completed

      raise Orp::MovementValidationError if !self.valid?
      self.update(*args) if args.length > 0

      # This mutex prevents against two attempts to complete the same move
      # simultaneously. The movement remains editable throughout.
      #
      # BUT: Do we even need this? If the movement is only created just in time
      # then nothing else is going to have that instance 
#      mutex(0.01) do
	# Commit the issue
	self.issue_committed = self.source_target.issue(self) ? true : false
	
	# Commit the receipt if the issue succeeded
	if self.issue_committed
	  self.issue_time = Time.now.to_f
	  # Recalculate the destination unit cost in case the source
	  # overrided the source unit cost
	  self.dest_amount.ucost = Rational(self.source_amount.value / self.dest_amount.qty)
	  self.rcpt_committed = self.dest_target.receive(self) ? true : false
	else
	  raise Orp::MovementIssueError
	end
	
	# Reverse the issue if the receipt failed
	if self.rcpt_committed
	  self.rcpt_time = Time.now.to_f
	else
	  self.issue_committed = self.source_target.reverse_issue(self) ? false : true
	  if !self.issue_committed
	    # If issue_committed is still true, then the issue reversal also
	    # failed!
	    raise Orp::MovementReverseIssueError
	  else
	    self.issue_time = nil
	    raise Orp::MovementRcptError
	  end
	end
	
        # Movement is now done
        self.completed = true
        self.completion_time = Time.now.to_f
#      end
      Orp.logger.info(self.to_s)
      self.save
    end
    
    # @return [String] string representation of a Movement
    def to_s
      "Movement: %s '%s' [%s] x %s @ %s > %s[%s] x %s @ %s '%s'" % [
        completed ? '.' : '!',
        source_entity,
        source_target,
        source_amount.qty,
        source_amount.ucost,
        dest_entity != source_entity ? "'#{dest_entity}' " : '',
        dest_target,
        dest_amount.qty,
        dest_amount.ucost,
        narrative
      ]
    end
  end
end
  
