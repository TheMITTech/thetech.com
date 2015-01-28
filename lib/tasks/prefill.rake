namespace :prefill do
  desc "TODO"
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

  task :create_homepage do
    pieces = ArticleVersion.where(web_status: 1).map {|v| v.article.piece}.uniq.map {|p| p.id}
    pictures = Picture.all.map {|p| p.id}
    homepage_layout = []

    if pieces.any? && pictures.any?
      # create sample two-row homepage layout
      homepage_layout = [
        [
          {cols: 1, modules: [
            {type: 'img_nocaption', picture: pictures.sample},
            {type: 'article', piece: pieces.sample},
            {type: 'links', links: [pieces.sample]}
          ]},
          {cols: 2, modules: [
            {type: 'img', picture: pictures.sample}
          ]},
          {cols: 1, modules: [
            {type: 'article', piece: pieces.sample},
            {type: 'article', piece: pieces.sample}
          ]}
        ],
        [
          {cols: 1, modules: [
            {type: 'img', picture: pictures.sample}
          ]},
          {cols: 1, modules: [
            {type: 'article', piece: pieces.sample}
          ]},
          {cols: 1, modules: [
            {type: 'article', piece: pieces.sample}
          ]},
          {cols: 1, modules: [
            {type: 'img', picture: pictures.sample}
          ]}
        ]
      ]
    end

    Homepage.create(layout: homepage_layout)
  end
end
