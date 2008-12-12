ENV["RAILS_ENV"] = "test"

# load the support libraries
require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_record/fixtures'

# load the code-to-be-tested
ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__) + '/../lib/'
require File.dirname(__FILE__) + '/../init'

# establish the database connection
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
ActiveRecord::Base.establish_connection('nested_assignment_test')

# capture the logging
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/test.log")

# load the schema ... silently
ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/db/schema.rb")

# load the ActiveRecord models
require File.dirname(__FILE__) + '/db/models'

# configure the TestCase settings
class ActiveSupport::TestCase
  include PluginTestModels

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'

  fixtures :all
end

