require 'spec_helper'

class DummyClass < ActiveRecord::Base
  has_many :foo, dependent: :destroy
  has_one :bar
  belongs_to :baz, dependent: :delete
end

describe Lifesaver::Notification::DependentAssociations do
  let(:dependent_associations) do
    Lifesaver::Notification::DependentAssociations.new(DummyClass)
  end

  describe '#fetch' do
    it 'returns association keys that are dependent' do
      expect(dependent_associations.fetch).to eql([:foo, :baz])
    end
  end
end
