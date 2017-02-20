# encoding utf-8

namespace :rebirth do
  desc "Collection of tasks for migrating the database to post-REBIRTH era. "

  task migrate_images: :environment do
    puts "Migrating #{Image.count} images"

    puts "Destroying all RbImage-s"
    RbImage.destroy_all

    RbImage.record_timestamps = false

    Image.all.each do |i|
      puts "Migrating image with ID #{i.id}, captioned '#{i.caption.strip.truncate(80)}'"

      image = RbImage.new({
        issue_id: i.associated_piece.issue_id,
        caption: i.caption,
        attribution: i.attribution,
        author_id: i.author_id,
        created_at: i.created_at,
        updated_at: i.updated_at,
      })

      image.web_photo = i.pictures[0].content
      image.save!
    end

    RbImage.record_timestamps = true

    puts "Migration complete"
  end
end