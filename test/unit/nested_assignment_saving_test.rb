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
  
  def test_saving_with_recursive_references
    # This recursive situation is a little contrived. A more likely example would be
    # a new associated record that refers back to the first. For example, suppose you
    # store events, and after the user modifies his name you wish to store the fact.
    # You may do something like `Event.create(:user => self, :change => 'name')`. This
    # would create a recursive reference such as here.
    @user = users(:bob)
    @user.name = "william"
    @user.tasks[0].name = "research"
    @user.tasks[0].user = @user
    assert_nothing_raised do
      @user.save
    end
    @user.reload
    assert_equal "william", @user.name
    assert_equal "research", @user.tasks[0].name
  end
  
  def test_saving!
    @user = users(:bob)
    @user.tasks[0].name = "research"
    @user.save!
    assert_equal "research", @user.reload.tasks[0].name
  end
end
