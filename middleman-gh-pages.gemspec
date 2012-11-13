# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-gh-pages/version'

Gem::Specification.new do |gem|
  gem.name          = "middleman-gh-pages"
  gem.version       = Middleman::GithubPages::VERSION
  gem.authors       = ["Adam McCrea"]
  gem.email         = ["adam@adamlogic.com"]
  gem.description   = %q{Easy deployment of Middleman sites to Github Pages}
  gem.summary       = %q{Easy deployment of Middleman sites to Github Pages}
  gem.homepage      = "http://github.com/newcontext/middleman-gh-pages"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rake', '> 0.9.3'
end
