module PluginTestModels
  def self.included(base)
    base.set_fixture_class({
      :avatars => PluginTestModels::Avatar,
      :groups => PluginTestModels::Group,
      :managers => PluginTestModels::Manager,
      :tags => PluginTestModels::Tag,
      :tasks => PluginTestModels::Task,
      :users => PluginTestModels::User
    })
  end
  
  class User < ActiveRecord::Base
    has_one                 :avatar
    belongs_to              :manager
    has_many                :tasks
    has_many                :tags, :through => :tasks
    has_and_belongs_to_many :groups
    
    accessible_associations :avatar, :manager, :tasks, :tags, :groups
    
    validates_presence_of :name
  end
  
  class Avatar < ActiveRecord::Base
    belongs_to :user
    
    validates_presence_of :name
  end
  
  class Manager < ActiveRecord::Base
    has_many :users
  
    validates_presence_of :name
  end
  
  class Task < ActiveRecord::Base
    belongs_to :user
    has_many :tags
  
    validates_presence_of :name
  end
  
  class Tag < ActiveRecord::Base
    belongs_to :task
    
    validates_presence_of :name
  end
  
  class Group < ActiveRecord::Base
    has_and_belongs_to_many :users
    
    validates_presence_of :name
  end
  
  class Event < ActiveRecord::Base
    belongs_to :entity, :polymorphic => true
  end
end
