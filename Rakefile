require 'rake/rdoctask'
require 'rubygems'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'porp'

task :test do
  require 'cutest'
  Cutest.run(Dir["test/*"])
end

task :default => :test

Rake::RDocTask.new(:rdoc) do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
end
