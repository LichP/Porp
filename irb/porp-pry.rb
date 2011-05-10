#!/usr/bin/env ruby1.9.1

require 'pry'
require 'fileutils'

$: << FileUtils.pwd.sub(/irb$/, 'lib')

require 'porp'

# Create a stock entity
test_stke = StockEntity.create(description: "Test stock entity")

# Move the stock entity from the misc target to the misc target
source_target = MiscTarget.acquire
dest_target = NullTarget.acquire
binding.pry
test_stke.move(source_target, dest_target, 1, 2.00)

binding.pry
