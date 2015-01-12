module TechParser
  class ArticleParser
    require 'open-uri'

    attr_reader :metas, :html

    def initialize(url)
      @url = url
    end

    def parse!
      page = open(@url).read
      doc = Nokogiri::HTML(page)
      @metas = {}

      article = doc.at_css('div.article')
      return if article.nil?
      meta = article.at_css('div.articlemeta')
      return if meta.nil?

      @metas[:headline] = fix_stuff(meta.at_css('.headline').try(:content))
      @metas[:subhead] = fix_stuff(meta.at_css('.subhead').try(:content))
      @metas[:bytitle] = fix_stuff(meta.at_css('.bytitle').try(:content))
      @metas[:authors] = parse_author_line(meta.at_css('.byline a').try(:content))

      meta.remove

      @html = article.to_s

      @success = true
    end

    def import!
      return unless @success
      return if @metas[:authors].empty?

      # For now, import everything into the first section
      piece = Piece.create(
        section_id: Section.first.id,
        issue_id: Issue.first.id
      )

      article = Article.create(
        piece_id: piece.id,
        headline: @metas[:headline],
        subhead: @metas[:subhead],
        bytitle: @metas[:bytitle],
        html: @html,
        author_ids: @metas[:authors].map { |p| Author.find_or_create_by(name: p).id }.join(","),
      )

      article.save_version!
    end

    private
      def fix_stuff(str)
        return nil if str.nil?
        str.lines.map(&:strip).select { |s| !s.blank? }.map(&:strip).join(' ')
      end

      def parse_author_line(line)
        return [] if line.nil?

        regex = /^(.*?) and (.*?)$/
        match = regex.match(line)
        return [match[1], match[2]] if match

        authors = line.split(",").map(&:strip)
        authors[-1] = authors[-1][4..-1] if authors[-1] =~ /^and/

        authors
      end
  end
end