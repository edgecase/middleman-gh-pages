require 'fileutils'

CURRENT_BRANCH = `git rev-parse --abbrev-ref HEAD`.strip
PROJECT_ROOT   = `git rev-parse --show-toplevel`.strip

REPO_NAME      = ""
REPO_URL       = ""

BUILD_DIR      = File.join(PROJECT_ROOT, "build")
GH_PAGES_REF   = File.join(BUILD_DIR, ".git/refs/remotes/origin/gh-pages")
USER_PAGES_REF = File.join(BUILD_DIR, ".git/refs/remotes/origin/#{CURRENT_BRANCH}")

directory BUILD_DIR

file GH_PAGES_REF => BUILD_DIR do

  cd BUILD_DIR do
    sh "git init"
    sh "git remote add origin #{REPO_URL}"
    sh "git fetch origin"
    sh "git checkout master"

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

file USER_PAGES_REF => BUILD_DIR do

  cd BUILD_DIR do
    sh "git init"
    sh "git remote add origin #{REPO_URL}"
    sh "git fetch origin"

    if `git branch -r` =~ /master/
      sh "git checkout master"
    else
      sh "git checkout --orphan master"
      sh "touch index.html"
      sh "git add ."
      sh "git commit -m 'initial master commit'"
      sh "git push origin master"
    end
  end
end

# Alias to something meaningful
task :prepare_gh_pages_git_remote_in_build_dir   => GH_PAGES_REF
task :prepare_user_pages_git_remote_in_build_dir => USER_PAGES_REF

# Fetch upstream changes for master or gh-pages
task :sync do
  cd BUILD_DIR do
    sh "git fetch origin"
    branch_to_sync = is_user_page? ? "master" : "gh-pages"
    sh "git reset --hard origin/#{branch_to_sync}"
  end
end

# Make sure master is ready for USER PAGES ONLY
task :prepare_master_for_user_pages do
  cd PROJECT_ROOT do
    if `git branch -r` =~ /master/
      sh "git checkout master"

      if (`ls` =~ /index.html/).nil?
        sh "git checkout #{CURRENT_BRANCH}"
      else
        sh "git checkout #{CURRENT_BRANCH}"
        sh "git push origin :master"
        sh "git branch -d master"
      end
    end
  end
end

desc "Get project URL and name"
task :get_project_repo_url_and_name do
  cd PROJECT_ROOT do
    REPO_URL.replace `git config --get remote.origin.url`.strip
    REPO_NAME.replace REPO_URL.match(/\/(.*?)\z/)[1].chomp('.git')
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

desc "Build and publish to GitHub"
task :publish => [:not_dirty, :get_project_repo_url_and_name] do
  message = nil

  if is_user_page?
    if on_master_or_gh_branch
      puts "You are trying to deploy a GitHub user page while on the #{CURRENT_BRANCH} branch.
      Please move to a branch other than master OR gh-pages branch and redeploy."
    else
      Rake::Task['prepare_master_for_user_pages'].invoke
      Rake::Task['prepare_user_pages_git_remote_in_build_dir'].invoke
    end
  else
    Rake::Task['prepare_gh_pages_git_remote_in_build_dir'].invoke
  end

  Rake::Task['sync'].invoke
  Rake::Task['build'].invoke

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
    is_user_page? ? sh("git push origin master") : sh("git push origin gh-pages")
  end
end

def on_master_or_gh_branch
  ["master", "gh-pages"].include?(CURRENT_BRANCH)
end

def is_user_page?
  !REPO_NAME.match(/(.github.(com|io))/)[1].nil?
end

