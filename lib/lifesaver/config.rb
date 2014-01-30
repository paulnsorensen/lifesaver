module Lifesaver
  # A container for configuration parameters
  class Config
    attr_accessor :notification_queue, :indexing_queue

    def initialize(options = {})
      @notification_queue = :lifesaver_notification
      @indexing_queue = :lifesaver_indexing

      options.each do |key, value|
        public_send("#{key}=", value)
      end
    end
  end
end
