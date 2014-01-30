require 'pry'
require 'database_cleaner'

if ENV['RUN_COVERALLS'] && RUBY_ENGINE != 'rbx'
  require 'coveralls'
  Coveralls.wear!
end

require 'lifesaver'

require 'support/active_record'
require 'support/test_models'
require 'support/tire_helper'

Resque.inline = true
Tire::Model::Search.index_prefix 'lifesaver_test'

Model = Struct.new(:id)

RSpec.configure do |config|
  config.include TireHelper

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  DatabaseCleaner.strategy = :truncation

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
