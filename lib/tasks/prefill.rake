namespace :prefill do
  desc "TODO"

  task :setup, [:issues] => [:environment] do |t, args|
    issues = args[:issues] || 5

    Rake::Task['prefill:create_root'].invoke
    Rake::Task['prefill:import_legacy'].invoke(issues, 0, 0)
    Rake::Task['prefill:create_homepage'].invoke
  end

  task create_root: :environment do
    if User.find_by(email: 'admin@mit.edu')
      puts 'Superuser already exists. '
    else
      user = User.create(email: 'admin@mit.edu', password: 'themittech', password_confirmation: 'themittech', name: 'Administrator')
      user.roles.create(value: 1)
    end
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

    p1 = pieces.sample
    p2 = pieces.sample
    p3 = pieces.sample
    p4 = pieces.sample
    p5 = pieces.sample

    i1 = pictures.sample
    i2 = pictures.sample
    i3 = pictures.sample

    if pieces.any? && pictures.any?
      # create sample two-row homepage layout
      homepage_layout = [
        {modules: [
          {cols: 1, submodules: [
            {type: 'img_nocaption', picture: pictures.sample},
            {type: 'article', piece: p1, headline: Piece.find(p1).article.headline, lede: Piece.find(p1).article.lede},
            {type: 'links', links: [pieces.sample]}
          ]},
          {cols: 2, submodules: [
            {type: 'img', picture: i1, caption: Picture.find(i1).image.caption}
          ]},
          {cols: 1, submodules: [
            {type: 'article', piece: p2, headline: Piece.find(p2).article.headline, lede: Piece.find(p2).article.lede},
            {type: 'article', piece: p3, headline: Piece.find(p3).article.headline, lede: Piece.find(p3).article.lede}
          ]}
        ]},
        {modules: [
          {cols: 1, submodules: [
            {type: 'img', picture: i2, caption: Picture.find(i2).image.caption}
          ]},
          {cols: 1, submodules: [
            {type: 'article', piece: p4, headline: Piece.find(p4).article.headline, lede: Piece.find(p4).article.lede}
          ]},
          {cols: 1, submodules: [
            {type: 'article', piece: p5, headline: Piece.find(p5).article.headline, lede: Piece.find(p5).article.lede}
          ]},
          {cols: 1, submodules: [
            {type: 'img', picture: i3, caption: Picture.find(i3).image.caption}
          ]}
        ]}
      ]
    end

    Homepage.destroy_all
    h = Homepage.create(layout: homepage_layout)

    h.publish_ready!
  end
end
