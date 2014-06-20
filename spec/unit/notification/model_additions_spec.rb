require 'spec_helper'

describe Lifesaver::Notification::ModelAdditions do
  let(:post) { Post.create!(title: 'Test', content: 'Lorem', tags: %w(tests)) }
  let(:affiliate) { Affiliate.create(name: 'Some place') }
  let(:author) { Author.create!(name: 'Paul Sorensen', affiliate: affiliate) }
  let(:authorship) { Authorship.create!(post: post, author: author) }
  before do
    post.reload
    author.reload
    authorship.reload
  end

  describe '.notifies_for_indexing' do
    before do
      allow(post).to receive(:update_associations)
    end

    it 'calls update_associations on save' do
      expect(post).to receive(:update_associations)

      post.save!
    end

    it 'calls update_associations on destroy' do
      expect(post).to receive(:update_associations)

      post.destroy
    end
  end

  describe '.load_with_notifiable_associations' do
    it 'returns the correct eager-loaded models' do
      model = Authorship.load_with_notifiable_associations(authorship.id).first

      expect(model.association(:author).loaded?).to be_truthy
    end
  end

  describe '#associations_to_notify' do
    it 'returns the correct models' do
      expect(author.associations_to_notify).to eql([authorship])
    end
  end

  describe '#needs_to_notify?' do
    it 'is false if there are no notifiable associations' do
      expect(post.needs_to_notify?).to be_falsey
    end

    it 'is true if there are notifiable associations' do
      expect(author.needs_to_notify?).to be_truthy
    end
  end

  describe '#models_for_association' do
    it 'should return an array of models for multiple association' do
      models = post.models_for_association(:authorships)

      expect(models.first).to be_a_kind_of(Authorship)
    end

    it 'should return an array of one model for a singular association' do
      models = author.models_for_association(:affiliate)

      expect(models.first).to be_a_kind_of(Affiliate)
    end
  end
end
