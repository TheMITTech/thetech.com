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
        
        # --- NEW IMAGE EXTRACTION CODE ---
        # 1. Check if the draft has HTML content
        if draft.respond_to?(:html) && draft.html.present?
          # 2. Use Regex to find the first image tag and capture the src URL
          if first_image_match = draft.html.match(/<img[^>]+src=["']([^"']+)["']/)
            image_url = first_image_match[1]
            
            # 3. Ensure the URL is absolute (handles relative paths like '/images/photo.jpg')
            image_url = "#{root_url.chomp('/')}#{image_url}" if image_url.start_with?('/')
            
            # 4. Inject it into the RSS feed
            xml.enclosure url: image_url, type: "image/jpeg", length: "0"
          end
        end
        # ---------------------------------
      end
    end
  end
end
