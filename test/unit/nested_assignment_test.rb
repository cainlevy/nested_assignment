require File.dirname(__FILE__) + '/../test_helper'

class NestedAssignmentTest < ActiveSupport::TestCase
  def test_fixtures
    assert !User.find(:all).empty?
  end
  
  def test_failure
    flunk
  end
end
