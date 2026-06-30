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

        if draft.respond_to?(:html) && draft.html.present?
          doc = Nokogiri::HTML(draft.html)
          img = doc.at_css("img")
          if img && img["src"].present?
            image_url = img["src"]
            image_url = "#{root_url.chomp('/')}#{image_url}" if image_url.start_with?("/")
            xml.media :content, url: image_url, medium: "image"
          end
        end
      end
    end
  end
end
