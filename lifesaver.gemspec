# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lifesaver/version'

Gem::Specification.new do |spec|
  spec.name          = "lifesaver"
  spec.version       = Lifesaver::VERSION
  spec.authors       = ["Paul Sorensen"]
  spec.email         = ["paulnsorensen@gmail.com"]
  spec.description   = %q{Asynchronously sends your ActiveRecord models for reindexing in elasticsearch by making use of tire and resque}
  spec.summary       = %q{Asynchronously sends your ActiveRecord models for reindexing in elasticsearch by making use of tire and resque}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_runtime_dependency 'activerecord', '>= 3'
  spec.add_runtime_dependency 'tire', '~> 0.6.0'
  spec.add_runtime_dependency 'resque', '~> 1.25.0'
  spec.add_runtime_dependency 'resque-loner', '~> 1.3.0'

  if RUBY_ENGINE == 'rbx'
    spec.add_development_dependency 'racc'
    spec.add_development_dependency 'rubysl', '~> 2.0'
    spec.add_development_dependency 'json'
  end
end
