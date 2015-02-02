require 'recap/recipes/rails'

set :application, 'prototype-rails'
set :repository, 'git@github.com:TheMITTech/prototype-rails.git'
set :branch, 'deploy'

ssh_options[:keys] = ENV['AMAZON_PEM_FILE']

set :foreman_template_option, "--env #{application_home}/.env"

server 'ubuntu@54.152.138.149', :app
