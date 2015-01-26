namespace :prefill do
  desc "TODO"

  task create_root: :environment do
    user = User.create(email: 'admin@mit.edu', password: 'themittech', password_confirmation: 'themittech', name: 'Administrator')
    user.roles.create(value: 1)
  end

  task sections: :environment do
    Section.destroy_all

    ['News', 'Opinion', 'Campus Life', 'Arts', 'Sports', 'World and Nation', 'Features'].each do |section|
      Section.create(name: section)
    end
  end

  task :import_legacy, [:num, :skip, :html] => [:environment] do |t, args|
    require 'legacy_db_parser'
    db_args = YAML.load(File.read(File.join(Rails.root, 'config/database.yml')))['legacy']
    parser = TechParser::LegacyDBParser.new(db_args['host'], db_args['username'], db_args['password'], db_args['database'])
    parser.import!({num: args[:num], skip: args[:skip], legacy_html: args[:html]})
  end

end
