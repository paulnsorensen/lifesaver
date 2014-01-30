require 'resque-loner'
require 'lifesaver/version'
require 'lifesaver/config'
require 'lifesaver/serialized_model'
require 'lifesaver/indexing/model_additions'
require 'lifesaver/indexing/enqueuer'
require 'lifesaver/indexing/indexer'
require 'lifesaver/notification/dependent_associations'
require 'lifesaver/notification/notifiable_associations'
require 'lifesaver/notification/model_additions'
require 'lifesaver/notification/eager_loader'
require 'lifesaver/notification/traversal_queue'
require 'lifesaver/notification/indexing_graph'
require 'lifesaver/notification/enqueuer'
require 'lifesaver/index_worker'
require 'lifesaver/visitor_worker'
require 'lifesaver/railtie' if defined? Rails

module Lifesaver
  extend self

  @@suppress_indexing = false

  def suppress_indexing
    @@suppress_indexing = true
  end

  def unsuppress_indexing
    @@suppress_indexing = false
  end

  def indexing_suppressed?
    @@suppress_indexing
  end

  def config=(options = {})
    @config = Config.new(options)
  end

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end
end
