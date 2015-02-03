require 'recap/recipes/rails'
require "whenever/capistrano"

set :application, 'prototype-rails'
set :repository, 'git@github.com:TheMITTech/prototype-rails.git'
set :foreman_template_option, "--env #{application_home}/.env"

task :staging do
  set :branch, 'deploy'
  ssh_options[:keys] = ENV['AMAZON_STAGING_PEM_FILE']
  server 'ubuntu@54.86.101.151', :app
end

task :backend do
  set :branch, 'production'
  ssh_options[:keys] = ENV['AMAZON_PRODUCTION_PEM_FILE']
  server 'ubuntu@54.152.245.252', :app
end

task :frontend do
  set :branch, 'production'
  ssh_options[:keys] = ENV['AMAZON_PRODUCTION_PEM_FILE']
  server 'ubuntu@54.84.30.113', :app
end