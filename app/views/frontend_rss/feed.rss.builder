xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "The MIT Tech"
    xml.description "MIT's oldest and largest newspaper, providing MIT faculty, staff, and students with continuous news service since 1881. "
    xml.link root_url

    for article in @articles
      xml.item do
        xml.title article.article.latest_published_version.meta(:headline)
        xml.description article.article.latest_published_version.meta(:intro)
        xml.pubDate article.published_at.to_s(:rfc822)
        xml.link article.frontend_display_path
        xml.guid article.frontend_display_path
      end
    end
  end
end