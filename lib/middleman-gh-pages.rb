require "middleman-gh-pages/version"

module Middleman
  module GithubPages
    Rake.add_rakelib(File.expand_path('../middleman-gh-pages/tasks', __FILE__))
  end
end
