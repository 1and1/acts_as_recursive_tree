require 'bundler/gem_tasks'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task default: [:spec]
rescue LoadError
end

desc 'Deletes temporary files'
task :clean_tmp_files do
  %w( db.log test.sqlite3 ).each do |file|
    File.delete(file) if File.exists?(file)
  end
end
