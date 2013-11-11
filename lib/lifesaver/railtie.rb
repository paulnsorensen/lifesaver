module Lifesaver
  class Railtie < Rails::Railtie
    initializer 'lifesaver.model' do
      ActiveSupport.on_load :active_record do
        include Indexing::ModelAdditions
        include Notification::ModelAdditions
      end
    end
  end
end
