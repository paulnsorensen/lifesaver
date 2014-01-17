require 'pry'

if RUBY_ENGINE != 'rbx'
  require 'coveralls'
  Coveralls.wear! if ENV['RUN_COVERALLS']
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

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      fail ActiveRecord::Rollback
    end
  end
end
