require 'spec_helper'

describe Lifesaver do
  before do
    Lifesaver.suppress_indexing
  end
  let(:affiliate) { Affiliate.create(name: 'Prosper Forebearer') }
  let(:author) do
    Author.create(name: 'Theo Epstein', affiliate_id: affiliate.id)
  end
  let(:post) do
    Post.create(
                title: 'Lifesavers are my favorite candy',
                content: 'Lorem ipsum',
                tags: %w(candy stuff opinions)
               )
  end
  let(:comment) do
    Comment.create(
                   post: post,
                   text: 'We love this!'
                  )
  end
  before do
    Authorship.create(post: post, author: author)
    author.reload
    post.reload

    setup_indexes([author, post])

    Lifesaver.unsuppress_indexing
  end

  it 'should traverse the provided graph' do
    input = [{ 'class_name' => 'Author', 'id' => 1 }]
    output = [author, post]
    indexing_graph = Lifesaver::Notification::IndexingGraph.new
    indexing_graph.initialize_models(input)

    models = indexing_graph.generate

    expect(models).to eql(output)
  end

  it 'should reindex on destroy' do
    author.destroy
    author.index.refresh

    expect(Author.search(query: 'Theo Epstein').count).to eql(0)
  end

  it 'should reindex on update' do
    author.name = 'Harry Carry'
    author.save!
    author.index.refresh

    expect(Author.search(query: 'Harry Carry').count).to eql(1)
  end

  it 'should update distant related indexes' do
    post.tags << 'werd'
    post.save!
    author.index.refresh

    expect(Author.search(query: 'werd').count).to eql(1)
  end

  it "should update related indexes if saved model doesn't have index" do
    comment.text = 'We hate this!'
    comment.save!
    post.index.refresh

    result = Post.search(query: 'Lifesavers').to_a.first
    comment_text = result.comments.first.text

    expect(comment_text).to eql('We hate this!')
  end
end
