# Lifesaver

[![Build Status](https://travis-ci.org/paulnsorensen/lifesaver.png?branch=master)](https://travis-ci.org/paulnsorensen/lifesaver)
[![Dependency Status](https://gemnasium.com/paulnsorensen/lifesaver.png)](https://gemnasium.com/paulnsorensen/lifesaver)
[![Coverage Status](https://coveralls.io/repos/paulnsorensen/lifesaver/badge.png)](https://coveralls.io/r/paulnsorensen/lifesaver)
[![Code Climate](https://codeclimate.com/github/paulnsorensen/lifesaver.png)](https://codeclimate.com/github/paulnsorensen/lifesaver)

Indexes your ActiveRecord models in [elasticsearch](https://github.com/elasticsearch/elasticsearch) asynchronously by making use of [tire](https://github.com/karmi/tire) and [resque](https://github.com/resque/resque) (hence the name: resque + tire = lifesaver). Using lifesaver, you can easily control when or if to reindex your model depending on your context. Lifesaver also provides the ability to traverse ActiveRecord associations to trigger the index updates of related models.

## Installation

Add this line to your application's Gemfile:

    gem 'lifesaver', git: "git://github.com/paulnsorensen/lifesaver.git"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lifesaver

## Usage

Replaces the tire callbacks in your models

```ruby
    class Article < ActiveRecord::Base
      include Tire::Model::Search
      # Replace the following include with Lifesaver
      # include Tire::Model::Callbacks
      enqueues_indexing
    end
```

#### Configurable Behavior
You can decided when or if the index gets updated at all based on your current situation. Lifesaver exposes two methods (`supress_indexing`, `unsuppress_indexing`) that set a model's indexing behavior until that model is saved.

```ruby
    class ArticlesController < ApplicationController
      def suppressed_update
        @article = Article.find(params[:id])
        @article.attributes = params[:article]

        # No reindexing will occur at all
        @article.suppress_indexing

        @article.save!
        
        # Not neccessary but if saved
        # after this following call,
        # this article would reindex
        @article.unsuppress_indexing
      end
    end
```

#### ActiveRecord Association Traversal
Lifesaver can trigger other models to reindex if you have nested models in your indexes that you would like to update. Use the `notifies_for_indexing` method to indicate which related models should be marked for indexing. Any associations passed will be both updated when a model is changed (`save` or `destroy`) and when another model notifies it. Any associations passed in the options will only notify when the model is changed or notified when specified in the `only_on_change` or `only_on_notify` keys, respectively.

```ruby
    class Article < ActiveRecord::Base
      belongs_to :author
      belongs_to :category
      has_many :watchers
      has_one :moderator
      
      notifies_for_indexing :author, 
        only_on_change: :category,
        only_on_notify: [:watchers, :moderator]
    end
```

## Integration with Resque
You will see two new queues: `lifesaver_indexing` and `lifesaver_notification`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO
+ specify which fields will trigger indexing changes
+ configuration options
+ bulk indexing
+ resque-scheduler to provide `delay_indexing` and `enqueues_indexing after: 30.minutes, on: :save`
+ unsuppress indexing after save
+ sidekiq support
+ prepare for new elasticsearch library