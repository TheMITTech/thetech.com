module TechParser
  class LegacyDBParser
    def initialize(host, username, password, db)
      @client = Mysql2::Client.new(host: host, username: username, password: password, database: db)
    end

    def import!(options)
      import_sections
      import_issues(options)
      import_legacyhtml if options[:legacy_html].to_i > 0
    end

    def import_legacyhtml!
      import_legacyhtml
    end

    def import_legacy_images!
      import_legacy_images
    end

    private
      def import_pdf(i)
        issue = Issue.find(i['idissues'].to_i)

        puts "  Importing PDF file. "

        tmp_file = '/tmp/tech_pdf.pdf'

        command = "rm #{tmp_file}"
        `#{command}`

        command = "scp tech:/srv/www/tech/V#{issue.volume}/PDF/V#{issue.volume}-N#{issue.number}.pdf #{tmp_file}"
        `#{command}`

        if File.exists?(tmp_file)
          issue.pdf = File.open(tmp_file)
          issue.save
        else
          puts "    Not found. "
        end
      end

      def import_legacy_images(i)
        volume = i['volume'].to_i
        issue = i['issue'].to_i

        tmp_dir = '/tmp/tech_graphics'

        command = "rm -r #{File.join(tmp_dir, '*')}"
        `#{command}`

        command = "scp -r tech:/srv/www/tech/V#{volume}/N#{issue}/graphics/* #{tmp_dir}"
        `#{command}`

        graphics = @client.query("SELECT idgraphics, ArticleID, filename, credit, caption, lastupdate FROM graphics WHERE IssueID = #{i['idissues']}")

        count = 0

        graphics.each do |g|
          count += 1

          cap = Nokogiri::HTML.fragment(g['caption']).text

          image = Image.create do |img|
            img.id = g['idgraphics'].to_i
            img.caption = cap
            img.attribution = Nokogiri::HTML.fragment(g['credit']).text

            img.created_at = g['lastupdate']
            img.updated_at = g['lastupdate']
          end

          Picture.create do |pic|
            pic.id = g['idgraphics'].to_i
            pic.image_id = pic.id
            pic.content = File.open(File.join(tmp_dir, g['filename']))


            pic.created_at = g['lastupdate']
            pic.updated_at = g['lastupdate']
          end

          image.pieces << Article.find(g['ArticleID'].to_i).piece
        end

        Issue.find(i['idissues'].to_i).pieces.with_article.each do |p|
          p.article.asset_images.each_with_index do |i, idx|
            if idx == 0
              html = "<img src='#{Rails.application.routes.url_helpers.direct_image_picture_path(i, i.pictures.first)}' style='float: right'>"
              p.article.update(html: html + p.article.html)
            else
              html = "<img src='#{Rails.application.routes.url_helpers.direct_image_picture_path(i, i.pictures.first)}'>"
              p.article.update(html: p.article.html + html)
            end
          end

          p.article.save_version!
        end

        puts "  #{count} images imported. "
      end

      def import_legacyhtml
        count = 0

        legacies = @client.query('SELECT idlegacyhtml, rawcontent, IssueID, archivetag, headline FROM legacyhtml')

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

      def import_issues(options)
        count = 0
        realcount = 0

        issues = @client.query('SELECT * FROM issues')

        options[:skip] ||= 0
        options[:skip] = options[:skip].to_i

        options[:num] ||= 1000000
        options[:num] = options[:num].to_i

        if options[:skip] == 0
          Issue.delete_all
          Article.delete_all
          ArticleVersion.delete_all
          Piece.delete_all
          Picture.delete_all
          Author.delete_all
          Image.delete_all

          ActiveRecord::Base.connection.execute("DELETE FROM images_pieces")
          ActiveRecord::Base.connection.execute("DELETE FROM images_users")
        end

        puts "Briefly disabling timestamping"
        Article.record_timestamps = false
        Piece.record_timestamps = false
        ArticleVersion.record_timestamps = false
        Issue.record_timestamps = false
        Image.record_timestamps = false
        Picture.record_timestamps = false

        issues.to_a.reverse.each do |i|
          count += 1

          next if count <= options[:skip]

          puts "Importing volume #{i['volume']} issue #{i['issue']}"

          Issue.create do |iss|
            iss.id = i['idissues'].to_i
            iss.volume = i['volume'].to_i
            iss.number = i['issue'].to_i
            iss.published_at = i['publishdate']
            iss.created_at = i['publishdate'].to_datetime
            iss.updated_at = i['publishdate'].to_datetime
          end

          import_articles(i)
          import_legacy_images(i)
          import_pdf(i)

          realcount += 1
          break if realcount == options[:num]
        end

        puts "Reenabling timestamping"
        Article.record_timestamps = true
        Piece.record_timestamps = true
        ArticleVersion.record_timestamps = true
        Issue.record_timestamps = true
        Image.record_timestamps = true
        Picture.record_timestamps = true

        puts "#{realcount} issues imported. "
      end

      def import_articles(i)
        articles = @client.query('SELECT * FROM articles WHERE IssueID = ' + i['idissues'].to_s)

        count = 0

        articles.each do |a|
          count += 1

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

          piece.created_at = issue.published_at.to_datetime
          piece.updated_at = a['lastupdate']
          piece.save

          article = Article.create do |art|
            art.piece_id = art.id = a['idarticles'].to_i
            art.headline = a['headline']
            art.subhead = a['subhead']
            art.author_ids = parse_author_line(a['byline'])
            art.bytitle = a['bytitle']
            art.html = a['body']
          end

          article.created_at = issue.published_at.to_datetime
          article.updated_at = a['lastupdate']
          article.save

          article.save_version!
        end

        puts "  #{count} articles imported. "
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