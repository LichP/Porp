#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

#module Porp

=begin
The StockMovement class represents movements of physical stock by moving
quantities and cost value from one MovementTarget to another.
=end
  class StockMovement < Ohm::Model
    include Ohm::Looseref
  
    looseref  :source_target, MovementTarget
    reference :source_stke, StockEntity
    attribute :source_qty
    attribute :source_unit_cost

    looseref  :dest_target, MovementTarget
    reference :dest_stke, StockEntity
    attribute :dest_qty
    
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
      movement = create(*args)
      movement.move_no_cleanup()
      movement
    end
    
    # Create the StockMovement, and set default values where appropriate
    def create(*args)
      super(*args)
      creation_time = Time.now.to_f
      issue_committed = false
      issue_time = nil
      rcpt_committed = false
      rcpt_time = nil
      completed = false
      completion_time = nil
      
      # Source quantity and unit cost default to zero if not supplied
      # (may want to add warning here in future)
      source_qty ||= 0
      unit_cost ||= 0
      
      # Destination stock entity is assumed to be the same as the source
      # stock entity if not supplied
      dest_stke_id ||= source_stke_id
      
      # Destination quantity is assumed to be the same as the source
      # quantity if not supplied
      dest_qty ||= source_qty
      save
    end
    
    # Validation. A movement must specify the following:
    #  * Source target
    #  * Destination target
    #  * Source stock entity
    def validate
      assert_present :source_target_id
      assert_present :dest_target_id
      assert_present :source_stke_id
    end

    # Commit the movement. If the movement fails, destroy the inconsistent
    # movement and reraise. Wraps move_no_cleanup
    def move(*args)
      begin
        move_no_cleanup(*args)
      rescue MovementAlreadyComplete
        warn "Attempted to complete already completed movement"
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
      
      mutex do
        self.update(*args) if args.length > 0
        raise Orp::MovementValidationError if !self.valid?

	# Commit the issue
	self.issue_committed = self.source_target.issue(id) ? true : false
	
	# Commit the receipt if the issue succeeded
	if self.issue_committed
	  self.issue_time = Time.now.to_f
	  self.rcpt_committed = self.dest_target.receive(id) ? true : false
	else
	  raise Orp::MovementIssueError
	end
	
	# Reverse the issue if the receipt failed
	if self.rcpt_committed
	  self.rcpt_time = Time.now.to_f
	else
	  self.issue_committed = self.source_target.reverse_issue(id) ? false : true
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
        self.save
      end
      return true
    end
  end
#end
  
