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

  task :import_legacy, [:username, :password, :db, :num, :skip, :html] => [:environment] do |t, args|
    require 'legacy_db_parser'
    parser = TechParser::LegacyDBParser.new('127.0.0.1', args[:username], args[:password], args[:db])
    parser.import!({num: args[:num], skip: args[:skip], legacy_html: args[:html]})
  end

end
