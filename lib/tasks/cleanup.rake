namespace :cleanup do
  
  desc "Assigns all images in the database to authors based on attributions, creating new authors if necessary. Ignores many types of malformed authors"
  task assign_images: :environment do
  end

  desc "removes malformed authors and non-human authors from database"
  task remove_authors: :environment do
  	Author.find_each do |author| 
	if author.name.match(/source|©|new york times|20th century fox|universal|records|Recordings|columbia|paramount|entertainment|cinema|disney|.com|—Tech File Photo|—Tech Photo Illustration|— THE TECH|-THE TECH|–The Tech|— The Tech|—Tech Photo Ilustration|—Fox Searchlight Pictures|Warner Bros. Pictures|.org|films|—Flickr|flickr/i) || author.name.split.size > 4
		author.destroy
	end
end
  end

end
