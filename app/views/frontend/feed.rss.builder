xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "The MIT Tech"
    xml.description "MIT's oldest and largest newspaper, providing MIT faculty, staff, and students with continuous news service since 1881. "
    xml.link root_url

    for article in @articles
      draft = article.newest_web_published_draft

      xml.item do
        xml.title draft.headline
        xml.description draft.lede
        xml.pubDate draft.published_at.to_s(:rfc822)
        xml.link frontend_url(article)
        xml.guid frontend_url(article)
        
        # --- S3 IMAGE EXTRACTION CODE ---
        if article.images.any?
          first_image = article.images.first
          
          # We now know the Paperclip attachment is named 'web_photo'
          if first_image.respond_to?(:web_photo) && first_image.web_photo.present?
            
            # Grabbing the raw S3 URL for the image
            image_url = first_image.web_photo.url
            
            # Fix relative protocol S3 links (e.g., //s3.amazonaws.com/...)
            image_url = "https:#{image_url}" if image_url.start_with?("//")
            
            xml.enclosure url: image_url, type: "image/jpeg", length: "0"
          end
        end
        # ---------------------------------
      end
    end
  end
end
