require "middleman-gh-pages/version"

if defined?(Rake)
  Rake.add_rakelib(File.expand_path('../middleman-gh-pages/tasks', __FILE__))
end
