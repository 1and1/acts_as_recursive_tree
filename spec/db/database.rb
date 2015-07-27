database_folder           = "#{File.dirname(__FILE__)}/../db"
database_adapter          = 'sqlite'

# Logger setup
log                       = Logger.new('db.log')
log.sev_threshold         = Logger::DEBUG
ActiveRecord::Base.logger = log

ActiveRecord::Migration.verbose      = false
# ActiveRecord::Base.table_name_prefix = ENV['DB_PREFIX'].to_s
# ActiveRecord::Base.table_name_suffix = ENV['DB_SUFFIX'].to_s

ActiveRecord::Base.configurations = YAML::load(ERB.new(IO.read("#{database_folder}/database.yml")).result)

config = ActiveRecord::Base.configurations[database_adapter]

# remove database if present
FileUtils.rm config['database'], force: true

ActiveRecord::Base.establish_connection(database_adapter.to_sym)
ActiveRecord::Base.establish_connection(config)
#Foreigner.load

require_relative 'schema'
require_relative 'models'

