# A set of classes design to offer not only every association, but every pair of associations.
# For example, there's a has_one paired with a normal belongs_to, and another has_one paired with a polymorphic belongs_to.
# To use, mix the PluginTestModels module into the TestCase
module PluginTestModels
  def self.included(base)
    base.set_fixture_class({
      :addresses => PluginTestModels::Address,
      :users => PluginTestModels::User,
      :services => PluginTestModels::Service,
      :subscriptions => PluginTestModels::Subscription,
      :roles => PluginTestModels::Role
    })
  end

  class Address < ActiveRecord::Base
    belongs_to :addressable, :polymorphic => true
    
    validates_presence_of :name
  end

  class User < ActiveRecord::Base
    has_and_belongs_to_many :roles
    has_one :subscription
    has_one :address, :as => :addressable
    has_many :services, :through => :subscription
    
    accessible_associations :subscription, :roles, :services
    
    validates_presence_of :name
  end

  class Service < ActiveRecord::Base
    has_many :subscriptions
    has_many :users, :through => :subscriptions
    
    accessible_associations :subscriptions
    
    validates_presence_of :name
  end

  class Subscription < ActiveRecord::Base
    belongs_to :service
    belongs_to :user
    
    accessible_associations :user
    
    validates_presence_of :name
  end

  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users
    
    validates_presence_of :name
  end
end
