#!/usr/bin/env ruby1.9.1

#require 'pry'
require 'ruby-prof'
require 'fileutils'

$: << FileUtils.pwd.sub(/irb$/, 'lib')

require 'porp'

$read_local_uber_counter = 0

class Ohm::Model
  def add_to_indices
    db.pipelined do
      indices.each do |att|
        next add_to_index(att) unless collection?(send(att))
        send(att).each { |value| add_to_index(att, value) }
      end
    end
  end

  def delete_from_indices
    key[:_indices].smembers.each do |index|
      db.pipelined do
        db.srem(index, id)
      end
    end
        
    key[:_indices].del
  end
  
#  def read_local(att)
#    @_attributes[att]
#  end

  def initialize(attrs = {})
    @id = nil   
    @_memo = {}
    @_attributes = Hash.new do |hash, key|
      hash[key] = read_remote(key)
#      $read_local_uber_counter += 1
#      if $read_local_uber_counter.modulo(5000) == 0
#        binding.pry
#      end
    end
    update_attributes(attrs)
  end


  def write
    unless (attributes + counters).empty?
      @_attributes = key.hgetall.merge(@_attributes)
      atts = (attributes + counters).inject([]) { |ret, att|
        value = send(att).to_s
 
        ret.push(att, value) if not value.empty?
        ret
      }

      db.multi do
        key.del
        key.hmset(*atts.flatten) if atts.any?
      end
    end
  end
end

#test_stke_array = []
#101.upto(900) do |i|
#  StockEntity.find(description: "Test stock entity #{i}").first || StockEntity.create(description: "Test stock entity #{i}")
#end

#holding_target = test_stke.holding(:test_holding)
#holding_target2 = test_stke.holding(:test_holding2)
#misc_target = MiscTarget.acquire
null_target = NullTarget.acquire

#binding.pry

StockEntity.all.each do |test_stke|
#  puts test_stke.description
  test_stke.move(null_target, test_stke.holding(:test_holding), 10, 2.00)
end

RubyProf.start
StockEntity.all.each do |test_stke|
#  puts test_stke.description
  test_stke.move(test_stke.holding(:test_holding), test_stke.holding(:test_holding2), 10, 2.00)
end
result = RubyProf.stop

#binding.pry

# Print a flat profile to text
printer = RubyProf::GraphPrinter.new(result)
#printer = RubyProf::CallTreePrinter.new(result)
printer.print(STDOUT, {})
