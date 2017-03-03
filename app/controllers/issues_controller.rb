class IssuesController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  def index
    @filter_volume = params[:filter_volume]
    @issues = Issue.all
    @issues = @issues.where(volume: @filter_volume) if @filter_volume.present?
    @issues = @issues.page(params[:page]).per(100)

    @new_issue = Issue.new
  end

  def show
    @articles_by_sections = @issue.articles.reorder('section_id ASC').group_by { |x| x.section.name }
    @images = @issue.images
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
      @issue.generate_pdf_preview!

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
