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
    assert !@subscription.reload.user.nil?, "the previously associated object has not been disassociated yet"
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
  def setup
    @user = users(:bob)
    @subscription = subscriptions(:bob_is_free)
  end
  
  def test_updating_the_subscription_user
    @subscription.user_params = {
      "1" => {
        :id => @user.id,
        :name => "William"
      }
    }
    assert !@subscription.user.new_record?, "the association was not rebuilt"
    assert_equal "William", @subscription.user.name, "the existing subscription's name has changed"
    assert_equal "Bob", @user.reload.name, "the name change has not been saved"
  end
  
  def test_assigning_a_replacement_user
    @subscription.user_params = {
      "1" => {
        :name => "William"
      }
    }
    assert @subscription.user.new_record?, "the association is a new object"
    assert_equal "William", @subscription.user.name, "the new record has the specified name"
    assert !@subscription.reload.user.nil?, "the previously associated object has not been disassociated yet"
  end
  
  def test_assigning_a_removed_user
    @subscription.user_params = {
      "1" => {
        :id => @user.id,
        :name => "William",
        :_delete => "1"
      }
    }
    assert @subscription.user._delete, "the association is marked for deletion"
    assert_nothing_raised("the associated object has not been deleted yet") do @user.reload end
    assert_equal "Bob", @subscription.user.name, "the association attribute did not update"
  end
end

class NestedAssignmentHasManyTest < ActiveSupport::TestCase
  def setup
    @service = services(:free)
    @subscription = subscriptions(:bob_is_free)
  end
  
  def test_adding_a_subscription
    @service.subscriptions_params = {
      "1" => {
        :name => "Foo"
      }
    }
    assert @service.subscriptions.any?{|s| s.new_record?}, "a new record is added"
    assert_equal "Foo", @service.subscriptions.detect{|s| s.new_record?}.name, "the new record has the specified attribute value"
  end
  
  def test_missing_subscriptions_do_not_delete
    @service.subscriptions_params = {
      "1" => {:name => "Foo"}
    }
    assert @service.subscriptions.any?{|s| s == @subscription}, "existing records remain in the collection"
  end
  
  def test_updating_a_subscription
    @service.subscriptions_params = {
      "1" => {
        :id => @subscription.id,
        :name => "Foo"
      }
    }
    assert !@service.subscriptions.any?{|s| s.new_record?}, "no new record is created"
    assert_equal "Foo", @service.subscriptions.detect{|s| s == @subscription}.name, "the name is updated"
    assert_equal "Bob/Free", @subscription.reload.name, "the name is not saved"
  end
  
  def test_removing_a_subscription
    @service.subscriptions_params = {
      "1" => {
        :id => @subscription.id,
        :name => "Foo",
        :_delete => "1"
      }
    }
    assert @service.subscriptions.detect{|s| s == @subscription}._delete, "the associated record is marked for deletion"
    assert_equal "Bob/Free", @service.subscriptions.detect{|s| s == @subscription}.name, "the association attribute did not update"
  end
end

class NestedAssignmentHasAndBelongsToManyTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @role = roles(:cook)
  end
  
  def test_adding_a_role
    @user.roles_params = {
      "1" => {
        :name => "Foo"
      }
    }
    assert @user.roles.any?{|r| r.new_record?}, "a new record is added"
    assert_equal "Foo", @user.roles.detect{|r| r.new_record?}.name, "the new record has the specified attribute value"
  end
  
  def test_missing_roles_do_not_delete
    @user.roles_params = {
      "1" => {:name => "Foo"}
    }
    assert @user.roles.any?{|r| r == @role}, "existing records remain in the collection"
  end
  
  def test_updating_a_role
    @user.roles_params = {
      "1" => {
        :id => @role.id,
        :name => "Foo"
      }
    }
    assert !@user.roles.any?{|s| s.new_record?}, "no new record is created"
    assert_equal "Foo", @user.roles.detect{|s| s == @role}.name, "the name is updated"
    assert_equal "Cook", @role.reload.name, "the name is not saved"
  end
  
  def test_removing_a_role
    @user.roles_params = {
      "1" => {
        :id => @role.id,
        :name => "Foo",
        :_delete => "1"
      }
    }
    assert @user.roles.detect{|s| s == @role}._delete, "the associated record is marked for deletion"
    assert_equal "Cook", @user.roles.detect{|s| s == @role}.name, "the association attribute did not update"
  end
end

class NestedAssignmentHasManyThroughTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @service = services(:free)
  end
  
  def test_adding_a_service
    @user.services_params = {
      "1" => {
        :name => "Foo"
      }
    }
    assert @user.services.any?{|r| r.new_record?}, "a new record is added"
    assert_equal "Foo", @user.services.detect{|r| r.new_record?}.name, "the new record has the specified attribute value"
  end
  
  def test_missing_services_do_not_delete
    @user.services_params = {
      "1" => {:name => "Foo"}
    }
    assert @user.services.any?{|r| r == @service}, "existing records remain in the collection"
  end
  
  def test_updating_a_service
    @user.services_params = {
      "1" => {
        :id => @service.id,
        :name => "Foo"
      }
    }
    assert !@user.services.any?{|s| s.new_record?}, "no new record is created"
    assert_equal "Foo", @user.services.detect{|s| s == @service}.name, "the name is updated"
    assert_equal "Free", @service.reload.name, "the name is not saved"
  end
  
  def test_removing_a_service
    @user.services_params = {
      "1" => {
        :id => @service.id,
        :name => "Foo",
        :_delete => "1"
      }
    }
    assert @user.services.detect{|s| s == @service}._delete, "the associated record is marked for deletion"
    assert_equal "Free", @user.services.detect{|s| s == @service}.name, "the association attribute did not update"
  end
end

class NestedAssignmentHelperTest < ActiveSupport::TestCase
  def test_association_names
    assert_equal [:address, :roles, :services, :subscription], User.association_names.sort_by(&:to_s)
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
