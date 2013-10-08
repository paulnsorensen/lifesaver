require 'lifesaver'

require 'support/active_record'
require 'support/test_models'
ActiveSupport.on_load :active_record do
  include Lifesaver::ModelAdditions
end

Resque.inline = true
Tire::Model::Search.index_prefix "lifesaver_test"


RSpec.configure do |config|
  # config.expect_with :rspec do |c|
  #   c.syntax = :expect
  # end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end