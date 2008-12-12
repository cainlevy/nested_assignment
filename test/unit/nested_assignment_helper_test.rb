require File.dirname(__FILE__) + '/../test_helper'

class NestedAssignmentHelperTest < ActiveSupport::TestCase
  def test_association_names
    assert_equal [:avatar, :groups, :manager, :tags, :tasks], User.association_names.sort_by(&:to_s)
  end

  def test_instantiated_associated_does_not_load_associations
    ActiveRecord::Associations::AssociationProxy.any_instance.expects(:loaded).never
    user = User.find(:first)
    assert_equal [], user.send(:instantiated_associated)
  end
  
  def test_instantiated_associated_retrieves_loaded_associations
    user = User.find(:first)
    group = user.groups.build(:name => "designers")
    assert_equal [group], user.send(:instantiated_associated), "only one group is instantiated"
    assert_equal 2, user.groups.length, "though there were more associated groups"
  end
  
  def test_instantiated_associated_returns_arrays_for_singular_association
    user = User.find(:first)
    assert !user.avatar.nil?
    assert_equal [user.avatar], user.send(:instantiated_associated)
  end
  
  def test_instantiated_associated_returns_arrays_for_plural_association
    user = User.find(:first)
    assert !user.groups.empty?
    assert_equal user.groups, user.send(:instantiated_associated)
  end
end
