#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT (see LICENSE file)

class Stock
=begin
The Status class represents different states can hold, such as 'in stock',
'on order', etc
=end
  class Status < Orp::Model
    include Ohm::FindAdditions

    attribute  :name
    index      :name
    attribute  :description
    collection :holdings, Holding, :status

    def validate
      assert_unique :name
    end

    # Ensure that a status object corresponding to each passed string or symbol
    # exists, creating it if not
    #
    # @param statuses Collection of strings or symbols corresponding to names
    #   of statuses
    def self.ensure_extant(statuses)
      statuses = [statuses] unless statuses.kind_of?(Array)
      statuses.each {|name| find_or_create(name: name.to_s)}
    end
  end
end
