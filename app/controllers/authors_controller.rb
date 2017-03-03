class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update]

  # TODO: Authorization?

  def index
    @authors = Author.all

    respond_to do |format|
      format.html
      format.json { render json: @authors.to_json(only: [:id, :name]) }
    end
  end

  def show
    @articles = @author.drafts.map(&:article).uniq
  end

  def new
    @author = Author.new
  end

  def edit
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      respond_to do |f|
        f.html { redirect_to @author, flash: {success: "You have successfully created an author. "} }
        f.js
      end
    else
      @errors = @author.errors.full_messages.join("\n")

      respond_to do |f|
        f.html do
          @flash[:error] = @errors
          render 'new'
        end

        f.js
      end
    end
  end

  def update
    if @author.update(author_params)
      redirect_to @author, flash: {success: "You have successfully updated the author. "}
    else
      @flash[:error] = @author.errors.full_messages.join("\n")
      render 'edit'
    end
  end

  private
    def set_author
      @author = Author.friendly.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :email, :bio, :portrait, :twitter)
    end
end
