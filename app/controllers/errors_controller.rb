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
        render "errors/#{@rescue_response}", code: @status_code, status: @status_code
      else
        yield
      end
    end
end