require 'spec_helper'

describe Lifesaver::ModelAdditions do
  Lifesaver.suppress_indexing

  describe ".notifies_for_indexing" do
    after(:each) do 
      Post.send(:notifies_for_indexing, only_on_change: :authorships)
    end
    it "should return a Hash of models for notification on save and notify" do
      Post.send(:notifies_for_indexing, :comments, 
        only_on_change: :authorships,
        only_on_notify: :authors
      )
      exp_hash = { on_change: [], on_notify: [] }
      exp_hash[:on_change] << :comments
      exp_hash[:on_change] << :authorships
      exp_hash[:on_notify] << :comments
      exp_hash[:on_notify] << :authors
      expect(Post.notifiable_associations).to eql(exp_hash)
    end
  end

  describe "#association_models" do
    before(:each) do
      @post = Post.create(title: "Some post")
      affiliate = Affiliate.create(name: "Some place")
      @author = Author.create(name: "Some guy", affiliate_id: affiliate.id)
      Authorship.create(post: @post, author: @author)
    end
    after(:all) do
      Post.destroy_all
      Author.destroy_all
      Authorship.destroy_all
      Affiliate.destroy_all
    end

    it "should return an array of models for multiple association" do
      association = @post.association_models(:authorships)
      expect(association[0]).to be_a_kind_of(Authorship)
    end

    it "should return an array of one model for a singular association" do
      association = @author.association_models(:affiliate)
      expect(association[0]).to be_a_kind_of(Affiliate)
    end
  end
  
  Lifesaver.unsuppress_indexing

  describe "#indexing_suppressed?" do
    let(:post) { Post.new(title: "Test Post") }

    it "should be false by default" do
      expect(post.send(:suppress_indexing?)).to eql(false)
    end

    it "should be true if overridden locally" do
      Lifesaver.suppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(true)
    end

    it "should be false if override is cancelled" do
      Lifesaver.unsuppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(false)
    end

    it "should be true if set individually" do
      post.suppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(true)
    end

    it "should be false if unset individually" do
      post.unsuppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(false)
    end
  end

end