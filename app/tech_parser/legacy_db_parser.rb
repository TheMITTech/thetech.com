module TechParser
  class LegacyDBParser
    def log_entry(message)
      puts message
      File.open('/tmp/legacy_import.log', 'a+') { |f| f.puts message }
    end

    def initialize(host, username, password, db)
      @client = Mysql2::Client.new(host: host, username: username, password: password, database: db)
    end

    def import!(options)
      File.write('/tmp/legacy_import.log', '')

      import_sections
      import_issues(options)
      import_legacyhtml if options[:legacy_html].to_i > 0

      reset_pk_sequences
    end

    def import_legacyhtml!
      import_legacyhtml
      reset_pk_sequences
    end

    def import_legacy_images!
      import_legacy_images
      reset_pk_sequences
    end

    private
      def reset_pk_sequences
        log_entry "Resetting PK sequences"

        User.reset_pk_sequence!
        Article.reset_pk_sequence!
        Image.reset_pk_sequence!
        Piece.reset_pk_sequence!
        Author.reset_pk_sequence!
        Section.reset_pk_sequence!
        ActsAsTaggableOn::Tag.reset_pk_sequence!
        ActsAsTaggableOn::Tagging.reset_pk_sequence!
        Issue.reset_pk_sequence!
        Authorship.reset_pk_sequence!
        ArticleVersion.reset_pk_sequence!
        LegacyPage.reset_pk_sequence!
        Picture.reset_pk_sequence!
        ArticleList.reset_pk_sequence!
        Homepage.reset_pk_sequence!
        LegacyComment.reset_pk_sequence!
      end

      def import_pdf(i)
        issue = Issue.find(i['idissues'].to_i)

        log_entry "  Importing PDF file. "

        tmp_file = '/tmp/tech_pdf.pdf'

        command = "rm -f #{tmp_file}"
        `#{command}`

        command = "scp tech:/srv/www/tech/V#{issue.volume}/PDF/V#{issue.volume}-N#{issue.number}.pdf #{tmp_file}"
        `#{command}`

        if File.exists?(tmp_file)
          issue.pdf = File.open(tmp_file)
          issue.save
        else
          log_entry "    Not found. "
        end
      end

      def import_comments(obj_type, obj_id, piece_id)
        count = 0

        comments = @client.query("SELECT * FROM comments WHERE obj_id = #{obj_id} AND obj_type = #{obj_type}")

        return if comments.size == 0

        comments.each do |c|
          LegacyComment.find_by(id: c['id'].to_i).try(:destroy)
          LegacyComment.create do |com|
            com.id = c['id'].to_i
            com.piece_id = piece_id
            com.author_email = c['auth_email']
            com.author_name = c['auth_name']
            com.published_at = Time.zone.at(c['publish_time'].to_i) if c['publish_time']
            com.ip_address = c['post_ip']
            com.content = c['comment']

            com.created_at = Time.zone.at(c['post_time'].to_i)
            com.updated_at = Time.zone.at(c['post_time'].to_i)
          end

          count += 1
        end

        puts "    #{count} comment(s) imported. "
      end

      def import_legacy_images(i)
        volume = i['volume'].to_i
        issue = i['issue'].to_i

        tmp_dir = '/tmp/tech_graphics'

        `rm -rf /tmp/tech_graphics`
        `mkdir /tmp/tech_graphics`

        command = "scp -r tech:/srv/www/tech/V#{volume}/N#{issue}/graphics/* #{tmp_dir}"
        `#{command}`

        graphics = @client.query("SELECT * FROM graphics WHERE IssueID = #{i['idissues']}")

        count = 0

        graphics.each do |g|
          count += 1
          g_id = g['idgraphics'].to_i + 200000

          cap = Nokogiri::HTML.fragment(g['caption']).text

          Piece.find_by(id: g_id).try(:destroy)
          Piece.create do |pie|
            pie.id = g_id
            pie.section_id = g['SectionID'].to_i
            pie.issue_id = g['IssueID'].to_i
            tag = g['phototag'].gsub(' ', '-').chars.select { |x| /[0-9A-Za-z-]/.match(x) }.join
            pie.slug = "embedded-graphics-#{tag}-V#{volume}-N#{issue}".downcase

            pie.created_at = Issue.find(g['IssueID'].to_i).published_at.to_datetime
            pie.updated_at = Issue.find(g['IssueID'].to_i).published_at.to_datetime
          end

          Image.find_by(id: g['idgraphics'].to_i).try(:destroy)
          image = Image.create do |img|
            img.id = g_id
            img.caption = cap
            img.attribution = Nokogiri::HTML.fragment(g['credit']).text
            img.primary_piece_id = g_id

            img.created_at = img.updated_at = Issue.find(g['IssueID'].to_i).published_at.to_datetime
          end

          Picture.find_by(id: g_id).try(:destroy)
          Picture.create do |pic|
            pic.id = g_id
            pic.image_id = pic.id

            if File.exists?(File.join(tmp_dir, g['filename']))
              pic.content = File.open(File.join(tmp_dir, g['filename']))
            else
              pic.content = File.open(File.join(Rails.root, 'public/image_not_found.png'))
              log_entry "    #{g['filename']} not found. "
            end

            pic.created_at = pic.updated_at = Issue.find(g['IssueID'].to_i).published_at.to_datetime
          end

          image.pieces << Article.find(g['ArticleID'].to_i).piece

          import_comments(2, g['idgraphics'].to_i, g_id)
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

        log_entry "  #{count} images imported. "

        boxpics = @client.query("SELECT * FROM boxpics WHERE IssueID = #{i['idissues']}")

        count = 0

        boxpics.each do |b|
          id = b['idboxpics'].to_i + 70000

          issue = Issue.find(b['IssueID'].to_i)

          Piece.find_by(id: id).try(:destroy)
          piece = Piece.create do |pie|
            pie.id = id
            pie.section_id = b['SectionID'].to_i
            pie.issue_id = b['IssueID'].to_i
            tag = b['phototag'].gsub(' ', '-').chars.select { |x| /[0-9A-Za-z-]/.match(x) }.join
            pie.slug = "graphics-#{tag}-V#{issue.volume}-N#{issue.number}".downcase

            pie.created_at = issue.published_at.to_datetime
            pie.updated_at = issue.published_at.to_datetime
          end

          Image.find_by(id: id).try(:destroy)
          image = Image.create do |img|
            img.id = id
            img.caption = Nokogiri::HTML.fragment(b['caption']).text
            img.attribution = Nokogiri::HTML.fragment(b['credit']).text

            img.created_at = img.updated_at = issue.published_at.to_datetime
          end

          Picture.find_by(id: id).try(:destroy)
          picture = Picture.create do |pic|
            pic.id = id
            pic.image_id = id

            if File.exists?(File.join(tmp_dir, b['filename']))
              pic.content = File.open(File.join(tmp_dir, b['filename']))
            else
              pic.content = File.open(File.join(Rails.root, 'public/image_not_found.png'))
              log_entry "    #{b['filename']} not found. "
            end

            pic.created_at = pic.updated_at = issue.published_at.to_datetime
          end

          piece.image = image
          piece.save
          image.save

          count += 1

          import_comments(3, b['idboxpics'].to_i, id)
        end

        log_entry "  #{count} box images imported. "
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

          log_entry "Imported #{count} legacy pages. " if count % 100 == 0
        end

        log_entry "Imported #{count} legacy pages. "
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

        log_entry "Imported #{sections.count} sections. "
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
          ActsAsTaggableOn::Tag.delete_all
          ActsAsTaggableOn::Tagging.delete_all

          ActiveRecord::Base.connection.execute("DELETE FROM images_pieces")
          ActiveRecord::Base.connection.execute("DELETE FROM images_users")
        end

        log_entry "Briefly disabling timestamping"
        Article.record_timestamps = false
        Piece.record_timestamps = false
        ArticleVersion.record_timestamps = false
        Issue.record_timestamps = false
        Image.record_timestamps = false
        Picture.record_timestamps = false

        issues.to_a.reverse.each do |i|
          count += 1

          next if count <= options[:skip]

          log_entry "Importing volume #{i['volume']} issue #{i['issue']}, count #{count}"

          begin
            issue = Issue.find(i['idissues'].to_i)

            log_entry "  Destroying current issue. "

            issue.pieces.each do |p|
              if p.article
                p.article.article_versions.each(&:destroy)

                p.article.asset_images.each do |i|
                  i.pictures.each(&:destroy)
                  i.destroy
                end
                p.article.destroy
              end

              if p.image
                p.image.pictures.each(&:destroy)
                p.image.destroy
              end
            end

            issue.destroy
          rescue ActiveRecord::RecordNotFound
          end

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

        log_entry "Reenabling timestamping"
        Article.record_timestamps = true
        Piece.record_timestamps = true
        ArticleVersion.record_timestamps = true
        Issue.record_timestamps = true
        Image.record_timestamps = true
        Picture.record_timestamps = true

        log_entry "#{realcount} issues imported. "
      end

      def import_articles(i)
        articles = @client.query('SELECT * FROM articles WHERE IssueID = ' + i['idissues'].to_s + ' ORDER BY idarticles ASC')

        count = 0

        articles.each do |a|
          count += 1

          issue = Issue.find(a['IssueID'].to_i)

          Piece.find_by(id: a['idarticles'].to_i).try(:destroy)
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

            fp = a['headline'].split(':').first
            pie.primary_tag = fp if (fp =~ /[A-Z ]*/ && a['headline'].split(':').count >= 2)

            pie.created_at = issue.published_at.to_datetime
            pie.updated_at = issue.published_at.to_datetime
          end

          piece.created_at = issue.published_at.to_datetime
          piece.updated_at = issue.published_at.to_datetime
          piece.save

          Article.find_by(id: a['idarticles'].to_i).try(:destroy)
          article = Article.create do |art|
            art.piece_id = art.id = a['idarticles'].to_i
            art.headline = HTMLEntities.new.decode(a['headline'])
            art.subhead = HTMLEntities.new.decode(a['subhead'])
            art.author_ids = parse_author_line(a['byline'])
            art.bytitle = HTMLEntities.new.decode(a['bytitle'])
            art.html = a['body']
            art.rank = a['rank'].to_i
            art.lede = HTMLEntities.new.decode(a['lede'])

            fp = a['headline'].split(':').first
            art.headline = a['headline'].split(':').drop(1).join(':') if (fp =~ /^[A-Z ]*$/ && a['headline'].split(':').count >= 2)

            art.headline = HTMLEntities.new.decode(art.headline)
          end

          article.created_at = issue.published_at.to_datetime
          article.updated_at = issue.published_at.to_datetime
          article.save

          article.save_version!

          import_comments(1, article.id, article.piece_id)
        end

        log_entry "  #{count} articles imported. "
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