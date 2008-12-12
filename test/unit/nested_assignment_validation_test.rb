require File.dirname(__FILE__) + '/../test_helper'

require 'ruby-debug'

class NestedAssignmentValidationTest < ActiveSupport::TestCase
  def test_an_invalid_new_associated_record
    @user = users(:bob)
    @user.tasks.build(:name => nil)
    assert !@user.valid?
  end
  
  def test_an_invalid_existing_associated_record
    @user = users(:bob)
    @user.tasks[0].name = nil
    assert !@user.valid?
  end
  
  def test_an_invalid_deeply_associated_record
    @user = users(:bob)
    @user.tasks[0].tags[0].name = nil
    assert !@user.valid?
    assert @user.tasks[0].errors.full_messages.empty?
    assert @user.tasks[0].tags[0].errors.on(:name)
  end
  
  def test_multiple_invalid_associated_records
    @user = users(:bob)
    @user.tasks[0].name = nil
    @user.tasks.build(:name => nil)
    assert !@user.valid?
    assert @user.tasks[0].errors.on(:name)
    assert @user.tasks[1].errors.on(:name)
  end
end
