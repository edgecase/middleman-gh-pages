# Middleman Github Pages

[Middleman](http://middlemanapp.com) makes creating static sites a joy, [Github 
Pages](http://pages.github.com) hosts static sites for free, Middleman Github 
Pages brings the two together. Middleman Github Pages is just a few rake tasks 
that automate the process of deploying a Middleman site to Github Pages.

## Installation

Add this line to your Gemfile:

```shell
gem 'middleman-gh-pages'
```

You'll also need to require the gem in your Rakefile:

```ruby
require 'middleman-gh-pages'
```

## Usage

Middleman Github Pages provides the following rake tasks:

```shell
rake build    # Compile all files into the build directory
rake publish  # Build and publish to Github Pages
```

The only assumption is that you are deploying to a gh-pages branch in the same 
remote as the source. `rake publish` will create this branch for you if it 
doesn't exist.

Note that you cannot deploy your site if you have uncommitted changes. You can
override this with the `ALLOW_DIRTY` option:

```shell
bundle exec rake publish ALLOW_DIRTY=true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
