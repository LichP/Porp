#!/usr/bin/env ruby
#
# Porp - The Prototype open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

class Porp

  # Provides a generic Redis based data model.
  class OrpModel
    attr_reader :id

    def initialize(id)
      @id = id
    end
  
    def ==(other)
      @id.to_s == other.id.to_s
    end
  
    # Fetches the next available id for a new record. This method sets a
    # record key with this id so effectively creates the record  
    def self.new_id
      klass = self.name.downcase
      id = redis.incr("#{Porp.ns}:#{klass}:uid")
      redis.set("#{Porp.ns}:#{klass}:id:#{id.to_s}:created", 1)
      id
    end

    # Finds a record by id
    def self.find_by_id(id)
      self.exists?(id) ? self.new(id) : nil
    end

    # Checks whether a record exists
    def self.exists?(id)
      klass = self.name.downcase
      redis.key?("#{Porp.ns}:#{klass}:id:#{id.to_s}:created")
    end

    # Creates accessor methods for attributes stored as simple values in the db
    def self.property(*names)
      klass = self.name.downcase
      names.each do |name|
        self.class_eval <<-EOCE
          def #{name}
            _#{name}
          end
      
          def _#{name}
            redis.get("#{Porp.ns}:#{klass}:id:" + id.to_s + ":#{name}")
          end

          def #{name}=(val)
            redis.set("#{Porp.ns}:#{klass}:id:" + id.to_s + ":#{name}", val)
          end
        EOCE
      end
    end
  end
end
  
