#!/usr/bin/env ruby1.9.1

#require 'pry'
require 'ruby-prof'
require 'fileutils'

$: << FileUtils.pwd.sub(/irb$/, 'lib')

require 'porp'

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
printer.print(STDOUT, {})
    