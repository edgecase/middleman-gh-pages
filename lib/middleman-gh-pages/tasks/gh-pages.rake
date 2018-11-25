require "fileutils"
require "tmpdir"

def remote_name
  ENV.fetch("REMOTE_NAME", "origin")
end

def branch_name
  ENV.fetch("BRANCH_NAME", "gh-pages")
end

def uncommitted_changes?
  `git status --porcelain`.chomp.length > 0
end

def backup_and_restore(dir, file, &block)
  return yield unless File.exist?(File.join(dir, file))

  Dir.mktmpdir do |tmpdir|
    mv File.join(dir, file), tmpdir
    yield
    mv File.join(tmpdir, file), dir
  end
end

PROJECT_ROOT = ENV.fetch("PROJECT_ROOT", `git rev-parse --show-toplevel`.chomp)
BUILD_DIR    = ENV.fetch("BUILD_DIR", File.join(PROJECT_ROOT, "build"))
GH_PAGES_REF = File.join(BUILD_DIR, ".git/refs/remotes/#{remote_name}/#{branch_name}")

directory BUILD_DIR

file GH_PAGES_REF => BUILD_DIR do
  repo_url = nil

  cd PROJECT_ROOT do
    repo_url = `git config --get remote.#{remote_name}.url`.chomp
  end

  cd BUILD_DIR do
    sh "git init"
    sh "git remote add #{remote_name} #{repo_url}"
    sh "git fetch #{remote_name} #{branch_name}"

    if `git branch -r` =~ /#{branch_name}/
      sh "git checkout #{branch_name}"
    else
      sh "git checkout --orphan #{branch_name}"
      FileUtils.touch("index.html")
      sh "git add ."
      sh "git commit -m \"initial gh-pages commit\""
      sh "git push #{remote_name} #{branch_name}"
    end
  end
end

# Alias to something meaningful
task :prepare_build_dir => GH_PAGES_REF

# Fetch upstream changes on gh-pages branch
task :sync_build_dir => :prepare_build_dir do
  cd BUILD_DIR do
    sh "git fetch #{remote_name} #{branch_name}"
    sh "git reset --hard #{remote_name}/#{branch_name}"
  end
end

# Prevent accidental publishing before committing changes
task :prevent_dirty_builds do
  if uncommitted_changes?
    puts "*** WARNING: You currently have uncommitted changes. ***"
    fail "Build aborted, because project directory is not clean." unless ENV["ALLOW_DIRTY"]
  end
end

desc "Compile all files into the build directory"
task :build do
  backup_and_restore(BUILD_DIR, ".git") do
    cd PROJECT_ROOT do
      sh "bundle exec middleman build --clean"
    end
  end
end

desc "Build and publish to Github Pages"
task :publish => [:prevent_dirty_builds, :sync_build_dir, :build] do
  message = nil
  suffix = ENV["COMMIT_MESSAGE_SUFFIX"]

  cd PROJECT_ROOT do
    head = `git log --pretty="%h" -n1`.chomp
    message = ["Site updated to #{head}", suffix].compact.join("\n\n")
  end

  cd BUILD_DIR do
    sh "git add --all"
    if uncommitted_changes?
      sh "git commit -m \"#{message}\""
    else
      puts "No changes to commit."
    end
    sh "git push #{remote_name} #{branch_name}"
  end
end
