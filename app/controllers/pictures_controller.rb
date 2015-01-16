class PicturesController < ApplicationController
  def destroy
    @picture = Picture.find(params[:id])

    @picture.destroy

    redirect_to @picture.image, flash: {success: 'Picture has been removed. '}
  end

  def create
  end
end
