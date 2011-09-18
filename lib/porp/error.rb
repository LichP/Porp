#!/usr/bin/env ruby
#
# Porp - The Prototype Open Retail Platform
#
# Copyright (c) 2010 Phil Stewart
#
# License: MIT (see LICENSE file)

module Orp

=begin
Error exception classes are defined here
=end

  # All porp errors are of type Orp::Error
  class Error < RuntimeError; end

  # Stock creation errors
  class StockCreationError < Error; end
  class NoHoldersSpecified  < StockCreationError; end
  class NoStatusesSpecified < StockCreationError; end

  # Movement errors  
  class MovementError < Error; end
  class MovementInvalidTarget     < MovementError; end
  class MovementValidationError   < MovementError; end
  class MovementIssueError        < MovementError; end
  class MovementRcptError         < MovementError; end  
  class MovementReverseIssueError < MovementError; end  
end
  
