class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update]

  load_and_authorize_resource

  respond_to :html

  def index
    @sections = Section.all
  end

  def show
  end

  def new
    @section = Section.new
    respond_with(@section)
  end

  def edit
  end

  def create
    @section = Section.new(section_params)
    @section.save
    respond_with(@section)
  end

  def update
    @section.update(section_params)
    respond_with(@section)
  end

  private
    def set_section
      @section = Section.friendly.find(params[:id])
    end

    def section_params
      params.require(:section).permit(:name)
    end
end
