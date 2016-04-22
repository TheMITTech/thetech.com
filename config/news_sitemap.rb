# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://thetech.com"

SitemapGenerator::Sitemap.public_path = 'public/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/news'
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.include_root = false
SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(:news_sitemap)

SitemapGenerator::Sitemap.create do

  Piece.find_each do |piece|
    #Only add articles that are newer than two days!!! Using 1.9 as a buffer

    if (Time.zone.now - piece.publish_datetime) /1.day.to_i > 2  then
      next
    end

    year = piece.publish_datetime.strftime('%Y')
    mo = piece.publish_datetime.strftime('%m')
    day = piece.publish_datetime.strftime('%d')

    tags_array = piece.tags

    tags_string = tags_array.join(", ")

    genre = ""
    case piece.section.slug
    when "opinion"
      genre = "OpEd, "
    when "arts"
      genre = "Opinion, "
    end

    genre << "UserGenerated"

    if !piece.article.nil? && piece.article.web_published? 
      add frontend_piece_path(year: year, month: mo, day: day, slug: piece.slug) , lastmod: piece.updated_at, priority: 1.0,  changefreq: 'never', 
      news: {
        publication_name: "The Tech",
        publication_language: "en",
        title: piece.article.headline.strip,
        keywords: tags_string,
        publication_date: piece.published_at,
        genres: genre
         }
    end

  end  


  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end


end
