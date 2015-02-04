module ExternalFrontendUrlHelper
  def external_root_url(*args)
    decorate(Rails.application.routes.url_helpers.root_path(*args))
  end

  def external_frontend_piece_url(*args)
    decorate(Rails.application.routes.url_helpers.frontend_piece_path(*args))
  end

  def external_frontend_author_url(*args)
    decorate(Rails.application.routes.url_helpers.frontend_author_path(*args))
  end

  def external_frontend_section_url(*args)
    decorate(Rails.application.routes.url_helpers.frontend_section_path(*args))
  end

  def external_frontend_tag_url(*args)
    decorate(Rails.application.routes.url_helpers.frontend_tag_path(*args))
  end

  def external_frontend_static_page_url(*args)
    decorate(Rails.application.routes.url_helpers.frontend_static_page_path(*args))
  end

  private
    def decorate(path)
      host = ENV["TECH_APP_FRONTEND_HOSTNAME"]

      if host
        "http://#{host}#{path}"
      else
        path
      end
    end
end
