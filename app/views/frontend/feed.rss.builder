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
      end
    end
  end
end