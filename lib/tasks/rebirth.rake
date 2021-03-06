# encoding utf-8

require 'nokogiri'
require_relative '../../app/techplater/parser'

namespace :rebirth do
  desc "Collection of tasks for migrating the database to post-REBIRTH era. "

  PICTURE_STYLE_MAPPINGS = {
    original: :original,
    square: :square,
    thumbnail: :thumbnail,
    large: :web,
  }

  OUTPUT_MOVE_FILE = true
  OUTPUT_ID_MAPPING = true

  def strip_images(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css('img').remove
    doc.to_html
  end

  def migrate_articles(issue)
    def check_nil(value, default_value)
      value.nil? ?
        default_value :
        value
    end

    objs = Piece.where(issue_id: issue.id).map(&:article).compact
    count = objs.count
    done = 0
    objs.each do |a|
      done += 1
      print ("[%5d / %5d] " % [done, count]) + "Article #{a.id}. "

      new_article = Article.create!({
        slug: a.piece.slug,
        section_id: a.piece.section_id,
        issue_id: a.piece.issue_id,
        rank: a.rank,
        syndicated: check_nil(a.piece.syndicated, false),
        allow_ads: check_nil(a.piece.allow_ads, true),
        created_at: a.created_at,
        updated_at: a.updated_at
      })

      new_article.image_ids = a.piece.pre_rebirth_image_ids.map { |pri| @image_id_map[pri] }
      new_article.save!
      print "Images: #{a.piece.pre_rebirth_image_ids.map(&:to_s).join(' ')}. " unless a.piece.pre_rebirth_image_ids.empty?
      print "Versions: "

      errors = []

      a.article_versions.each do |av|
        print "#{av.id} "

        article = PreRebirthArticle.new
        article.assign_attributes(av.article_attributes)

        piece = Piece.new
        piece.assign_attributes(av.piece_attributes)

        stripped_html = strip_images(article.html)
        parser = Techplater::Parser.new(stripped_html)
        parser.parse!

        new_draft = new_article.drafts.create!({
          headline: article.headline,
          subhead: article.subhead,
          bytitle: article.bytitle,
          lede: article.lede,
          attribution: article.attribution || "",
          notes: article.sandwich_quotes || "",
          redirect_url: piece.redirect_url || "",
          chunks: parser.chunks,
          html: stripped_html,
          web_template: parser.template,
          web_status: av.web_status,
          print_status: av.print_status,
          user_id: User.first.id,
          tag_list: piece.my_tag_list,
          created_at: av.created_at,
          updated_at: av.updated_at,
          published_at: av.updated_at
        })

        new_draft.authors << article.author_ids.split(',').map do |i|
          begin
            Author.find(i.strip.to_i)
          rescue ActiveRecord::RecordNotFound
            errors << "Cannot find author with ID #{i.strip.to_i}"
            nil
          end
        end.compact
      end

      @article_id_map[a.id] = new_article.id
      puts
      errors.each { |e| puts "[    ERROR    ] #{e}" }
      puts "[   MAPPING   ] Article %d => %d" % [a.id, new_article.id] if OUTPUT_ID_MAPPING
    end
  end

  def migrate_images(issue)
    pieces = Piece.where(issue_id: issue.id)
    ids = []

    pieces.each do |p|
      ids += p.pre_rebirth_images.map(&:id)
      ids << p.image.try(:id)
    end

    ids.compact!

    return if ids.empty?

    objs = PreRebirthImage.find(ids.uniq)
    count = objs.count
    done = 0
    objs.each do |i|
      done += 1
      puts ("[%5d / %5d] " % [done, count]) + "Image #{i.id}."

      if i.pictures.empty?
        puts "[    ERROR    ] Image #{i.id} has no pictures."
        next
      end

      image = Image.new({
        issue_id: i.associated_piece.issue_id,
        caption: i.caption,
        attribution: i.attribution,
        author_id: i.author_id,
        created_at: i.created_at,
        updated_at: i.updated_at,
        published_at: i.updated_at,
        web_status: i.web_status,
        print_status: i.print_status,
        web_photo_file_name: i.pictures[0].content_file_name,
        web_photo_content_type: i.pictures[0].content_content_type,
        web_photo_file_size: i.pictures[0].content_file_size,
        web_photo_updated_at: i.pictures[0].content_updated_at,
      })

      image.save!

      PICTURE_STYLE_MAPPINGS.each do |k, v|
        puts "[  MOVE FILE  ] %s => %s" % [i.pictures[0].content.path(k), image.web_photo.path(v)] if OUTPUT_MOVE_FILE
      end

      @image_id_map[i.id] = image.id
      puts "[   MAPPING   ] Image %d => %d" % [i.id, image.id] if OUTPUT_ID_MAPPING
    end
  end

  def migrate_legacy_comments(issue)
    objs = Piece.where(issue_id: issue.id).map(&:legacy_comments).flatten
    count = objs.count
    done = 0
    objs.each do |c|
      done += 1
      puts ("[%5d / %5d] " % [done, count]) + "LegacyComment #{c.id}. "

      obj = c.piece.article.present? ?
        Article.find(@article_id_map[c.piece.article.id]) :
        Image.find(@image_id_map[c.piece.image.id])

      obj.legacy_comments << LegacyComment.create!({
        author_email: c.author_email,
        author_name: c.author_name,
        published_at: c.published_at,
        created_at: c.created_at,
        updated_at: c.updated_at,
        ip_address: c.ip_address,
        content: c.content,
      })
    end
  end

  def migrate_homepages
    puts @article_id_map.inspect

    count = Homepage.all.count
    done = 0
    Homepage.all.each do |homepage|
      done += 1
      puts ("[%5d / %5d] " % [done, count]) + "Homepage #{homepage.id}. "

      layout = homepage.layout

      layout.each do |row|
        row[:modules].each do |mod|
          mod[:submodules].each do |submod|
            case submod[:type].to_sym
            when :article
              piece = Piece.find_by(id: submod[:piece])
              puts "[    ERROR    ] Cannot find piece with ID #{submod[:piece]}." if piece.nil?
              new_article = Article.find_by(id: @article_id_map[piece.article.id]) if piece.present?
              puts "[    ERROR    ] Cannot find new article with old ID #{piece.article.id}." if new_article.nil?
              submod[:article_id] = new_article.id if new_article.present?
            when :img, :img_nocaption
              picture = Picture.find_by(id: submod[:picture])
              puts "[    ERROR    ] Cannot find picture with ID #{submod[:picture]}." if picture.nil?
              new_image = Image.find_by(id: @image_id_map[picture.image.id]) if picture.present?
              (puts "[    ERROR    ] Cannot find new image with old ID #{picture.image.id}." and next) if new_image.nil?
              submod[:image_id] = new_image.id if new_image.present?
            when :links
              puts "[    ERROR    ] Ignoring :links module." and next if piece.nil?
            else
              puts "[    ERROR    ] Unexpected module type #{submod[:type].to_sym}." and next if piece.nil?
            end
          end
        end
      end

      homepage.update!(layout: layout)
    end
  end

  task :migrate, [:resume] => [:environment] do |t, args|
    @image_id_map = {}
    @article_id_map = {}

    Image.record_timestamps = false
    Article.record_timestamps = false
    Draft.record_timestamps = false
    LegacyComment.record_timestamps = false

    resume = args[:resume]

    if resume.present?
      issue = Issue.find(resume)
      issue.articles.each(&:really_destroy!)
      issue.images.each(&:really_destroy!)
    else
      Image.delete_all
      Article.delete_all
      Draft.delete_all
      LegacyComment.delete_all

      ActiveRecord::Base.connection.execute("DELETE FROM authors_drafts")
      ActiveRecord::Base.connection.execute("DELETE FROM articles_images")
    end

    Issue.unscoped.all.order('id ASC').each do |i|
      puts "=================== #{i.id}: #{i.name} ==================="

      next if resume.present? && i.id < resume.to_i

      migrate_images(i)
      migrate_articles(i)
      migrate_legacy_comments(i)
    end

    migrate_homepages

    puts "Reindexing Article-s"
    Article.reindex

    puts "Reindexing Image-s"
    Image.reindex

    Image.record_timestamps = true
    Article.record_timestamps = true
    Draft.record_timestamps = true
    LegacyComment.record_timestamps = true

    puts "Migration complete"
  end

  desc "Migrate user roles to use the new format. "
  task migrate_roles: [:environment] do
    User.find_each do |u|
      roles = []

      u.legacy_roles.each do |r|
        roles << UserRole::LEGACY_MAPPING[r.value]
      end

      roles.uniq!
      roles.compact!

      puts "%-30s %s" % [u.name, roles.inspect]

      u.roles = roles
      u.save!
    end
  end
end