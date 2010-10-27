$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'rubygems'
require 'porp'

task :test do
  require 'cutest'
  Cutest.run(Dir["test/*"])
end

task :default => :test
