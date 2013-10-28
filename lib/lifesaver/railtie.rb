module Lifesaver
  class Railtie < Rails::Railtie
    initializer 'lifesaver.model' do
      ActiveSupport.on_load :active_record do
        include Model::IndexingQueuing
        include Model::IndexingNotification
      end
    end
  end
end