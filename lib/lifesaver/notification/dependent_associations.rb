module Lifesaver
  module Notification
    class DependentAssociations
      def initialize(klass)
        @class = klass
      end

      def fetch
        @dependent_associations ||= populate
      end

      private

      def populate
        dependent_associations = []
        @class.reflect_on_all_associations.each do |association|
          if association.options[:dependent].present?
            dependent_associations << association.name.to_sym
          end
        end
        dependent_associations
      end
    end
  end
end
