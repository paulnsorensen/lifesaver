require 'spec_helper'

describe Lifesaver do
  before(:all) do
    Lifesaver.suppress_indexing
    Post.destroy_all
    Author.destroy_all
    Authorship.destroy_all
    Affiliate.destroy_all
    Comment.destroy_all
    Lifesaver.unsuppress_indexing
  end
  before(:each) do
    [Author, Post].each do |klass|
      klass.tire.index.delete
      klass.tire.create_elasticsearch_index
    end

    Lifesaver.suppress_indexing
    
    @posts = []
    @posts << Post.create(
      title: "Lifesavers are my favorite candy", 
      content: "Lorem ipsum",
      tags: %w(candy stuff opinions)
      )
    @posts << Post.create(
      title: "Birds are the best animal", 
      content: "Lorem ipsum",
      tags: %w(animals stuff facts)
    )
    @posts << Post.create(
      title: "Chicago Cubs have a winning season", 
      content: "Lorem ipsum",
      tags: %w(sports stuff jokes)
    )
    @comments = []
    @comments << Comment.create(
      post: @posts.last,
      text: "We love this!"
    )
    @comments << Comment.create(
      post: @posts.last,
      text: "We lied. Didn't realize it was a joke."
    )
    @authors = []
    @authors << Author.create(name: "Paul Sorensen")
    @authors << Author.create(name: "Paul Sorensen's Ghost Writer")
    @authors << Author.create(name: "Theo Epstein")
    @affiliates = []
    @affiliates << Affiliate.create(name: "Prosper Forebearer")
    @affiliates << Affiliate.create(name: "Chicago Cubs")
    @authors[0].affiliate_id = @affiliates.first.id
    @authors[1].affiliate_id = @affiliates.first.id
    @authors[2].affiliate_id = @affiliates.last.id
    @authors.each { |a| a.save! }
    Authorship.create(post: @posts[0], author: @authors[0])
    Authorship.create(post: @posts[1], author: @authors[0])
    Authorship.create(post: @posts[1], author: @authors[1])
    Authorship.create(post: @posts[2], author: @authors[2])

    @authors.each { |a| a.reload }
    @posts.each { |p| p.reload }

    Lifesaver.unsuppress_indexing

    [Author, Post].each do |klass|
      klass.all.each { |k| k.tire.update_index }
      klass.tire.index.refresh
    end
  end

  after(:each) do
    Post.destroy_all
    Author.destroy_all
    Authorship.destroy_all
    Affiliate.destroy_all
    Comment.destroy_all
  end

  it "should traverse the provided graph" do
    input = [{"class_name" => "Author", "id" => 1}]
    indexing_graph = Lifesaver::Notification::IndexingGraph.new
    indexing_graph.initialize_models(input)
    models = indexing_graph.generate
    output = [ @authors[0], @posts[0], @posts[1] ]
    expect(models).to eql(output)
  end

  it "should reindex on destroy" do
    @authors[2].destroy
    sleep(1.seconds)
    expect(Author.search(query: "Theo Epstein").to_a.size).to eql(0)
  end

  it "should reindex on update" do
    @authors[2].name = "Harry Carry"
    @authors[2].save!
    sleep(1.seconds) # need to wait for elasticsearch to update
    expect(Author.search(query: "Harry Carry").to_a.size).to eql(1)
  end

  it "should update distant related indexes" do
    @posts[0].tags << 'werd'
    @posts[0].save!
    sleep(1.seconds)
    expect(Author.search(query: "werd").to_a.size).to eql(1)
  end

  it "should update related indexes if saved model doesn't have index" do
    @comments[0].text = "We hate this!"
    @comments[0].save!
    sleep(1.seconds)
    result = Post.search(query: "Chicago").to_a.first
    comment_text = result.comments.first.text
    expect(comment_text).to eql("We hate this!")
  end
end