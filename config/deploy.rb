require "bundler/capistrano"
require "capistrano-rbenv"
require 'capistrano/ext/multistage'

load "config/recipes/base"
load "config/recipes/monit"

set :application, "YOUR APPLICATION NAME"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "YOUR GIT URL/#{application}.git"
set :stages, ["staging", "production"]
set :default_stage, "staging"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config_app, roles: :app do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/assets"
    sudo "ln -nfs #{current_path}/config/unicorn_#{rails_env}_init.sh /etc/init.d/unicorn_#{application}"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end

  task :setup_config_web, roles: :web do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/assets"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    sudo "ln -nfs #{current_path}/config/nginx.#{rails_env}.conf /etc/nginx/sites-enabled/#{application}"
    puts "Now edit the config files in #{shared_path}."
  end

  task :setup_config_db, roles: :db do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end

  after "deploy:setup", "deploy:setup_config_app","deploy:setup_config_web","deploy:setup_config_db"

  task :symlink_config do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/assets"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
    sudo "ln -nfs #{current_path}/config/nginx.#{rails_env}.conf /etc/nginx/sites-enabled/#{application}"
  end

  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts "WARNING: HEAD is not the same as origin/#{branch}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
