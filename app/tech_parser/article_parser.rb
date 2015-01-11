module TechParser
  class ArticleParser
    require 'open-uri'

    def initialize(url)
      @url = url
    end

    def parse!
      page = open(@url).read
      doc = Nokogiri::HTML(page)

      article = doc.at_css('div.article')

        meta = {}

        article.at_css('div.article_meta') do |meta|
          meta[:headline] = meta.at_css
        end
      end
    end

    def import!
    end
  end
end