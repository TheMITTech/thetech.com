class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource

  respond_to :html

  def index
    @series = Series.all
    respond_with(@series)
  end

  def show
    respond_with(@series)
  end

  def new
    @series = Series.new
    respond_with(@series)
  end

  def edit
  end

  def create
    @series = Series.new(series_params)
    @series.save
    respond_with(@series)
  end

  def update
    @series.update(series_params)
    respond_with(@series)
  end

  def destroy
    @series.destroy
    respond_with(@series)
  end

  private
    def set_series
      @series = Series.find(params[:id])
    end

    def series_params
      params.require(:series).permit(:name)
    end
end
