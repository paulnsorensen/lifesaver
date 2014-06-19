require 'spec_helper'

describe Lifesaver::Notification::EagerLoader do

  let(:eager_loader) { Lifesaver::Notification::EagerLoader.new }

  describe '#add_model' do

    it 'adds when empty' do
      eager_loader.add_model('Post', 34)
      expected_result = { 'Post' => [34] }

      expect(eager_loader.send(:models_to_load)).to eql(expected_result)
    end

    it 'adds to when other model ids exist' do
      eager_loader.add_model('Post', 34)
      eager_loader.add_model('Post', 38)
      eager_loader.add_model('Article', 3)
      expected_result = { 'Post' => [34, 38], 'Article' => [3] }

      expect(eager_loader.send(:models_to_load)).to eql(expected_result)
    end

    it 'does not add a previously added model' do
      eager_loader.add_model('Post', 38)
      eager_loader.add_model('Post', 38)
      expected_result = { 'Post' => [38] }

      expect(eager_loader.send(:models_to_load)).to eql(expected_result)
    end

  end

  describe '#load' do
    before do
      allow(Post).to receive(:load_with_notifiable_associations).and_return([])
      eager_loader.add_model('Post', 34)
      eager_loader.add_model('Post', 38)
    end

    it 'empties the models_to_load' do
      eager_loader.load

      expect(eager_loader.send(:models_to_load)).to be_empty
    end

    it 'returns an array' do
      expect(eager_loader.load).to eq([])
    end
  end

  describe '#empty?' do
    it 'is true when empty' do
      expect(eager_loader.empty?).to be_truthy
    end

    it 'is false when not empty' do
      eager_loader.add_model('Post', 38)

      expect(eager_loader.empty?).to be_falsey
    end
  end
end
