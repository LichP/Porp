#!/usr/bin/env ruby1.9.1

require 'benchmark'

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
    indices_key = key[:_indices].smembers
    db.pipelined do
      indices_key.each do |index|
        db.srem(index, id)
      end
    end
        
    key[:_indices].del
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
# We do this 12 times to ensure we've got 12 entries in each test_holding1
# available to move on to test_holding2 in the real test
puts "Receiving stock from null"
StockEntity.all.each do |test_stke|
  12.times do
    test_stke.move(null_target, test_stke.holding(:test_holding1), 10, 2.00)
  end
end

# Benchmark
puts "Commencing benchmark"

Benchmark.bmbm do |x|
  x.report("no pipelining") do
    StockEntity.all.each do |test_stke|
      test_stke.move(test_stke.holding(:test_holding1), test_stke.holding(:test_holding2), 10, 2.00)
    end
  end

  x.report("add_to_indices pipelining") do
    class Ohm::Model
      alias_method :add_to_indices, :add_to_indices_pipelined
    end

    StockEntity.all.each do |test_stke|
      test_stke.move(test_stke.holding(:test_holding1), test_stke.holding(:test_holding2), 10, 2.00)
    end

    class Ohm::Model
      alias_method :add_to_indices, :add_to_indices_original
    end
  end

  x.report("delete_from_indices pipelining") do
    class Ohm::Model
      alias_method :delete_from_indices, :delete_from_indices_pipelined
    end

    StockEntity.all.each do |test_stke|
      test_stke.move(test_stke.holding(:test_holding1), test_stke.holding(:test_holding2), 10, 2.00)
    end

    class Ohm::Model
      alias_method :delete_from_indices, :delete_from_indices_original
    end
  end

  x.report("no pipelining 2nd run") do
    StockEntity.all.each do |test_stke|
      test_stke.move(test_stke.holding(:test_holding1), test_stke.holding(:test_holding2), 10, 2.00)
    end
  end

  x.report("add and delete indices pipelining") do
    class Ohm::Model
      alias_method :add_to_indices, :add_to_indices_pipelined
      alias_method :delete_from_indices, :delete_from_indices_pipelined
    end

    StockEntity.all.each do |test_stke|
      test_stke.move(test_stke.holding(:test_holding1), test_stke.holding(:test_holding2), 10, 2.00)
    end

    class Ohm::Model
      alias_method :add_to_indices, :add_to_indices_original
      alias_method :delete_from_indices, :delete_from_indices_original
    end
  end
end

    