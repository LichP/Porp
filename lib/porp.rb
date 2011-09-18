#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010-2011 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'rubygems'
require 'hiredis'
require 'redis/connection/hiredis'
require 'ohm'
require 'ohm/contrib'

require File.join(File.dirname(__FILE__), 'porp', 'error')
require File.join(File.dirname(__FILE__), 'porp', 'structs')
require File.join(File.dirname(__FILE__), 'porp', 'stock')
require File.join(File.dirname(__FILE__), 'porp', 'saleentity')
require File.join(File.dirname(__FILE__), 'porp', 'plu')
