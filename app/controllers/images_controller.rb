class ImagesController < ApplicationController
  before_action :load_image, only: [:show, :edit, :update, :destroy, :publish]
  before_action :prepare_authors_json, only: [:new, :edit]

  load_and_authorize_resource

  respond_to :html

  def index
    @images = RbImage.search_query(params[:q]).order('created_at DESC').limit(100)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @assignable_pieces = Piece.with_article.recent.where.not(:id => @image.pieces.map(&:id).uniq)

    respond_with(@image)
  end

  def new
    @image = Image.new
    @piece = Piece.new
    respond_with(@image)
  end

  def edit
  end

  def create
    @image = Image.new(image_params)
    @piece = Piece.new(piece_params)

    @pictures = params[:images].map { |i| Picture.new(content: i) }

    piece_id = params[:piece_id]

    unless @pictures.all?(&:valid?)
      @flash[:error] = "Please make sure that all files are valid images. "
      render 'new' and return
    end

    unless @image.valid?
      @flash[:error] = @image.errors.full_messages.join("\n")
      render 'new' and return
    end

    if piece_id.blank?
      if @piece.valid?
        @pictures.each { |p| @image.pictures << p }
        @piece.save
        @image.primary_piece = @piece
        @image.save

        redirect_to @image
      else
        @flash[:error] = @piece.errors.full_messages.join("\n")
        render 'new'
      end
    else
      @pictures.each { |p| @image.pictures << p }
      @image.pieces << Piece.find(piece_id)
      @image.save

      redirect_to @image
    end
  end

  def update
    @image.assign_attributes(image_params)

    if @image.primary_piece.present?
      @piece = @image.primary_piece
      @piece.assign_attributes(piece_params)
    end

    if @image.valid?
      if @image.primary_piece.present?
        if @piece.valid?
          @piece.save
          @image.save

          redirect_to image_path(@image), flash: {success: 'You have successfully edited the image. '}
        else
          @flash[:error] = @image.errors.full_messages.join("\n")

          render 'edit'
        end
      else
        @image.save
        redirect_to image_path(@image), flash: {success: 'You have successfully edited the image. '}
      end
    else
      @flash[:error] = @image.errors.full_messages.join("\n")

      render 'edit'
    end
  end

  def destroy
    @image.destroy
    respond_with(@image)
  end

  def publish
    ActionController::Base.new.expire_fragment("below_fold") # Invalidate below_fold fragment cache when new content is published

    require 'varnish/purger'

    @image.web_published!

    Varnish::Purger.purge(frontend_photographer_path(@image.author), true) if @image.author

    issues = (@image.pieces + [@image.primary_piece]).compact.map(&:issue).uniq { |i| i.id }

    issues.each do |i|
      Varnish::Purger.purge(frontend_issue_path(i.volume, i.number), true)
    end

    redirect_to publishing_dashboard_path, flash: {success: 'You have successfully published that image. '}
  end

  private
    def load_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:caption, :attribution, :content, :creation_piece_id, :section_id, :web_status, :print_status, :author_id)
    end

    def prepare_authors_json
      gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
      gon.prefilled_authors = [@image.author].compact.map { |a| {id: a.id, name: a.name} } rescue []
    end
end
