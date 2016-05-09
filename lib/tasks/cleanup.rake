namespace :cleanup do
  
  desc "Assigns all images in the database to authors based on attributions, creating new authors if necessary. Ignores many types of malformed authors"
  task assign_images: :environment do

  	i = 1
	Image.find_each do |image| 
	# s = image.attribution.match(/(?<author>.*)(—The Tech)*/)[:author]
	puts "i %d" % i 
	i +=1

	if !image.author_id.nil?
		puts 'Has author'
		next
	end 

	if image.attribution == "" || image.attribution.match(/courtesy|no attribution|source|©|new york times|20th century fox|universal|records|Recordings|columbia|paramount|entertainment|cinema|disney|.com|—Fox Searchlight Pictures|Warner Bros. Pictures|.org|films|—Flickr|flickr/i)
		puts 'SKIPPED' + image.attribution 
		next
	end

	s = image.attribution.gsub(/—The Tech|illustration by |infographic by |–The Tech|-THE TECH|— THE TECH|–The Tech| — THE TECH|—Tech File Photo|—Tech Photo Ilustration|—Tech File Photo|—Tech Photo Illustration|— THE TECH|-THE TECH|–The Tech|— The Tech|—Tech Photo Ilustration/i, "")

	if s.split.size > 4 
		next
	end

	a  = Author.new name: s
	slug_cand = a.normalize_friendly_id(a.name)

	author_cand = Author.where(slug: slug_cand).first
	if !author_cand.nil? 
		image.author_id = author_cand.id
	else
		STDOUT.puts "Create new author? (y/n)  " + s.strip.titleize
		input = STDIN.gets.strip
		if input == 'y'
			new_author = Author.create name: s.strip.titleize
			image.author_id = new_author.id
			puts 'Created'
		elsif input == 'n'
			puts "Skipping"
		end
	end

	image.save
   end
 end

  desc "removes malformed authors and non-human authors from database"
  task remove_authors: :environment do
  	Author.find_each do |author| 
  		if author.name.match(/new york times/i)
  			puts "EVIL NEW YORK TIMES"
  			author.destroy
  			next
  		end

		if author.name.match(/courtesy|source|©|new york times|20th century fox|universal|records|pictures|Recordings|columbia|paramount|entertainment|cinema|disney|.com|—Tech File Photo|—Tech Photo Illustration|— THE TECH|-THE TECH|–The Tech|— The Tech|—Tech Photo Ilustration|—Fox Searchlight Pictures|Warner Bros. Pictures|.org|films|—Flickr|flickr/i) || author.name.split.size > 3 || author.name.match(/^—/) 
			STDOUT.puts "Destroy? (y/n)  " + author.name.strip
			input = STDIN.gets.strip
			if input == 'y'
				author.destroy
				puts 'Destroyed'
			elsif input == 'n'
				puts "Skipping"
			end
		end
	end

 end

  desc "fills attribution field of articles with authors_line"
  task fill_attributions: :environment do
	Article.find_each do |a|
		a.attribution = a.authors_line
		
		a.save_version!
	end

 end


end
