# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: [:spec]

desc 'Deletes temporary files'
task :clean_tmp_files do
  %w[db.log test.sqlite3].each do |file|
    File.delete(file) if File.exist?(file)
  end
end
