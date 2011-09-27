#!/usr/bin/env ruby1.9.1

require 'pry'
#require 'ruby-prof'
require 'fileutils'

#$: << FileUtils.pwd.sub(/irb$/, 'lib')

require File.join(File.dirname(__FILE__), '..', 'lib', 'porp')

binding.pry

session = Orp::Session.load_file("../config/local.yaml")

binding.pry

