module ArticleXmlExportable
  extend ActiveSupport::Concern

  # array of strings
  ARTICLE_PARTS = %w(primary_tag headline subhead byline bytitle body)

  CHUNK_MAPPING = {
    'p' => 'p',
    'h2' => 'h2',
    # map h3 to h2 for now
    'h3' => 'h2'
  }

  def as_xml(parts)
    parts ||= ARTICLE_PARTS # if no parts specified take everything
    parts_to_take = ARTICLE_PARTS & parts # intersection

    assign_attributes(latest_article_version.article_attributes)

    content = "<document>\n"

    content += metadata_xml

    content += "<content>\n"

    content += primary_tag_xml if parts_to_take.include?('primary_tag')
    content += headline_xml if parts_to_take.include?('headline')
    content += subhead_xml if parts_to_take.include?('subhead')
    content += byline_xml if parts_to_take.include?('byline')
    content += bytitle_xml if parts_to_take.include?('bytitle')

    if parts_to_take.include?('body')
      chunks.each do |chunk_node|
        chunk = Nokogiri::HTML.fragment(chunk_node)
        fc = chunk.children.first

        next unless CHUNK_MAPPING.key? fc.name.to_s
        content += "<#{CHUNK_MAPPING[fc.name.to_s]}>"
        fc.children.each do |c|
          next if c.text.blank?
          case c.name.to_sym
          when :text
            content += c.text
          when :a
            content += c.content
          when :em
            content += "<em>#{c.text}</em>"
          when :strong
            content += "<strong>#{c.text}</strong>"
          end
        end        
        content += "</#{CHUNK_MAPPING[fc.name]}>\n"
      end
    end

    content += "</content>\n</document>"
    content
  end

  private

  def latest_article_version
    print_version || latest_version
  end

  def metadata_xml
"  <metadata>
    <section>#{piece.section.name}</section>
    <primary_tag>#{piece.primary_tag}</primary_tag>
    <id>#{latest_article_version.id}</id>
  </metadata>\n"
  end

  def primary_tag_xml
    return '' if piece.primary_tag.blank?
    "<primary_tag>#{piece.primary_tag}</primary_tag>\n"
  end

  def headline_xml
    return '' if headline.blank?
    "<headline>#{headline}</headline>\n"
  end

  def subhead_xml
    return '' if subhead.blank?
    "<subhead>#{subhead}</subhead>\n"
  end

  def byline_xml
    return '' if authors_line.blank?
    "<byline>#{authors_line}</byline>\n"
  end

  def bytitle_xml
    return '' if bytitle.blank?
    "<bytitle>#{bytitle}</bytitle>\n"
  end
end
