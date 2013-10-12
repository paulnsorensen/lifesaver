require 'spec_helper'

describe Lifesaver::IndexGraph do
  Lifesaver.suppress_indexing

  describe "#visited_model_key" do
    it "should return a key when passed an ActiveRecord model" do
      post = Post.create(title: "Some post")
      expect(Lifesaver::IndexGraph.new.send(:visited_model_key, post)).to eql("Post_1")
    end

    it "should return a key when passed a Hash" do
      post = {class: "post", id: "1", status: "notified"}
      expect(Lifesaver::IndexGraph.new.send(:visited_model_key, post)).to eql("Post_1")
    end
  end

  describe "#notified_models" do
    after(:all) do
      Post.destroy_all
      Author.destroy_all
      Authorship.destroy_all
    end
    context "when passed model has changed" do
      before(:each) do
        @post = Post.create(title: "Some post")
        @author = Author.create(name: "Some guy")
        Authorship.create(post: @post, author: @author)
      end
      
      it "should return notified models when passed an ActiveRecord model" do
        models = Lifesaver::IndexGraph.new.send(:notified_models, @post, :on_change)
        expect(models.size).to eql(1)
      end

      it "should return notified models when passed a Hash" do
        post = {class: "post", id: "1", status: "changed"}
        models = Lifesaver::IndexGraph.new.send(:notified_models, post, :on_change)
        expect(models.size).to eql(1)
      end
    end

    context "when passed model has not changed" do
      before(:each) do
        @post = Post.create(title: "Some post")
        @author = Author.create(name: "Some guy")
        Authorship.create(post: @post, author: @author)
      end

      it "should return notified models when passed an ActiveRecord model" do
        models = Lifesaver::IndexGraph.new.send(:notified_models, @author, :on_notify)
        expect(models.size).to eql(1)
      end
      
      it "should return notified models when passed a Hash" do
        author = {class: "author", id: "1", status: "notified"}
        models = Lifesaver::IndexGraph.new.send(:notified_models, author, :on_notify)
        expect(models.size).to eql(1)
      end
    end
  end

  Lifesaver.unsuppress_indexing
end