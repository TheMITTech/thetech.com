class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :edit, :update, :destroy]
  after_action :purge_manifest_cache, only: [:create, :update]

  load_and_authorize_resource

  respond_to :html

  def index
    @ads = Ad.order('start_date DESC').all
    respond_with(@ads)
  end

  def show
    respond_with(@ad)
  end

  def new
    @ad = Ad.new
    respond_with(@ad)
  end

  def edit
  end

  def create
    @ad = Ad.new(ad_params)

    if @ad.valid?
      @ad.save
    else
      @flash[:error] = @ad.errors.full_messages.join("\n")
    end

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

    respond_with(@ad)
  end

  def update
    @ad.assign_attributes(ad_params)

    if @ad.valid?
      @ad.save
    else
      @flash[:error] = @ad.errors.full_messages.join("\n")
    end

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

    respond_with(@ad)
  end

  def destroy
    @ad.destroy

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

    respond_with(@ad)
  end

  private
    def set_ad
      @ad = Ad.find(params[:id])
    end

    def ad_params
      params.require(:ad).permit(:name, :start_date, :end_date, :position, :content, :link)
    end

    def purge_manifest_cache
      require 'varnish/purger'

      Varnish::Purger.purge(frontend_ads_manifest_path, true)
    end
end
