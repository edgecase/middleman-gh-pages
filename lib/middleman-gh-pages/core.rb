require 'rake/dsl_definition'
require 'fileutils'

module Middleman
  module GithubPages

    # Creates the rake tasks for building and pushing your middleman site to github pages.
    #
    # options - optional Hash of overrides
    #           :project_root - The root of where your middleman app is located
    def self.create_tasks options={}
      extend Rake::DSL
      project_root = options[:project_root] || `git rev-parse --show-toplevel`.strip
      build_dir    = File.join(project_root, "build")
      gh_pages_ref = File.join(build_dir, ".git/refs/remotes/origin/gh-pages")

      CLEAN << build_dir if defined? CLEAN

      directory build_dir

      file gh_pages_ref => build_dir do
        repo_url = nil

        cd project_root do
          repo_url = `git config --get remote.origin.url`.strip
        end

        cd build_dir do
          sh "git init"
          sh "git remote add origin #{repo_url}"
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

      # Alias to something meaningful
      task :prepare_git_remote_in_build_dir => gh_pages_ref

      # Fetch upstream changes on gh-pages branch
      task :sync do
        cd build_dir do
          sh "git fetch origin"
          sh "git reset --hard origin/gh-pages"
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
        cd project_root do
          sh "bundle exec middleman build --clean"
        end
      end

      desc "Build and publish to Github Pages"
      task :publish => [:not_dirty, :prepare_git_remote_in_build_dir, :sync, :build] do
        message = nil

        cd project_root do
          head = `git log --pretty="%h" -n1`.strip
          message = "Site updated to #{head}"
        end

        cd build_dir do
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
  end
end