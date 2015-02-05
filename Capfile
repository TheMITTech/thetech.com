require 'recap/recipes/rails'

set :application, 'prototype-rails'
set :repository, 'git@github.com:TheMITTech/prototype-rails.git'
set :foreman_template_option, "--env #{application_home}/.env"

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

task :frontend do
  set :branch, 'production'
  ssh_options[:keys] = ENV['AMAZON_PRODUCTION_PEM_FILE']
  server 'ubuntu@' + ENV['PRODUCTION_FRONTEND_IP'], :app
end