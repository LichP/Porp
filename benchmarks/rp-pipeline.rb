#!/usr/bin/env ruby1.9.1

require 'ruby-prof'

require 'fileutils'

$: << FileUtils.pwd.sub(/benchmarks$/, 'lib')

require 'porp'

class Ohm::Model
  alias_method :add_to_indices_original, :add_to_indices
  alias_method :delete_from_indices_original, :delete_from_indices

  def add_to_indices_pipelined
    db.pipelined do
      indices.each do |att|
        next add_to_index(att) unless collection?(send(att))
        send(att).each { |value| add_to_index(att, value) }
      end
    end
  end

  def delete_from_indices_pipelined
   indices = key[:_indices].smembers
    db.pipelined do
      indices.each do |index|
        db.srem(index, id)
      end
    end
        
    key[:_indices].del
  end
end

profile_choice = case ARGV.shift
  when "standard"  then :standard
  when "pipelined" then :pipelined
  else :standard
end
puts "Profile choice: #{profile_choice}"

if profile_choice == :pipelined
  class Ohm::Model
    alias_method :add_to_indices, :add_to_indices_pipelined
    alias_method :delete_from_indices, :delete_from_indices_pipelined
  end
end

# Flush database
puts "Flushing database"
Ohm.flush

# Create stock entities
print "Creating stock entities ... "
1000.times do |i|
  StockEntity.create(description: "Test stock entity #{i}")
end
puts "done."

# Create null target
null_target = NullTarget.acquire

# Touch holdings to bring them in to existance
print "Creating stock holdings ... "
StockEntity.all.each do |test_stke|
  test_stke.holding(:test_holding1)
  test_stke.holding(:test_holding2)
end
puts "done."

# Receive some stock from null target to test_holding1 for each entity.
# We do this 3 times to ensure we've got 3 entries in each test_holding1
# available to move on to test_holding2 in the real test
3.times do |i|
  puts "Receiving stock from null: pass #{i}"
  StockEntity.all.each do |test_stke|
    test_stke.move(null_target, test_stke.holding(:test_holding1), 10, 2.00)
  end
end

# Profile
puts "Commencing profiling"
RubyProf.start
StockEntity.all.each do |test_stke|
  test_stke.move(test_stke.holding(:test_holding1), test_stke.holding(:test_holding2), 10, 2.00)
end
result = RubyProf.stop
  
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})
