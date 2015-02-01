class FrontendController < ApplicationController
  private
    def allowed_in_frontend?
      true
    end

    def set_cache_control_headers(age = 24.hours)
      request.session_options[:skip] = true
      response.headers["Cache-Control"] = "public, max-age=#{age}"
    end
end