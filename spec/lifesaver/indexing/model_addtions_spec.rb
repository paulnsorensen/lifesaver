require 'spec_helper'

describe Lifesaver::Indexing::ModelAdditions do
  let(:post) { Post.new(title: "Test Post") }

  describe ".enqueues_indexing" do
    before do
      post.stub(:enqueue_indexing)
    end

    it "calls enqueue_indexing on save" do
      expect(post).to receive(:enqueue_indexing)
      post.save!
    end

    it "calls enqueue_indexing on destroy" do
      expect(post).to receive(:enqueue_indexing)
      post.destroy
    end
  end

  describe "#indexing_suppressed?" do
    it "is false by default" do
      expect(post.send(:suppress_indexing?)).to eql(false)
    end

    it "is true if overridden locally" do
      Lifesaver.suppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(true)
    end

    it "is false if override is cancelled" do
      Lifesaver.unsuppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(false)
    end

    it "is true if set individually" do
      post.suppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(true)
    end

    it "is false if unset individually" do
      post.unsuppress_indexing
      expect(post.send(:suppress_indexing?)).to eql(false)
    end
  end
end