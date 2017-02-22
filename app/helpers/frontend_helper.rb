module FrontendHelper
  # REBIRTH

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
    "#{request.protocol}#{request.host_with_port.sub(/:80$/,"")}/#{frontend_path(obj)}"
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
    link_to text, URI.unescape(external_frontend_static_page_url(name)), options
  end

  def frontend_link_to_adinfo_page(text, advertiser_type, current)
    options = {}
    options[:class] = 'active' if advertiser_type == current
    link_to text, external_frontend_adinfo_url(advertiser_type), options
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

  # OLD =========================================

  # def linked_photographer(author)
  #   link_to author.name, external_frontend_photographer_url(author)
  # end

  # def sections(secs)
  #   secs.uniq!

  #   if secs.first.is_a? Fixnum
  #     secs = secs.map { |i| Section.find(i).name }
  #   end

  #   case secs.size
  #   when 0
  #     ''
  #   when 1
  #     secs.first
  #   when 2
  #     secs.join ' and '
  #   else
  #     (secs[0...-1] + ["and " + secs.last]).join(', ')
  #   end
  # end

  # def link_to_tag(tag)
  #   external_frontend_tag_url(ActsAsTaggableOn::Tag.find_by(name: tag).slug)
  # end



  # def primary_tag_link(draft)
  # end

  # def section_and_primary_tag_link(piece)
  #   content_tag :p, class: 'section-and-primary-tag' do
  #     els = [section_link(piece)]
  #     els += [content_tag(:span, ' | '), primary_tag_link(piece)] if piece.meta(:primary_tag)
  #     safe_join(els.compact)
  #     # raise [section_link(piece), primary_tag_link(piece)].compact.to_s
  #   end
  # end

  # def wicon_name(icon, sun_set)
  #   if Time.now < sun_set # day
  #     case icon
  #     when 'fog'
  #       "fog"
  #     when 'hazy'
  #       "dust"
  #     when 'mostlycloudy'
  #       "cloudy"
  #     when 'mostlysunny'
  #       "day-sunny-overcast"
  #     when 'partlycloudy', 'partlysunny'
  #       "day-cloudy"
  #     when 'rain'
  #       "rain"
  #     when 'sleet'
  #       "sleet"
  #     when 'flurries', 'snow'
  #       "snow"
  #     when 'clear', 'sunny'
  #       "day-sunny"
  #     when 'tstorms'
  #       "thunderstorm"
  #     when 'cloudy'
  #       "cloudy"
  #     else
  #       ""
  #     end
  #   else # night
  #     case icon
  #     when 'fog'
  #       "night-fog"
  #     when 'hazy'
  #       "dust"
  #     when 'mostlycloudy'
  #       "cloudy"
  #     when 'mostlysunny', 'partlycloudy', 'partlysunny'
  #       "night-cloudy"
  #     when 'rain'
  #       "night-rain"
  #     when 'sleet'
  #       "night-sleet"
  #     when 'flurries', 'snow'
  #       "night-snow"
  #     when 'clear'
  #       "night-clear"
  #     when 'tstorms'
  #       "night-thunderstorm"
  #     when 'cloudy'
  #       "night-cloudy"
  #     else
  #       ""
  #     end
  #   end
  # end
end