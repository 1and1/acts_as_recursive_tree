# frozen_string_literal: true

require 'fileutils'

database_folder           = "#{File.dirname(__FILE__)}/../db"
database_adapter          = 'sqlite'

# Logger setup
ActiveRecord::Base.logger = nil

ActiveRecord::Migration.verbose = false

ActiveRecord::Base.configurations = YAML.safe_load(File.read("#{database_folder}/database.yml"))

if ActiveRecord.version >= Gem::Version.new('6.1.0')
  config = ActiveRecord::Base.configurations.configs_for env_name: database_adapter, name: 'primary'
  database = config.database
else
  config = ActiveRecord::Base.configurations[database_adapter]
  database = config['database']
end

# remove database if present
FileUtils.rm database, force: true

ActiveRecord::Base.establish_connection(database_adapter.to_sym)
ActiveRecord::Base.establish_connection(config)

# require schemata and models
require_relative 'schema'
require_relative 'models'
