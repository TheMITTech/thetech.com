namespace :cleanup do
  
  desc "Assigns all images in the database to authors based on attributions, creating new authors if necessary. Ignores many types of malformed authors"
  task assign_images: :environment do

  	i = 0
	Image.find_each do |image| 
	# s = image.attribution.match(/(?<author>.*)(—The Tech)*/)[:author]
	puts "i", i
	i +=1

	if !image.author_id.nil?
		next
	end 

	if image.attribution == "" || image.attribution.match(/courtesy|no attribution|source|©|new york times|20th century fox|universal|records|Recordings|columbia|paramount|entertainment|cinema|disney|.com|—Fox Searchlight Pictures|Warner Bros. Pictures|.org|films|—Flickr|flickr/i)
		puts 'SKIPPED'
		next
	end

	s = image.attribution.gsub(/—The Tech|illustration by |infographic by |–The Tech|-THE TECH|— THE TECH|–The Tech| — THE TECH|—Tech File Photo|—Tech Photo Ilustration|—Tech File Photo|—Tech Photo Illustration|— THE TECH|-THE TECH|–The Tech|— The Tech|—Tech Photo Ilustration/i, "")

	if s.split.size > 4 
		next
	end

	a  = Author.new name: s
	slug_cand = a.normalize_friendly_id(a.name2)


	# if 

	# if a.should_generate_new_friendly_id?
	# 	Author.create name: s
	# else
	# 	a.valid?
	# 	author_cand = Author.where(slug: a.slug).first
	# end




	

	author_cand = Author.where(slug: slug_cand).first
	if !author_cand.nil? 
		image.author_id = author_cand.id
	else
		new_author = Author.create name: s.strip.titleize
		image.author_id = new_author.id
	end

	image.save
end
  end

  desc "removes malformed authors and non-human authors from database"
  task remove_authors: :environment do
  	Author.find_each do |author| 
	if author.name.match(/source|©|new york times|20th century fox|universal|records|Recordings|columbia|paramount|entertainment|cinema|disney|.com|—Tech File Photo|—Tech Photo Illustration|— THE TECH|-THE TECH|–The Tech|— The Tech|—Tech Photo Ilustration|—Fox Searchlight Pictures|Warner Bros. Pictures|.org|films|—Flickr|flickr/i) || author.name.split.size > 4
		author.destroy
	end
end

  desc "fills attribution field of articles with authors_line"
  task remove_authors: :environment do
	Article.find_each do |i|
	 i.attribution = i.authors_line
	 i.save 
	end 
end


end
