require 'fileutils'

CURRENT_BRANCH = `git rev-parse --abbrev-ref HEAD`.strip
PROJECT_ROOT   = `git rev-parse --show-toplevel`.strip

REPO_NAME      = ""
REPO_URL       = ""

BUILD_DIR      = File.join(PROJECT_ROOT, "build")
GH_PAGES_REF   = File.join(BUILD_DIR, ".git/refs/remotes/origin/gh-pages")
USER_PAGES_REF = File.join(BUILD_DIR, ".git/refs/remotes/origin/#{CURRENT_BRANCH}")
REPO_REF       = File.join(BUILD_DIR, ".git/refs/remotes/origin/#{CURRENT_BRANCH}")

directory BUILD_DIR

file REPO_REF => BUILD_DIR do

  cd PROJECT_ROOT do
    REPO_URL.replace `git config --get remote.origin.url`.strip
    REPO_NAME.replace REPO_URL.match(/\/(.*?)\z/)[1].chomp('.git')
  end
end

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

  end
end

# Alias to something meaningful
task :get_project_repo_url_and_name              => REPO_REF
task :prepare_gh_pages_git_remote_in_build_dir   => GH_PAGES_REF
task :prepare_user_pages_git_remote_in_build_dir => USER_PAGES_REF

# Fetch upstream changes, from the given branch
task :sync, [:branch] do |t, args|
  cd BUILD_DIR do
    sh "git fetch origin"
    sh "git reset --hard origin/#{args.branch}"
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
task :publish => [:not_dirty] do
  message = nil
  Rake::Task['get_project_repo_url_and_name'].invoke

  if is_user_page?
    if !on_master_or_gh_branch
      puts "Error!"
      puts "You are trying to deploy a GitHub user page while on the #{CURRENT_BRANCH} branch.
      Please move to another branch and try again."
    else
      puts "Ready to deploy to master!"
      # Rake::Task['prepare_user_pages_git_remote_in_build_dir'].invoke
      # Rake::Task['sync'].invoke("#{CURRENT_BRANCH}")
      # Rake::Task['build'].invoke

      # #
      # # deploy schtuff
      # #

      # Rake::Task['sync'].invoke('master')
    end
  else
    Rake::Task['get_project_repo_url'].invoke
    Rake::Task['prepage_git_remote_in_build_dir'].invoke
    Rake::Task['sync'].invoke('gh-pages')
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
      sh "git push origin gh-pages"
    end
  end
end

def on_master_or_gh_branch
  !["master", "gh-pages"].include?(CURRENT_BRANCH)
end

def is_user_page?
  !REPO_NAME.match(/(.github.(com|io))/)[1].nil?
end
