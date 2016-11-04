database_folder           = "#{File.dirname(__FILE__)}/../db"
database_adapter          = 'sqlite'

# Logger setup
ActiveRecord::Base.logger = nil

ActiveRecord::Migration.verbose = false

ActiveRecord::Base.configurations = YAML::load(File.read("#{database_folder}/database.yml"))

config = ActiveRecord::Base.configurations[database_adapter]

# remove database if present
FileUtils.rm config['database'], force: true

ActiveRecord::Base.establish_connection(database_adapter.to_sym)
ActiveRecord::Base.establish_connection(config)

# require schemata and models
require_relative 'schema'
require_relative 'models'

