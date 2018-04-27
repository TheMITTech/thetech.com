class ImagesController < ApplicationController
  # TODO: We are adding this exception for batch uploading.
  # Should probably find a better way.
  load_and_authorize_resource except: [:create]

  def index
    respond_to do |format|
      format.html
      format.json do
        @page = (params[:page].presence || 1).to_i
        @images = Image.search_query(params[:q]).order('created_at DESC').page(@page).per(20)

        next_page = @images.last_page? ?
                      nil :
                      images_path(page: @page + 1, format: :json)

        render json: {images: @images.map { |i| i.as_react(current_ability) }, nextPage: next_page}
      end
    end
  end

  def show
    respond_to do |f|
      f.html
      f.json { render json: {image: @image.as_react(current_ability)} }
    end
  end

  def new
    @image = Image.new
    prepare_authors_json
  end

  def create
    if params[:images].present? && params[:issue_id].present?
      # We are in batch uploading mode

      @images = params[:images].map do |image|
        Image.create!({
          issue: Issue.find(params[:issue_id]),
          caption: "Image uploaded at #{Time.zone.now.strftime('%b. %d, %Y %H:%M:%S')}",
          web_photo: image
        })
      end

      respond_to do |f|
        f.html { redirect_to images_path, flash: {success: "You have successfully uploaded #{@images.count} #{'image'.pluralize(@images.count)}. "} }
        # TODO: Make AJAX work.
        f.js
      end
    else
      @image = Image.create(image_params)

      if @image.valid?
        flash[:success] = "You have successfully created an image. "
        redirect_to @image
      else
        @flash[:error] = @image.errors.full_messages.join("\n")
        render 'new'
      end
    end
  end

  def edit
    prepare_authors_json
  end

  def update
    if image_params[:web_status].try(:to_sym) == :web_ready or
       image_params[:print_status].try(:to_sym) == :print_ready
      authorize! :ready, @image
    end

    if @image.update(image_params)
      respond_to do |f|
        f.html { redirect_to image_path(@image), flash: {success: 'You have successfully edited the image. '} }
        f.json { render json: {image: @image.as_react(current_ability)} }
      end
    else
      @flash[:error] = @image.errors.full_messages.join("\n")

      respond_to do |f|
        f.html { render 'edit' }
        f.json { render json: @flash[:error] }
      end
    end
  end

  def destroy
    raise RuntimeError, "Cannot destroy a web_published Image. " if @image.web_published?

    @image.destroy

    respond_to do |f|
      f.html { redirect_to :back, flash: {success: 'You have successfully deleted the image. '} }
      f.json { render json: {image: {id: @image.id, destroyed: true}}}
    end
  end

  def publish
    # REBIRTH_TODO: Need to invalidate cache.

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

    @image.web_published!
    @image.update!(published_at: Time.zone.now)

    respond_to do |f|
      f.html { redirect_to publishing_dashboard_path, flash: {success: 'You have successfully published that image. '}}
      f.json { render json: {image: @image.as_react(current_ability)} }
      f.js
    end
  end

  def unpublish
    # REBIRTH_TODO: Need to invalidate cache.

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

    @image.web_ready!
    @image.update!(published_at: nil)

    respond_to do |f|
      f.html { redirect_to publishing_dashboard_path, flash: {success: 'You have successfully unpublished that image. '}}
      f.json { render json: {image: @image.as_react(current_ability)} }
    end
  end
  # REBIRTH_TODO: Authorization?
  def add_article
    article = Article.find(params[:article_id])
    @image.articles << article
    @image.touch
    article.touch

    respond_to do |f|
      f.html { redirect_to @image, flash: {success: "You have successfully added the article to be accompanied by the image. "} }
      f.json { render json: {image: @image.as_react(current_ability)} }
    end
  end

  def remove_article
    article = Article.find(params[:article_id])
    @image.articles.delete(article)
    @image.touch
    article.touch

    respond_to do |f|
      f.html { redirect_to @image, flash: {success: "You have successfully removed the article from the list of accompanied articles. "} }
      f.json { render json: {image: @image.as_react(current_ability)} }
    end
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
      gon.prefilled_authors = [@image.author].compact.map { |a| {id: a.id, name: a.name} }
    end
end
