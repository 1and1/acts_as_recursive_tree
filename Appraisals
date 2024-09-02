# frozen_string_literal: true

appraise 'ar-70' do
  gem 'activerecord', '~> 7.0'
  gem 'activesupport', '~> 7.0'
end

appraise 'ar-71' do
  gem 'activerecord', '~> 7.1'
  gem 'activesupport', '~> 7.1'
end

appraise 'ar-72' do
  gem 'activerecord', '~> 7.2'
  gem 'activesupport', '~> 7.2'
end

appraise 'ar-next' do
  git 'https://github.com/rails/rails.git', branch: 'main' do
    gem 'activerecord'
    gem 'activesupport'
  end
end
