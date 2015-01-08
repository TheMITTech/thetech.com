# Load the Rails application.
require File.expand_path('../application', __FILE__)

Paperclip.options[:command_path] = "/usr/local/bin"

# Initialize the Rails application.
Rails.application.initialize!
