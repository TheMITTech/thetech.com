xml.instruct! :xml, :version => "1.0"
xml.rss "version" => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.channel do
    xml.title "The MIT Tech"
    xml.description "MIT's oldest and largest newspaper, providing MIT faculty, staff, and students with continuous news service since 1881. "
    xml.link root_url

    for article in @articles
      draft = article.newest_web_published_draft
      next unless draft

      xml.item do
        xml.title draft.headline
        xml.description draft.lede
        xml.pubDate draft.published_at.to_s(:rfc822)
        xml.link frontend_url(article)
        xml.guid frontend_url(article)

        # Pull all official S3 images attached to the article via Paperclip
        if article.images.any?
          article.images.each do |img|
            if img.respond_to?(:web_photo) && img.web_photo.present?
              image_url = img.web_photo.url
              
              # Fix relative protocol S3 links (//s3.amazonaws.com/...)
              image_url = "https:#{image_url}" if image_url.start_with?("//")
              
              # Using your upgraded media:content tag
              xml.media :content, url: image_url, medium: "image"
            end
          end
        end
        
      end
    end
  end
end
