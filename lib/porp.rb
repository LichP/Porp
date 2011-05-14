#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

require 'rubygems'
require 'hiredis'
require 'redis/connection/hiredis'
require 'ohm'
require 'ohm/contrib'

require 'porp/error'
require 'porp/structs'
require 'porp/movementtarget'
require 'porp/stocksourcedest'
require 'porp/stockentity'
require 'porp/stockholding'
require 'porp/saleentity'
require 'porp/stockmovement'
