module Lifesaver
  class Railtie < Rails::Railtie
    initializer 'lifesaver.model_additions' do
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end
  end
end