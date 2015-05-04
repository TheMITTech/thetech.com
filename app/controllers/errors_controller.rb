class ErrorsController < ApplicationController
  include Gaffe::Errors

  protected
    def allowed_in_frontend?
      true
    end
end