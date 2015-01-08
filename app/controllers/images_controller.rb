class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy, :direct]

  respond_to :html

  def index
    @images = Image.all
    respond_with(@images)
  end

  def show
    respond_with(@image)
  end

  def new
    @image = Image.new
    respond_with(@image)
  end

  def edit
  end

  def create
    @image = Image.new(image_params)
    @image.save
    respond_with(@image)
  end

  def update
    @image.update(image_params)
    respond_with(@image)
  end

  def destroy
    @image.destroy
    respond_with(@image)
  end

  def direct
    redirect_to @image.content.url
  end

  private
    def set_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:caption, :attribution, :content)
    end
end
