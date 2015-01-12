module TechParser
  class LegacyDBParser
    def initialize(host, username, password, db)
      @client = Mysql2::Client.new(host: host, username: username, password: password, database: db)
    end

    def import!
      import_sections
      import_issues
      import_articles
    end

    private
      def import_sections
        Section.destroy_all

        sections = @client.query('SELECT * FROM section')
        sections.each do |s|
          Section.create do |sec|
            sec.id = s['idsection'].to_i
            sec.name = s['sectionname']
          end
        end

        puts "Imported #{sections.count} sections. "
      end

      def import_issues
        Issue.destroy_all
        count = 0

        issues = @client.query('SELECT * FROM issues')
        issues.each do |i|
          count += 1

          Issue.create do |iss|
            iss.id = i['idissues'].to_i
            iss.volume = i['volume'].to_i
            iss.number = i['issue'].to_i
          end

          puts "#{count} issues imported. " if count % 100 == 0
        end

        puts "#{count} issues imported. "
      end

      def import_articles
        Piece.destroy_all
        Article.destroy_all

        articles = @client.query('SELECT * FROM articles')
        count = 0

        articles.each do |a|
          count += 1

          piece = Piece.create do |pie|
            pie.id = a['idarticles'].to_i
            pie.section_id = a['SectionID'].to_i
            pie.issue_id = a['IssueID'].to_i
          end

          article = Article.create do |art|
            art.piece_id = art.id = a['idarticles'].to_i
            art.headline = a['headline']
            art.subhead = a['subhead']
            art.author_ids = parse_author_line(a['byline'])
            art.bytitle = a['bytitle']
            art.html = a['body']
          end

          article.save_version!

          puts "#{count} articles imported. " if count % 100 == 0
        end

        puts "#{count} articles imported. "
      end

      def parse_author_line(line)
        return "" if line.blank?
        authors = []

        line = line.gsub("\n", '')

        regex = /^(.*?) and (.*?)$/
        match = regex.match(line)

        if match
          authors = [match[1], match[2]]
        else
          authors = line.split(",").map(&:strip)
          authors[-1] = authors[-1][4..-1] if authors[-1] =~ /^and/
        end

        authors.map { |p| Author.find_or_create_by(name: p).id }.join(",")
      end
  end
end