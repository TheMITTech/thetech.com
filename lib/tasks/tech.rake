namespace :tech do
  desc "TODO"
  task :scrape_page, [:url] => [:environment] do |t, args|
    require 'open-uri'
    require 'article_parser'

    Article.delete_all
    Piece.delete_all
    Image.delete_all
    Author.delete_all

    page = open(args[:url]).read
    doc = Nokogiri::HTML(page)

    doc.css('a').each do |a|
      regex = /^\/V(\d+)\/N(\d+)\/(.*).html$/
      next unless regex.match(a['href'])

      url = 'http://tech.mit.edu' + a['href']

      puts url

      p = TechParser::ArticleParser.new(url)
      p.parse!
      p.import!
    end
  end

end
