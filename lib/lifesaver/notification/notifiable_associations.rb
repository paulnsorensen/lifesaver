module Lifesaver
  module Notification
    class NotifiableAssociations
      class AssociationKeys < Struct.new(:on_change, :on_notify); end

      def initialize()
        @association_keys = AssociationKeys.new([], [])
      end

      def populate(associations, options=nil)
        options ||= {}
        add_associations(:on_change, associations)
        add_associations(:on_notify, associations)

        if options[:only_on_change]
          add_associations(:on_change, options[:only_on_change])
        end

        if options[:only_on_notify]
          add_associations(:on_notify, options[:only_on_notify])
        end
      end

      def on_notify
        association_keys.on_notify
      end

      def on_change
        association_keys.on_change
      end

      def any_to_notify?
        !on_notify.empty?
      end

      private

      attr_accessor :association_keys

      def add_associations(key, associations)
        if associations.is_a?(Array)
          association_keys[key] |= associations
        else
          association_keys[key] << associations
        end
      end
    end
  end
end