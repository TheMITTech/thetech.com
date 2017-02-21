# encoding utf-8

require 'nokogiri'
require_relative '../../app/techplater/parser'

namespace :rebirth do
  desc "Collection of tasks for migrating the database to post-REBIRTH era. "

  def strip_images(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css('img').remove
    doc.to_html
  end

  task migrate: :environment do
    puts "Migrating #{PreRebirthImage.count} images"

    image_id_map = {}

    Image.record_timestamps = false
    Article.record_timestamps = false
    Draft.record_timestamps = false

    puts "Destroying all Image-s"
    Image.destroy_all

    PreRebirthImage.all.each do |i|
      puts "Migrating image with ID #{i.id}, captioned '#{i.caption.strip.truncate(80)}'"

      image = Image.new({
        issue_id: i.associated_piece.issue_id,
        caption: i.caption,
        attribution: i.attribution,
        author_id: i.author_id,
        created_at: i.created_at,
        updated_at: i.updated_at,
        published_at: i.updated_at,
        web_status: i.web_status,
        print_status: i.print_status
      })

      image.web_photo = i.pictures[0].content
      image.save!

      image_id_map[i.id] = image.id
    end

    puts "Migrating #{PreRebirthArticle.count} articles"

    puts "Destroying all Article-s and Draft-s"
    Article.destroy_all
    Draft.destroy_all

    def check_nil(value, default_value)
      value.nil? ?
        default_value :
        value
    end

    PreRebirthArticle.all.each do |a|
      puts "Migrating article with ID #{a.id}, titled '#{a.headline}'"

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

      new_article.image_ids = a.piece.pre_rebirth_image_ids.map { |pri| image_id_map[pri] }
      new_article.save!
      puts "  Associating the article with #{a.piece.pre_rebirth_image_ids.count} images. "

      a.article_versions.each do |av|
        puts "  Migrating version with ID #{av.id}"

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

        new_draft.authors << article.author_ids.split(',').map { |i| Author.find(i.strip.to_i) }
      end
    end

    Image.record_timestamps = true
    Article.record_timestamps = true
    Draft.record_timestamps = true

    puts "Migration complete"
  end
end