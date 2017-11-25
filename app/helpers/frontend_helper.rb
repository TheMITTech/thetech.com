module FrontendHelper
  # Link to the frontend page of the following kinds of objects:
  #   Author, Section, Article, Image, and Tag
  def frontend_path(obj)
    case obj
    when Author
      frontend_author_path(obj.slug)
    when Section
      frontend_section_path(obj.slug)
    when Article
      draft = obj.oldest_web_published_draft
      frontend_article_path(
        draft.published_at.strftime("%Y"),
        draft.published_at.strftime("%m"),
        draft.published_at.strftime("%d"),
        obj.slug
      )
    when Image
      frontend_image_path(obj.id)
    when ActsAsTaggableOn::Tag
      frontend_tag_path(obj.slug)
    when Issue
      frontend_issue_path(volume: obj.volume, number: obj.number)
    else
      raise RuntimeError, "Unsupported class #{obj.class} used with FrontendHelper::frontend_path(). "
    end
  end

  # URL version of #frontend_path
  def frontend_url(obj)
    "#{request.protocol}#{request.host_with_port.sub(/:80$/,"")}#{frontend_path(obj)}"
  end

  def frontend_link_to(obj)
    to = frontend_path(obj)
    case obj
    when Author, Section, ActsAsTaggableOn::Tag
      link_to obj.name, to, class: obj.class.to_s.downcase
    else
      raise RuntimeError, "Unsupported class #{obj.class} used with FrontendHelper::frontend_path(). "
    end
  end

  def frontend_link_to_primary_tag(draft)
    return nil if draft.primary_tag.blank?
    tag = ActsAsTaggableOn::Tag.find_by(name: draft.primary_tag)
    link_to tag.name, frontend_path(tag), class: 'primary-tag'
  end

  def frontend_link_to_static_page(text, name, current)
    options = {}
    options[:class] = 'active' if (name == current || name + '/index' == current)
    link_to text, URI.unescape(frontend_static_page_url(name)), options
  end

  def frontend_link_to_adinfo_page(text, advertiser_type, current)
    options = {}
    options[:class] = 'active' if advertiser_type == current
    link_to text, frontend_adinfo_url(advertiser_type), options
  end

  def author_links(draft)
    authors = draft.authors
    links = authors.map(&method(:frontend_link_to))

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
end
