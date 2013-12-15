require 'spec_helper'

describe Lifesaver::Notification::NotifiableAssociations do
  let(:notifiable_associations) do
    Lifesaver::Notification::NotifiableAssociations.new
  end

  describe '#populate' do
    it 'mirrors arguments for both keys' do
      notifiable_associations.populate(:foo)
      association_keys = notifiable_associations.send(:association_keys)

      expect(association_keys.on_change).to eql(association_keys.on_notify)
    end

    it 'accepts arguments that are singular' do
      notifiable_associations.populate(:foo)
      association_keys = notifiable_associations.send(:association_keys)

      expect(association_keys.on_change).to eql([:foo])
    end

    it 'accepts arguments that are arrays' do
      notifiable_associations.populate([:foo, :bar])
      association_keys = notifiable_associations.send(:association_keys)

      expect(association_keys.on_notify).to eql([:foo, :bar])
    end

    it 'accepts an options hash for :only_on_notify' do
      notifiable_associations.populate(:foo, only_on_notify: [:baz])
      association_keys = notifiable_associations.send(:association_keys)

      expect(association_keys.on_notify).to eql([:foo, :baz])
    end

    it 'accepts an options hash for :only_on_change' do
      notifiable_associations.populate(:foo, only_on_change: [:baz])
      association_keys = notifiable_associations.send(:association_keys)

      expect(association_keys.on_change).to eql([:foo, :baz])
    end
  end

  describe '#any_to_notify?' do
    it 'is true if the :on_notify array is not empty' do
      notifiable_associations.populate([], only_on_notify: [:baz])

      expect(notifiable_associations.any_to_notify?).to be_true
    end

    it 'is false if the :on_notify array is empty' do
      notifiable_associations.populate([], only_on_change: [:baz])

      expect(notifiable_associations.any_to_notify?).to be_false
    end
  end

  describe '#on_notify' do
    it 'reads the :on_notify key' do
      notifiable_associations.populate([], only_on_notify: [:baz])
      keys = notifiable_associations.send(:association_keys)

      expect(notifiable_associations.on_notify).to eql(keys.on_notify)
    end
  end
  describe '#on_change' do
    it 'reads the :on_change key' do
      notifiable_associations.populate([], only_on_change: [:baz])
      keys = notifiable_associations.send(:association_keys)

      expect(notifiable_associations.on_change).to eql(keys.on_change)
    end
  end
end
