require File.dirname(__FILE__) + '/../test_helper'

class NestedAssignmentHasOneTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @avatar = avatars(:bobs_avatar)
  end
  
  def test_updating_the_avatar
    @user.avatar_params = {
      :id => @avatar.id,
      :name => "Bobtastic"
    }
    assert !@user.avatar.new_record?, "the association was not rebuilt"
    assert_equal "Bobtastic", @user.avatar.name, "the existing associated record's name has changed"
    assert_equal "mugshot", @avatar.reload.name, "the name change has not been saved"
  end
  
  def test_replacing_the_avatar
    @user.avatar_params = {
      :name => "Bobtastic"
    }
    assert @user.avatar.new_record?, "the association is a new object"
    assert_equal "Bobtastic", @user.avatar.name, "the new record has the specified name"
    assert !@avatar.reload.user.nil?, "the previously associated object has not been disassociated yet"
  end
  
  def test_removing_the_avatar
    @user.avatar_params = {
      :id => @avatar.id,
      :name => "Bobtastic",
      :_delete => "1"
    }
    assert @user.avatar._delete, "the association is marked for deletion"
    assert_nothing_raised("the associated object has not been deleted yet") do @avatar.reload end
    assert_equal "mugshot", @user.avatar.name, "the association attribute did not update"
  end
end

class NestedAssignmentBelongsToTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @manager = managers(:sue)
  end
  
  def test_updating_the_manager
    @user.manager_params = {
      :id => @manager.id,
      :name => "Susan"
    }
    assert !@user.manager.new_record?, "the association was not rebuilt"
    assert_equal "Susan", @user.manager.name, "the existing associated record's name has changed"
    assert_equal "Sue", @manager.reload.name, "the name change has not been saved"
  end
  
  def test_replacing_the_manager
    @user.manager_params = {
      :name => "Susan"
    }
    assert @user.manager.new_record?, "the association is a new object"
    assert_equal "Susan", @user.manager.name, "the new record has the specified name"
    assert !@user.reload.manager.nil?, "the previously associated object has not been disassociated yet"
  end
  
  def test_removing_the_manager
    @user.manager_params = {
      :id => @manager.id,
      :name => "Susan",
      :_delete => "1"
    }
    assert @user.manager._delete, "the association is marked for deletion"
    assert_nothing_raised("the associated object has not been deleted yet") do @manager.reload end
    assert_equal "Sue", @user.manager.name, "the association attribute did not update"
  end
end

class NestedAssignmentHasManyTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @task = tasks(:review)
  end
  
  def test_adding_a_task
    @user.tasks_params = {
      "1" => {
        :name => "refactor"
      }
    }
    assert @user.tasks.any?{|s| s.new_record?}, "a new record is added"
    assert_equal "refactor", @user.tasks.detect{|s| s.new_record?}.name, "the new record has the specified attribute value"
  end
  
  def test_missing_tasks_do_not_delete
    @user.tasks_params = {
      "1" => {:name => "refactor"}
    }
    assert @user.tasks.any?{|s| s == @task}, "existing records remain in the collection"
  end
  
  def test_updating_a_task
    @user.tasks_params = {
      "1" => {
        :id => @task.id,
        :name => "refactor"
      }
    }
    assert !@user.tasks.any?{|s| s.new_record?}, "no new record is created"
    assert_equal "refactor", @user.tasks.detect{|s| s == @task}.name, "the name is updated"
    assert_equal "review", @task.reload.name, "the name is not saved"
  end
  
  def test_removing_a_task
    @user.tasks_params = {
      "1" => {
        :id => @task.id,
        :name => "refactor",
        :_delete => "1"
      }
    }
    assert @user.tasks.detect{|s| s == @task}._delete, "the associated record is marked for deletion"
    assert_equal "review", @user.tasks.detect{|s| s == @task}.name, "the association attribute did not update"
  end
end

class NestedAssignmentHasAndBelongsToManyTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @group = groups(:developers)
  end
  
  def test_adding_a_group
    @user.groups_params = {
      "1" => {
        :name => "designers"
      }
    }
    assert @user.groups.any?{|r| r.new_record?}, "a new record is added"
    assert_equal "designers", @user.groups.detect{|r| r.new_record?}.name, "the new record has the specified attribute value"
  end
  
  def test_missing_groups_do_not_delete
    @user.groups_params = {
      "1" => {:name => "designers"}
    }
    assert @user.groups.any?{|r| r == @group}, "existing records remain in the collection"
  end
  
  def test_updating_a_group
    @user.groups_params = {
      "1" => {
        :id => @group.id,
        :name => "engineers"
      }
    }
    assert !@user.groups.any?{|s| s.new_record?}, "no new record is created"
    assert_equal "engineers", @user.groups.detect{|s| s == @group}.name, "the name is updated"
    assert_equal "developers", @group.reload.name, "the name is not saved"
  end
  
  def test_removing_a_group
    @user.groups_params = {
      "1" => {
        :id => @group.id,
        :name => "engineers",
        :_delete => "1"
      }
    }
    assert @user.groups.detect{|s| s == @group}._delete, "the associated record is marked for deletion"
    assert_equal "developers", @user.groups.detect{|s| s == @group}.name, "the association attribute did not update"
  end
end

class NestedAssignmentHasManyThroughTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
    @tag = tags(:challenging)
  end
  
  def test_adding_a_tag
    @user.tags_params = {
      "1" => {
        :name => "easy"
      }
    }
    assert @user.tags.any?{|r| r.new_record?}, "a new record is added"
    assert_equal "easy", @user.tags.detect{|r| r.new_record?}.name, "the new record has the specified attribute value"
  end
  
  def test_missing_tags_do_not_delete
    @user.tags_params = {
      "1" => {:name => "easy"}
    }
    assert @user.tags.any?{|r| r == @tag}, "existing records remain in the collection"
  end
  
  def test_updating_a_tag
    @user.tags_params = {
      "1" => {
        :id => @tag.id,
        :name => "difficult"
      }
    }
    assert !@user.tags.any?{|s| s.new_record?}, "no new record is created"
    assert_equal "difficult", @user.tags.detect{|s| s == @tag}.name, "the name is updated"
    assert_equal "challenging", @tag.reload.name, "the name is not saved"
  end
  
  def test_removing_a_tag
    @user.tags_params = {
      "1" => {
        :id => @tag.id,
        :name => "difficult",
        :_delete => "1"
      }
    }
    assert @user.tags.detect{|s| s == @tag}._delete, "the associated record is marked for deletion"
    assert_equal "challenging", @user.tags.detect{|s| s == @tag}.name, "the association attribute did not update"
  end
end
