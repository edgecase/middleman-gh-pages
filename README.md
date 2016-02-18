# Middleman Github Pages

[![Gem Version](https://img.shields.io/gem/v/middleman-gh-pages.svg)](https://rubygems.org/gems/middleman-gh-pages)
[![Gem Downloads](https://img.shields.io/gem/dt/middleman-gh-pages.svg)](https://rubygems.org/gems/middleman-gh-pages)

[Middleman](https://middlemanapp.com/) makes creating static sites a joy, [Github
Pages](https://pages.github.com/) hosts static sites for free, Middleman Github
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

## Environment Variable Options

### `ALLOW_DIRTY`

You cannot deploy your site if you have uncommitted changes, but you can
override this (default: `nil`):

```
bundle exec rake publish ALLOW_DIRTY=true
```

### `COMMIT_MESSAGE_SUFFIX`

You can append a custom suffix to commit messages on the build branch
(default: `nil`):

```
bundle exec rake publish COMMIT_MESSAGE_SUFFIX="[skip-ci]"
```

### `REMOTE_NAME`

You can change the remote that you deploy to (default: `origin`):

```
bundle exec rake publish REMOTE_NAME=upstream
```

### `BRANCH_NAME`

If you're publishing a personal or organization page, you may want to use the
branch `master` instead of `gh-pages` (default: `gh-pages`):

```
bundle exec rake publish BRANCH_NAME=master
```

### `PROJECT_ROOT`

If your middleman project isn't at the root of your repository, you will
likely need to change this (default: _root of git repository_):

```
bundle exec rake publish PROJECT_ROOT=/Users/me/projects/repo/www
```

### `BUILD_DIR`

If you override the default middlemant `:build_dir` setting, you will likely
also need to set this variable (default: `<PROJECT_ROOT>/build`):

```
bundle exec rake publish BUILD_DIR=/some/custom/path/to/public
```

### Setting ENV variables from your Rakefile

Of course, for more permanent settings, you can always set these environment
variables directly in your `Rakefile` instead of from the command line.

```ruby
require "middleman-gh-pages"

# Ensure builds are skipped when publishing to the gh-pages branch
ENV["COMMIT_MESSAGE_SUFFIX"] = "[skip ci]"
# Ignore errors about dirty builds (not recommended)
ENV["ALLOW_DIRTY"] = "true"
```

## Custom Domain

To set up a custom domain, you can follow the [GitHub help page](https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages/).

__NOTE__ You will need to put your CNAME file in the `source` directory of your middleman project, NOT in its root directory. This will result in the CNAME file being in the root of the generated static site in your gh-pages branch.

## Project Page Path Issues

Since project pages deploy to a subdirectory, assets and page paths are relative to the organization or user that owns the repo. If you're treating the project pages as a standalone site, you can tell Middleman to generate relative paths for assets and links with these settings in the build configuration in `config.rb`

``` ruby
activate :relative_assets
set :relative_links, true
```

__NOTE__ This only affects sites being accessed at the `username.github.io/projectname` URL, not when accessed at a custom CNAME.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
