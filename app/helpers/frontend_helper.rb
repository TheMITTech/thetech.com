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
    link_to author.name, frontend_author_path(author.slug)
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
end