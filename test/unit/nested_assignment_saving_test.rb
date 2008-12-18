require File.dirname(__FILE__) + '/../test_helper'

class NestedAssignmentSavingTest < ActiveSupport::TestCase
  def test_saving_with_new_associated_records
    @user = users(:bob)
    @user.tasks.build(:name => "research")
    assert_difference "Task.count" do
      @user.save
    end
  end
  
  def test_saving_with_modified_existing_associated_records
    @user = users(:bob)
    @user.tasks[0].name = "research"
    assert_no_difference "Task.count" do
      @user.save
    end
    assert_equal "research", @user.reload.tasks[0].name
  end
  
  def test_saving_with_existing_associated_records_marked_for_deletion
    @user = users(:bob)
    @user.tasks[0]._delete = true
    assert_difference "Task.count", -1 do
      @user.save
    end
  end
  
  def test_saving_with_modified_existing_deeply_associated_records
    @user = users(:bob)
    @user.tasks[0].tags[0].name = "difficult"
    assert_no_difference "Task.count" do
      assert_no_difference "Tag.count" do
        @user.save
      end
    end
    assert_equal "difficult", @user.reload.tasks[0].tags[0].name
  end
  
  def test_saving!
    @user = users(:bob)
    @user.tasks[0].name = "research"
    @user.save!
    assert_equal "research", @user.reload.tasks[0].name
  end
  
  class UserWithEvent < User
    after_save do |user|
      PluginTestModels::Event.create(:entity => user)
    end
  end
  
  def test_saving_a_modified_record_that_spawns_an_associated_record
    @user = UserWithEvent.find(:first)
    @user.name = "william"
    assert_difference "Event.count", 1 do
      assert_nothing_raised do
        @user.save
      end
    end
    @user.reload
    assert_equal "william", @user.name
  end
  
  class UserWithResave < User
    after_create do |user|
      user.update_attribute(:name, "#{user.name} (verified)")
    end
  end
  
  def test_saving_a_new_record_with_a_single_resave
    @user = UserWithResave.new
    @user.name = "george"
    @user.save
    assert_equal "george (verified)", @user.reload.name
  end
end
