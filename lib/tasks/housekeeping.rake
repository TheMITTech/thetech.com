namespace :housekeeping do

  desc "Merge upper-case tags with their lower-case correct version. "
  task :downcase_tags => [:environment] do
    count = ActsAsTaggableOn::Tag.count
    done = 0

    ActsAsTaggableOn::Tag.all.each do |tag|
      done += 1
      puts "[%6d / %6d] #{tag.name} with %d taggings" % [done, count, tag.taggings.count]
      next if tag.name.downcase == tag.name

      new_tag = ActsAsTaggableOn::Tag.find_or_create_by(name: tag.name.downcase)
      tag.taggings.update_all(tag_id: new_tag.id)

      tag.destroy!
    end

    puts 'Resetting tagging counter caches'
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end

    puts 'Regenerating tag slugs'
    ActsAsTaggableOn::Tag.find_each do |tag|
      tag.slug = nil
      tag.save!
    end
  end

end