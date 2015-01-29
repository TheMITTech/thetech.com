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

  task create_homepage: :environment do
    pieces = ArticleVersion.where(web_status: 1).map {|v| v.article.piece}.uniq.map {|p| p.id}
    pictures = Picture.all.map {|p| p.id}
    homepage_layout = []

    if pieces.any? && pictures.any?
      # create sample two-row homepage layout
      homepage_layout = [
        {modules: [
          {cols: 1, submodules: [
            {type: 'img_nocaption', picture: pictures.sample},
            {type: 'article', piece: pieces.sample, headline: Piece.find(pieces.sample).article.headline, lede: Piece.find(pieces.sample).article.lede},
            {type: 'links', links: [pieces.sample]}
          ]},
          {cols: 2, submodules: [
            {type: 'img', picture: pictures.sample}
          ]},
          {cols: 1, submodules: [
            {type: 'article', piece: pieces.sample, headline: Piece.find(pieces.sample).article.headline, lede: Piece.find(pieces.sample).article.lede},
            {type: 'article', piece: pieces.sample, headline: Piece.find(pieces.sample).article.headline, lede: Piece.find(pieces.sample).article.lede}
          ]}
        ]},
        {modules: [
          {cols: 1, submodules: [
            {type: 'img', picture: pictures.sample}
          ]},
          {cols: 1, submodules: [
            {type: 'article', piece: pieces.sample, headline: Piece.find(pieces.sample).article.headline, lede: Piece.find(pieces.sample).article.lede}
          ]},
          {cols: 1, submodules: [
            {type: 'article', piece: pieces.sample, headline: Piece.find(pieces.sample).article.headline, lede: Piece.find(pieces.sample).article.lede}
          ]},
          {cols: 1, submodules: [
            {type: 'img', picture: pictures.sample}
          ]}
        ]}
      ]
    end

    Homepage.destroy_all
    h = Homepage.create(layout: homepage_layout)

    h.publish_ready!
  end
end
