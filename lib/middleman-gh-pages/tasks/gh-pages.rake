require 'fileutils'

def source_branch
  @source_branch ||= ENV.fetch('SOURCE_BRANCH', 'master')
end

def destination_branch
  @destination_branch ||= ENV.fetch('DESTINATION_BRANCH', 'gh-pages')
end

PROJECT_ROOT = `git rev-parse --show-toplevel`.strip
BUILD_DIR    = File.join(PROJECT_ROOT, "build")
GH_PAGES_REF = File.join(BUILD_DIR, ".git/refs/remotes/origin/#{destination_branch}")

directory BUILD_DIR

file GH_PAGES_REF => BUILD_DIR do
  repo_url = nil

  cd PROJECT_ROOT do
    repo_url = `git config --get remote.origin.url`.strip
  end

  cd BUILD_DIR do
    sh "git init"
    sh "git remote add origin #{repo_url}"
    sh "git fetch origin"
    sh "git checkout #{source_branch}"

    if `git branch -r` =~ /#{destination_branch}/
      sh "git checkout #{destination_branch}"
    else
      sh "git checkout --orphan #{destination_branch}"
      sh "touch index.html"
      sh "git add ."
      sh "git commit -m 'initial #{destination_branch} commit'"
      sh "git push origin #{destination_branch}"
    end
  end
end

# Alias to something meaningful
task :prepare_git_remote_in_build_dir => GH_PAGES_REF

# Fetch upstream changes on published branch
task :sync do
  cd BUILD_DIR do
    sh "git fetch origin"
    sh "git reset --hard origin/#{destination_branch}"
  end
end

# Prevent accidental publishing before committing changes
task :not_dirty do
  puts "***#{ENV['ALLOW_DIRTY']}***"
  unless ENV['ALLOW_DIRTY']
    fail "Directory not clean" if /nothing to commit/ !~ `git status`
  end
end

desc "Compile all files into the build directory"
task :build do
  cd PROJECT_ROOT do
    sh "bundle exec middleman build --clean"
  end
end

desc "Build and publish to Github Pages"
task :publish => [:not_dirty, :prepare_git_remote_in_build_dir, :sync, :build] do
  message = nil

  cd PROJECT_ROOT do
    head = `git log --pretty="%h" -n1`.strip
    message = "Site updated to #{head}"
  end

  cd BUILD_DIR do
    sh 'git add --all'
    if /nothing to commit/ =~ `git status`
      puts "No changes to commit."
    else
      sh "git commit -m \"#{message}\""
    end
    sh "git push origin #{destination_branch}"
  end
end
