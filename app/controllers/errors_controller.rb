class ErrorsController < ApplicationController
  include Gaffe::Errors

  around_filter :redirect_404

  protected
    def allowed_in_frontend?
      true
    end

  private
    def redirect_404
      if @status_code == 404
        return redirect_to ENV['LEGACY_REDIRECT_DOMAIN_NAME'] + request.original_fullpath
      else
        yield
      end
    end
end