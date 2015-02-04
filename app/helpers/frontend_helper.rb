module FrontendHelper
  def linked_authors_line(authors)
    links = authors.map(&method(:linked_author))

    case authors.size
    when 0
      'Unknown Author'
    when 1
      links.first
    when 2
      "#{links.first} and #{links.last}"
    else
      (links[0...-1] + ["and " + links.last]).join(', ')
    end.html_safe
  end

  def linked_author(author)
    link_to author.name, frontend_path(author)
  end

  def sections(secs)
    secs.uniq!

    case secs.size
    when 0
      ''
    when 1
      secs.first
    when 2
      secs.join ' and '
    else
      (secs[0...-1] + ["and " + secs.last]).join(', ')
    end
  end

  def frontend_path(obj)
    case obj
    when Author
      external_frontend_author_url(obj.slug)
    when Piece, Article, ArticleVersion
      obj.meta(:frontend_display_path)
    end
  end

  def link_to_tag(tag)
    external_frontend_tag_url(ActsAsTaggableOn::Tag.find_by(name: tag).slug)
  end

  def section_link(piece)
    link_to piece.meta(:section_name), external_frontend_section_url(Section.find_by(name: piece.meta(:section_name))), class: 'section'
  end

  def primary_tag_link(piece)
    piece.meta(:primary_tag).nil? ? nil : link_to(piece.meta(:primary_tag), link_to_tag(piece.meta(:primary_tag)), class: 'primary-tag')
  end

  def section_and_primary_tag_link(piece)
    content_tag :p, class: 'section-and-primary-tag' do
      els = [section_link(piece)]
      els += [content_tag(:span, ' | '), primary_tag_link(piece)] if piece.meta(:primary_tag)
      safe_join(els.compact)
      # raise [section_link(piece), primary_tag_link(piece)].compact.to_s
    end
  end

  def link_to_static_page(text, name, current)
    options = {}
    options[:class] = 'active' if name == current
    link_to text, external_frontend_static_page_url(name), options
  end
end