class IssuesController < ApplicationController
  before_action :set_issue, only: [:upload_pdf_form, :upload_pdf, :remove_pdf, :show]

  load_and_authorize_resource

  respond_to :html

  def index
    @filter_volume = params[:filter_volume]
    @issues = nil

    if @filter_volume.present?
      @issues = Issue.where(volume: @filter_volume)
    else
      @issues = Issue.all
    end

    @issues = @issues.page(params[:page]).per(100)

    @new_issue = Issue.new
    respond_with(@issues)
  end

  def show
    @articles = @issue.pieces.with_article.reorder('section_id ASC').map(&:article).map(&:as_display_json).group_by { |x| x[:section_name] }
    @images = (@issue.pieces.with_image.map(&:image).to_a + @issue.pieces.with_article.map(&:article).map(&:asset_images).flatten).uniq { |i| i.id }.map(&:as_display_json)
  end

  def create
    @issue = Issue.new(issue_params)

    if @issue.save
      redirect_to issues_path, flash: {success: 'Successfully created issue. '}
    else
      redirect_to issues_path, flash: {error: @issue.errors.full_messages.join("\n")}
    end
  end

  def upload_pdf
    @issue.pdf = params[:content]

    if @issue.valid?
      @issue.save

      redirect_to issues_path, flash: {success: "Successfully uploaded PDF for #{@issue.name}. "}
    else
      redirect_to issues_path, flash: {error: "Please make sure the file you upload is a valid PDF file. "}
    end
  end

  def upload_pdf_form
  end

  def remove_pdf
    @issue.pdf = nil
    @issue.save

    redirect_to issues_path, flash: {success: "Successfully removed PDF for #{@issue.name}. "}
  end

  private
    def set_issue
      @issue = Issue.find(params[:id])
    end

    def issue_params
      params.require(:issue).permit(:number, :volume, :published_at)
    end
end
