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
    parts ||= ARTICLE_PARTS               # if no parts specified take everything
    parts_to_take = ARTICLE_PARTS & parts # intersection

    content = "<document>\n"
    content += metadata_xml
    content += "<content>\n"

    content += primary_tag_xml if parts_to_take.include?('primary_tag')
    content += headline_xml if parts_to_take.include?('headline')
    content += subhead_xml if parts_to_take.include?('subhead')
    content += byline_xml if parts_to_take.include?('byline')
    content += bytitle_xml if parts_to_take.include?('bytitle')

    if parts_to_take.include?('body')
      self.xml_export_draft.chunks.each do |chunk_node|
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

  def xml_export_draft
    self.newest_print_ready_draft ||
    self.newest_web_published_draft ||
    self.newest_web_ready_draft ||
    self.newest_draft
  end

  private

  def metadata_xml
    draft = self.xml_export_draft

    "
      <metadata>
        <section>#{self.section.name.encode(xml: :text)}</section>
        <primary_tag>#{draft.primary_tag.try(:encode, xml: :text)}</primary_tag>
        <id>#{draft.id.to_s.encode(xml: :text)}</id>
      </metadata>\n
    "
  end

  def primary_tag_xml
    draft = self.xml_export_draft
    return '' if draft.primary_tag.blank?
    "<primary_tag>#{draft.primary_tag.encode(xml: :text)}</primary_tag>\n"
  end

  def headline_xml
    draft = self.xml_export_draft
    return '' if draft.headline.blank?
    "<headline>#{draft.headline.encode(xml: :text)}</headline>\n"
  end

  def subhead_xml
    draft = self.xml_export_draft
    return '' if draft.subhead.blank?
    "<subhead>#{draft.subhead.encode(xml: :text)}</subhead>\n"
  end

  def byline_xml
    draft = self.xml_export_draft
    return '' if draft.authors_string.blank?
    "<byline>By #{draft.authors_string.encode(xml: :text)}</byline>\n"
  end

  def bytitle_xml
    draft = self.xml_export_draft
    return '' if draft.bytitle.blank?
    "<bytitle>#{draft.bytitle.encode(xml: :text)}</bytitle>\n"
  end
end
