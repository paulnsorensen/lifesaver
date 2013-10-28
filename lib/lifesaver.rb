require 'resque-loner'
require "lifesaver/version"
require "lifesaver/config"
require "lifesaver/marshal"
require "lifesaver/index_graph"
require "lifesaver/model/indexing_queuing"
require "lifesaver/model/indexing_notification"
require "lifesaver/index_worker"
require "lifesaver/visitor_worker"
require "lifesaver/railtie" if defined? Rails

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