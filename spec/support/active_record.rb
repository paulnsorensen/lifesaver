require 'active_record'
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

module ActiveModel::Validations
  # Extension to enhance `should have` on AR Model instances.  Calls
  # model.valid? in order to prepare the object's errors object.
  #
  # You can also use this to specify the content of the error messages.
  #
  # @example
  #
  #     model.should have(:no).errors_on(:attribute)
  #     model.should have(1).error_on(:attribute)
  #     model.should have(n).errors_on(:attribute)
  #
  #     model.errors_on(:attribute).should include("can't be blank")
  def errors_on(attribute)
    self.valid?
    [errors[attribute]].flatten.compact
  end
  alias_method :error_on, :errors_on
end

# test models we'll use in each spec
ActiveRecord::Migration.create_table :comments do |t|
  t.string :text
  t.integer :post_id
  t.timestamps
end

ActiveRecord::Migration.create_table :posts do |t|
  t.string :title
  t.text :content
  t.text :tags
  t.timestamps
end

ActiveRecord::Migration.create_table :authors do |t|
  t.string :name
  t.integer :affiliate_id
  t.timestamps
end

ActiveRecord::Migration.create_table :authorships do |t|
  t.integer :post_id
  t.integer :author_id
  t.timestamps
end

ActiveRecord::Migration.create_table :affiliates do |t|
  t.string :name
  t.timestamps
end
