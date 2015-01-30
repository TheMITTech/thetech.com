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
      frontend_author_path(obj.slug)
    when Piece, Article, ArticleVersion
      obj.meta(:frontend_display_path)
    end
  end

  def link_to_tag(tag)
    puts ActsAsTaggableOn::Tag.find_by(name: tag).slug
    puts '#'*80
    frontend_tag_path(ActsAsTaggableOn::Tag.find_by(name: tag).slug)
  end

  def display_primary_tag_link(piece)
    text = piece.meta(:primary_tag) ? piece.meta(:primary_tag) : piece.meta(:section_name)
    link = piece.meta(:primary_tag) ? link_to_tag(piece.meta(:primary_tag)) : frontend_section_path(Section.find_by(name: piece.meta(:section_name)))

    link_to text, link, class: 'section primary-tag'
  end
end