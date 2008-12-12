ActiveRecord::Schema.define(:version => 1) do

  create_table :users, :force => true do |t|
    t.column :manager_id, :integer
    t.column :name, :string
  end

  create_table :avatars, :force => true do |t|
    t.column :user_id, :integer
    t.column :name, :string
  end

  create_table :managers, :force => true do |t|
    t.column :name, :string
  end

  create_table :tasks, :force => true do |t|
    t.column :user_id, :integer
    t.column :name, :string
  end

  create_table :tags, :force => true do |t|
    t.column :task_id, :integer
    t.column :name, :string
  end

  create_table :groups, :force => true do |t|
    t.column :user_id, :integer
    t.column :name, :string
  end
  
  create_table :groups_users, :force => true, :id => false do |t|
    t.column :group_id, :integer
    t.column :user_id, :integer
  end

end
