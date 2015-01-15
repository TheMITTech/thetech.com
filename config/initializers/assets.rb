# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# application.js and application do not include every js or css file, so we have to precompile
# every asset manually:
Rails.application.config.assets.precompile += ['*.js', '*.css', '**/*.js', '**/*.css']
