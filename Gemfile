source 'https://rubygems.org'

# Specify your gem's dependencies in lifesaver.gemspec
gemspec

group :test do
  gem 'coveralls', require: false
end

group :development, :test do
  gem 'pry', require: false
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
