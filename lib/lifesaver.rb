require 'resque-loner'
require "lifesaver/version"
require "lifesaver/index_graph"
require "lifesaver/model_additions"
require "lifesaver/index_worker"
require "lifesaver/visitor_worker"
require "lifesaver/railtie" if defined? Rails

module Lifesaver
  @@suppress_indexing = false

  def self.suppress_indexing
    @@suppress_indexing = true
  end

  def self.unsuppress_indexing
    @@suppress_indexing = false
  end

  def self.indexing_suppressed?
    @@suppress_indexing
  end
end