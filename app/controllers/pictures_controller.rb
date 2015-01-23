class PicturesController < ApplicationController
  def destroy
    @picture = Picture.find(params[:id])

    @picture.destroy

    redirect_to @picture.image, flash: {success: 'Picture has been removed. '}
  end

  def create
    @pictures = params[:pictures].map { |p| Picture.new(content: p) }
    @image = Image.find(params[:image_id])

    if @pictures.all?(&:valid?)
      @pictures.each { |p| @image.pictures << p}
      @image.save

      redirect_to image_path(@image), flash: {success: "Uploaded #{ActionController::Base.helpers.pluralize @pictures.count, 'picture'}. "}
    end
  end

  def direct
    redirect_to Picture.find(params[:id]).content.url(:large)
  end
end
