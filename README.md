# Lifesaver

[![Build Status](https://travis-ci.org/paulnsorensen/lifesaver.png?branch=master)](https://travis-ci.org/paulnsorensen/lifesaver)
[![Gem Version](https://badge.fury.io/rb/lifesaver.png)](http://badge.fury.io/rb/lifesaver)
[![Dependency Status](https://gemnasium.com/paulnsorensen/lifesaver.png)](https://gemnasium.com/paulnsorensen/lifesaver)
[![Coverage Status](https://coveralls.io/repos/paulnsorensen/lifesaver/badge.png)](https://coveralls.io/r/paulnsorensen/lifesaver)
[![Code Climate](https://codeclimate.com/github/paulnsorensen/lifesaver.png)](https://codeclimate.com/github/paulnsorensen/lifesaver)

Asynchronously sends your ActiveRecord models for reindexing in [elasticsearch](https://github.com/elasticsearch/elasticsearch) by making use of [tire](https://github.com/karmi/tire) and [resque](https://github.com/resque/resque) (hence the name: resque + tire = lifesaver). Lifesaver also provides the ability to traverse ActiveRecord associations to trigger the index updates of related models.

## Installation

Add this line to your application's Gemfile:

    gem 'lifesaver'

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

#### Configuring Indexing Behavior
You can suppress index updates on a per-model basis or globally using `Lifesaver.suppress_indexing` (to turn suppression back off, you would use `Lifesaver.unsuppress_indexing`). Lifesaver exposes two instance methods on the model level (`supress_indexing`, `unsuppress_indexing`) that set a model's indexing behavior for life of that instance.

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

## Integration with Tire
Lifesaver will not execute any `<after|before>_update_elasticsearch_index` callback hooks. Lifesaver also does not currently support percolation.

## Integration with Resque
You will see two new queues: `lifesaver_indexing` and `lifesaver_notification`. The queue names are configurable.

## Testing

In your spec_helper, you should place something similar to the following to make sure Lifesaver isn't spawning up indexing jobs unless you want it to.

```ruby
    config.before(:each) do
      Lifesaver.suppress_indexing
    end
```

Then, when your tests need Lifesaver to run, you should make sure you unsuppress indexing in a `before` block. You may also want to run [Resque inline](http://robots.thoughtbot.com/process-jobs-inline-when-running-acceptance-tests).

```ruby
  describe 'some test' do
    before { Lifesaver.unsuppress_indexing }
    # tests go here
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO
Please visit TODO page [here](https://github.com/paulnsorensen/lifesaver/wiki/TODO)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/paulnsorensen/lifesaver/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
