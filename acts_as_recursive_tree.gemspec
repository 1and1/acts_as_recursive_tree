# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_recursive_tree/version'

Gem::Specification.new do |spec|
  spec.name                  = 'acts_as_recursive_tree'
  spec.version               = ActsAsRecursiveTree::VERSION
  spec.authors               = ['Wolfgang Wedelich-John', 'Willem Mulder']
  spec.email                 = %w[wolfgang.wedelich@ionos.com 14mRh4X0r@gmail.com]
  spec.summary               = 'Drop in replacement for acts_as_tree but using recursive queries'
  spec.description           = '
  This is a ruby gem that provides drop in replacement for acts_as_tree but makes use of SQL recursive statement. Be sure to have a DBMS that supports recursive queries when using this gem (e.g. PostgreSQL or SQLite). '
  spec.homepage              = 'https://github.com/1and1/acts_as_recursive_tree'
  spec.license               = 'MIT'
  spec.metadata              = {
    'bug_tracker_uri' => 'https://github.com/1and1/acts_as_recursive_tree/issues',
    'changelog_uri' => 'https://github.com/1and1/acts_as_recursive_tree/blob/main/CHANGELOG.md'
  }
  spec.required_ruby_version = '>= 3.1.0'
  spec.files                 = `git ls-files -z`.split("\x0")
  spec.require_paths         = ['lib']

  spec.add_dependency 'activerecord', '>= 7.0.0', '< 8'
  spec.add_dependency 'activesupport', '>= 7.0.0', '< 8'
  spec.add_dependency 'zeitwerk', '>= 2.4'

  spec.add_development_dependency 'appraisal', '~> 2.5'
  spec.add_development_dependency 'database_cleaner-active_record', '~> 2.2'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-rails', '>= 6.1'
  spec.add_development_dependency 'rubocop', '~> 1.66.0'
  spec.add_development_dependency 'rubocop-rails', '~> 2.26.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0.4'

  spec.add_development_dependency 'sqlite3', '~> 2.0'
end
