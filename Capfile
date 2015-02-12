require 'recap/recipes/rails'

set :application, 'prototype-rails'
set :repository, 'git@github.com:TheMITTech/prototype-rails.git'
set :foreman_template_option, "--env #{application_home}/.env"

# The rails tasks build on standard deployment with support for running
# database migrations and precompiling assets.

require 'recap/tasks/deploy'

module Recap::Tasks::Rails
  extend Recap::Support::Namespace
  namespace :rails do
    namespace :assets do
      namespace :precompile do
        task :if_changed do
          puts 'Assets precompilation is now done locally and assets should be checked into Github repo. '
        end
      end
    end
  end
end

task :staging_importer do
  set :branch, 'deploy'
  ssh_options[:keys] = ENV['AMAZON_STAGING_PEM_FILE']
  server 'ubuntu@' + ENV['STAGING_IMPORTER_IP'], :app
end

task :staging do
  set :branch, 'deploy'
  ssh_options[:keys] = ENV['AMAZON_STAGING_PEM_FILE']
  server 'ubuntu@' + ENV['STAGING_IP'], :app
end

task :backend do
  set :branch, 'production'
  ssh_options[:keys] = ENV['AMAZON_PRODUCTION_PEM_FILE']
  server 'ubuntu@' + ENV['PRODUCTION_BACKEND_IP'], :app
end

task :production_importer do
  set :branch, 'production'
  ssh_options[:keys] = ENV['AMAZON_PRODUCTION_PEM_FILE']
  server 'ubuntu@' + ENV['PRODUCTION_IMPORTER_IP'], :app
end

task :frontend do
  set :branch, 'production'
  ssh_options[:keys] = ENV['AMAZON_PRODUCTION_PEM_FILE']
  server 'ubuntu@' + ENV['PRODUCTION_FRONTEND_IP'], :app
end