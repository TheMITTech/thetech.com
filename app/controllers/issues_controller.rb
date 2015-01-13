class IssuesController < ApplicationController
  before_action :set_issue, only: []

  load_and_authorize_resource

  respond_to :html

  def index
    @issues = Issue.all
    @new_issue = Issue.new
    respond_with(@issues)
  end

  def create
    @issue = Issue.new(issue_params)

    if @issue.save
      redirect_to issues_path
    else
      redirect_to issues_path, flash: {error: @issue.errors.full_messages.join("\n")}
    end
  end

  def lookup
    @issue = Issue.find_by!(volume: params[:volume], number: params[:issue])

    render json: {
      id: @issue.id,
      number: @issue.number,
      volume: @issue.volume,
      articles: @issue.pieces.select { |p| p.article }.map do |p|
        p.article.as_json only: [:id, :headline, :subhead]
      end
    }
  end

  private
    def set_issue
      @issue = Issue.find(params[:id])
    end

    def issue_params
      params.require(:issue).permit(:number, :volume)
    end
end
