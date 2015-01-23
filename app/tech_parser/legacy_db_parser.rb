module TechParser
  class LegacyDBParser
    def initialize(host, username, password, db)
      @client = Mysql2::Client.new(host: host, username: username, password: password, database: db)
    end

    def import!
      import_sections
      import_issues
      import_articles
      import_legacyhtml
    end

    def import_legacyhtml!
      import_legacyhtml
    end

    def import_legacy_images!
      import_legacy_images
    end

    private
      def import_legacy_images
        Picture.destroy_all
        Image.destroy_all

        issues = @client.query('SELECT * FROM issues')

        issues.to_a.reverse.each do |i|
          volume = i['volume'].to_i
          issue = i['issue'].to_i

          puts "Processing volume #{volume} number #{issue}"

          tmp_dir = '/tmp/tech_graphics'

          command = "rm -r #{File.join(tmp_dir, '*')}"
          `#{command}`

          command = "scp -r tech:/srv/www/tech/V#{volume}/N#{issue}/graphics/* #{tmp_dir}"
          `#{command}`

          graphics = @client.query("SELECT idgraphics, ArticleID, filename, credit, caption FROM graphics WHERE IssueID = #{i['idissues']}")

          graphics.each do |g|
            cap = Nokogiri::HTML.fragment(g['caption']).text

            if cap.length < 2
              cap = cap + '---'
              puts 'Caption too short. Changed to ' + cap
            end

            image = Image.create do |img|
              img.id = g['idgraphics'].to_i
              img.caption = cap
              img.attribution = Nokogiri::HTML.fragment(g['credit']).text
            end

            Picture.create do |pic|
              pic.id = g['idgraphics'].to_i
              pic.image_id = pic.id
              pic.content = File.open(File.join(tmp_dir, g['filename']))
            end

            image.pieces << Article.find(g['ArticleID'].to_i).piece
          end

          Issue.find(i['idissues'].to_i).pieces.with_article.each do |p|
            p.article.asset_images.each_with_index do |i, idx|
              if idx == 0
                html = "<img src='#{Rails.application.routes.url_helpers.direct_image_picture_path(i, i.pictures.first)}' style='float: right'>"
                p.article.update(html: html + p.article.html)
              else
                html = "<img src='#{Rails.application.routes.url_helpers.direct_image_picture_path(i, i.pictures.first)}' style='float: right'>"
                p.article.update(html: p.article.html + html)
              end
            end

            p.article.save_version!
          end
        end
      end

      def import_legacyhtml
        count = 0

        legacies = @client.query('SELECT idlegacyhtml, rawcontent, IssueID, archivetag, headline FROM legacyhtml')

        if legacies.count == LegacyPage.count
          puts 'Skipping legacy pages. '
          return
        end

        LegacyPage.delete_all

        legacies.each do |l|
          count += 1

          LegacyPage.create do |leg|
            leg.id = l['idlegacyhtml'].to_i
            leg.html = l['rawcontent']
            leg.issue_id = l['IssueID'].to_i
            leg.archivetag = l['archivetag']
            leg.headline = l['headline']
          end

          puts "Imported #{count} legacy pages. " if count % 100 == 0
        end

        puts "Imported #{count} legacy pages. "
      end

      def import_sections
        Section.delete_all

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
        count = 0

        issues = @client.query('SELECT * FROM issues')

        if issues.count == Issue.count
          puts 'Skipping issues. '
          return
        end

        Issue.delete_all
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
        articles = @client.query('SELECT * FROM articles')

        if articles.count == Article.count
          puts 'Skipping articles. '
          return
        end

        # Piece.delete_all
        # Article.delete_all

        count = 0

        articles.each do |a|
          count += 1

          if Piece.find_by_id(a['idarticles'].to_i).nil?

            issue = Issue.find(a['IssueID'].to_i)

            piece = Piece.create do |pie|
              pie.id = a['idarticles'].to_i
              pie.section_id = a['SectionID'].to_i
              pie.issue_id = a['IssueID'].to_i
              tag = a['archivetag'].gsub(' ', '-').chars.select { |x| /[0-9A-Za-z-]/.match(x) }.join
              if a['parent'].blank?
                pie.slug = "#{tag}-V#{issue.volume}-N#{issue.number}".downcase
              else
                parent = Article.find(a['parent'].to_i)
                parent_archive = /^(.*?)-v(\d+)-n(\d+)$/.match(parent.piece.slug)[1]
                pie.slug = "#{parent_archive}-#{tag}-V#{issue.volume}-N#{issue.number}".downcase
              end
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
          end

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