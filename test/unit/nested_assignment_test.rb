require File.dirname(__FILE__) + '/../test_helper'

require 'ruby-debug'

class NestedAssignmentTest < ActiveSupport::TestCase

  def test_association_names
    assert_equal [:address, :roles, :subscription], User.association_names.sort_by(&:to_s)
  end

  def test_instantiated_associated_does_not_load_associations
    ActiveRecord::Associations::AssociationProxy.any_instance.expects(:loaded).never
    user = User.find(:first)
    assert_equal [], user.send(:instantiated_associated)
  end
  
  def test_instantiated_associated_retrieves_loaded_associations
    user = User.find(:first)
    role = user.roles.build(:name => "Plumber")
    assert_equal [role], user.send(:instantiated_associated), "only one role is instantiated"
    assert_equal 2, user.roles.length, "though there were more associated roles"
  end
  
  def test_instantiated_associated_returns_arrays_for_singular_association
    user = User.find(:first)
    assert !user.address.nil?
    assert_equal [user.address], user.send(:instantiated_associated)
  end
  
  def test_instantiated_associated_returns_arrays_for_plural_association
    user = User.find(:first)
    assert !user.roles.empty?
    assert_equal user.roles, user.send(:instantiated_associated)
  end
  
end
