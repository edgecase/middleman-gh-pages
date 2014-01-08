# Middleman Github Pages

[Middleman](http://middlemanapp.com) makes creating static sites a joy, [Github 
Pages](http://pages.github.com) hosts static sites for free, Middleman Github 
Pages brings the two together. Middleman Github Pages is just a few rake tasks 
that automate the process of deploying a Middleman site to Github Pages.

## Installation

Add this line to your Gemfile:

```ruby
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

## Options

You cannot deploy your site if you have uncommitted changes. You can
override this with the `ALLOW_DIRTY` option:

```shell
bundle exec rake publish ALLOW_DIRTY=true
```

You can append a custom suffix to commit messages on the build branch:

```shell
bundle exec rake publish COMMIT_MESSAGE_SUFFIX="--skip-ci"
```

You can change the remote that you deploy to:

```shell
bundle exec rake publish REMOTE_NAME=upstream
```

## Custom Domain

To set up a custom domain, you can follow the [GitHub help page](https://help.github.com/articles/setting-up-a-custom-domain-with-pages).

__NOTE__ You will need to put your CNAME file in the `source` directory of your middleman project, NOT in its root directory. This will result in the CNAME file being in the root of the generated static site in your gh-pages branch.

## Project Page Path Issues

Since project pages deploy to a subdirectory, assets and page paths are relative to the organization or user that owns the repo. If you're treating the project pages as a standalone site, you can tell Middleman to generate relative paths for assets and links with these settings in the build configuration in `config.rb`

    activate :relative_assets
    set :relative_links, true

__NOTE__ This only affects sites being accessed at the `username.github.io/projectname` URL, not when accessed at a custom CNAME.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
