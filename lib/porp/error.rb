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

  # Movement errors  
  class MovementError < Error; end
  class MovementValidationError   < MovementError; end
  class MovementIssueError        < MovementError; end
  class MovementRcptError         < MovementError; end  
  class MovementReverseIssueError < MovementError; end  
end
  
