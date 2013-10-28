require 'coveralls'
Coveralls.wear!

require 'lifesaver'

require 'support/active_record'
require 'support/test_models'

Resque.inline = true
Tire::Model::Search.index_prefix "lifesaver_test"


RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end