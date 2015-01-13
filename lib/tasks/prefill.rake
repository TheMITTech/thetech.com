namespace :prefill do
  desc "TODO"
  task sections: :environment do
    Section.destroy_all

    ['News', 'Opinion', 'Campus Life', 'Arts', 'Sports', 'World and Nation', 'Features'].each do |section|
      Section.create(name: section)
    end
  end

  task :import_legacy, [:username, :password, :db] => [:environment] do |t, args|
    require 'legacy_db_parser'
    parser = TechParser::LegacyDBParser.new('127.0.0.1', args[:username], args[:password], args[:db])
    parser.import!
  end

  task :import_legacyhtml, [:username, :password, :db] => [:environment] do |t, args|
    require 'legacy_db_parser'
    parser = TechParser::LegacyDBParser.new('127.0.0.1', args[:username], args[:password], args[:db])
    parser.import_legacyhtml!
  end

end
