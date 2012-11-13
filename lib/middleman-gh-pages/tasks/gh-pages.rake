require 'fileutils'

BUILD_DIR = File.join(File.dirname(__FILE__), "build")
GH_PAGES_REF = File.join(BUILD_DIR, ".git/refs/remotes/origin/gh-pages")

directory BUILD_DIR

file GH_PAGES_REF => BUILD_DIR do
  repo_url = `git config --get remote.origin.url`.strip

  cd BUILD_DIR do
    sh "git init"
    sh "git remote add origin #{repo_url}"
    sh "git fetch origin"

    if `git branch -r` =~ /gh-pages/
      sh "git checkout gh-pages"
    else
      sh "git checkout --orphan gh-pages"
      sh "touch index.html"
      sh "git add ."
      sh "git commit -m 'initial gh-pages commit'"
      sh "git push origin gh-pages"
    end
  end
end

# Alias to something meaningful
task :prepare_git_remote_in_build_dir => GH_PAGES_REF

# Fetch upstream changes on gh-pages branch
task :sync do
  cd BUILD_DIR do
    sh "git fetch origin"
    sh "git reset --hard origin/gh-pages"
  end
end

# Prevent accidental publishing before committing changes
task :not_dirty do
  fail "Directory not clean" if /nothing to commit/ !~ `git status`
end

desc "Compile all files into the build directory"
task :build do
  sh "bundle exec middleman build --clean"
end

desc "Build and publish to Github Pages"
task :publish => [:not_dirty, :prepare_git_remote_in_build_dir, :sync, :build] do
  head = `git log --pretty="%h" -n1`.strip
  message = "Site updated to #{head}"

  cd BUILD_DIR do
    sh 'git add --all'
    if /nothing to commit/ =~ `git status`
      puts "No changes to commit."
    else
      sh "git commit -m \"#{message}\""
    end
    sh "git push origin gh-pages"
  end
end
