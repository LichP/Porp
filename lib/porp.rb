#!/usr/bin/env ruby
#
# Porp - The Prototype open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'rubygems'
require 'redis'

# Make redis available everywhere
def redis
 $redis ||= Redis.new
end

# This is the top level class of Porp. It provides configuration and handles
# the database key namespace.
class Porp
  @@options = {
    :ns_app        => 'porp',
    :ns_site       => 'mysite',
    :ns_deployment => 'dev'
  }

  def self.options
    @@options
  end

  def self.set_options(options = {})
    @@options.merge!(options)
  end

  # Namespace for all redis keys. By default compiles the string once only,
  # but can be forced to rebuild if necessary
  def self.ns(params = {:force_rebuild => false})
    @@ns = compile_ns_string if params[:force_rebuild]
    @@ns ||= compile_ns_string
  end

  def self.compile_ns_string
    "#{options[:ns_app]}:#{options[:ns_site]}:#{options[:ns_deployment]}"
  end

  # List all keys in the current namespace
  def self.ns_keys
    [redis.keys("#{ns}*")].flatten
  end  

  # Deletes all keys in the current namespace. This is intended primarily
  # for unit tests. The namespace string is explicitly rebuilt to ensure
  # any changes to the namespace options are picked up
  def self.purge_current_namespace!
    ns(:force_rebuild => :true)
    ns_keys.each { |key| redis.del(key) } unless ns_keys.nil?
  end
end

require 'porp/orpmodel'
require 'porp/stockentity'
require 'porp/saleentity'
