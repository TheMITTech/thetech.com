class ImagesController < ApplicationController
  before_action :prepare_authors_json, only: [:new, :edit]

  load_and_authorize_resource

  def index
    @images = Image.search_query(params[:q]).order('created_at DESC').limit(100)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.create(image_params)

    if @image.valid?
      flash[:success] = "You have successfully created an image. "
      redirect_to @image
    else
      @flash[:error] = @image.errors.full_messages.join("\n")
      render 'new'
    end
  end

  def edit
  end

  def update
    if @image.update(image_params)
      redirect_to image_path(@image), flash: {success: 'You have successfully edited the image. '}
    else
      @flash[:error] = @image.errors.full_messages.join("\n")
      render 'edit'
    end
  end

  def destroy
    @image.destroy
    redirect_to :back, flash: {success: 'You have successfully deleted the image. '}
  end

  def publish
    # REBIRTH_TODO: Need to invalidate cache.

    # Invalidate below_fold fragment cache when new content is published
    ActionController::Base.new.expire_fragment("below_fold")

    @image.web_published!

    redirect_to publishing_dashboard_path, flash: {success: 'You have successfully published that image. '}
  end

  private
    def load_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:caption, :attribution, :web_photo, :web_status, :print_status, :author_id, :issue_id)
    end

    def prepare_authors_json
      gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
      gon.prefilled_authors = [@image.author].compact.map { |a| {id: a.id, name: a.name} } rescue []
    end
end
