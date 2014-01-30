require 'tire'

ActiveSupport.on_load :active_record do
  include Lifesaver::Indexing::ModelAdditions
  include Lifesaver::Notification::ModelAdditions
end

class Author < ActiveRecord::Base
  has_many :authorships, dependent: :destroy
  has_many :posts, through: :authorships
  belongs_to :affiliate
  enqueues_indexing
  include ::Tire::Model::Search

  notifies_for_indexing :authorships
  def post_tags
    tags = Set.new
    posts.select(:tags).each do |p|
      tags |= Set.new(p.tags)
    end
    tags.to_a
  end
  mapping do
    indexes :id, type: 'integer', index: 'not_analyzed'
    indexes :name, type: 'multi_field', fields: {
      name: { type: 'string', analyzer: 'snowball' },
      untouched: { type: 'string', index: 'not_analyzed' }
    }
    indexes :post_tags, analyzer: 'keyword'
  end
  def self.search(params)
    tire.search do
      size 100
      query { string params[:query] } if params[:query].present?
      sort do
        by 'name.untouched', :asc
      end
      filter :term, affiliate_id: params[:afilliate_id] if params[:affiliate_id].present?
    end
  end
  def to_indexed_json
    to_json(include: :affiliate, methods: :post_tags)
  end
end

class Authorship < ActiveRecord::Base
  belongs_to :author
  belongs_to :post
  notifies_for_indexing only_on_notify: [:author, :post]
end

class Comment < ActiveRecord::Base
  belongs_to :post
  notifies_for_indexing :post
end

class Post < ActiveRecord::Base
  has_many :comments
  has_many :authorships, dependent: :destroy
  has_many :authors, through: :authorships
  serialize :tags, Array
  enqueues_indexing
  notifies_for_indexing only_on_change: :authorships
  include ::Tire::Model::Search
  mapping do
    indexes :id, type: 'integer', index: 'not_analyzed'
    indexes :title, type: 'multi_field', fields: {
      title: { type: 'string', analyzer: 'snowball' },
      untouched: { type: 'string', index: 'not_analyzed' }
    }
  end

  def self.search(params)
    tire.search do
      size 100
      query { string params[:query] } if params[:query].present?
      sort do
        by 'title.untouched', :asc
      end
    end
  end

  def to_indexed_json
    to_json(include: :comments, authors: { include: :affiliate })
  end
end

class Affiliate < ActiveRecord::Base
  has_many :authors
  notifies_for_indexing :authors
end
