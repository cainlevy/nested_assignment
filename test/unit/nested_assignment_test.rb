require File.dirname(__FILE__) + '/../test_helper'

require 'ruby-debug'

class NestedAssignmentHasOneTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @subscription = subscriptions(:bob_is_free)
  end
  
  def test_updating_a_subscription
    @user.subscription_params = {
      "1" => {
        :id => @subscription.id,
        :name => "Bobtastic"
      }
    }
    assert !@user.subscription.new_record?, "the association was not rebuilt"
    assert_equal "Bobtastic", @user.subscription.name, "the existing subscription's name has changed"
    assert_equal "Bob/Free", @subscription.reload.name, "the name change has not been saved"
  end
  
  def test_assigning_a_replacement_subscription
    @user.subscription_params = {
      "1" => {
        :name => "Bobtastic"
      }
    }
    assert @user.subscription.new_record?, "the association is a new object"
    assert_equal "Bobtastic", @user.subscription.name, "the new record has the specified name"
    assert !@subscription.reload.user_id.nil?, "the previously associated object has not been disassociated yet"
  end
  
  def test_assigning_a_removed_subscription
    @user.subscription_params = {
      "1" => {
        :id => @subscription.id,
        :name => "Bobtastic",
        :_delete => "1"
      }
    }
    assert @user.subscription._delete, "the association is marked for deletion"
    assert_nothing_raised("the associated object has not been deleted yet") do @subscription.reload end
    assert_equal "Bob/Free", @user.subscription.name, "the association attribute did not update"
  end

end

class NestedAssignmentBelongsToTest < ActiveSupport::TestCase
end

class NestedAssignmentHasManyTest < ActiveSupport::TestCase
end

class NestedAssignmentHasAndBelongsToManyTest < ActiveSupport::TestCase
end

class NestedAssignmentHasManyThroughTest < ActiveSupport::TestCase
end

class NestedAssignmentHelperTest < ActiveSupport::TestCase
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
