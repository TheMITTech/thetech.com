class ApiController < ApplicationController
  # return the article as xml
  def article_as_xml
    article = Article.find(params[:id])
    parts = params[:parts].try(:split, ',')
    # by default get everything
    parts ||= %w(headline subhead byline bytitle body)

    headers['Content-Type'] = 'text/plain; charset=UTF-8'
    render text: article.as_xml(parts).html_safe
  rescue ActiveRecord::RecordNotFound
    throw_not_found_error
  end

  # return the list of articles in a given issue
  def issue_lookup
    @issue = Issue.find_by!(volume: params[:volume], number: params[:issue])

    render json: {
      id: @issue.id,
      number: @issue.number,
      volume: @issue.volume,
      articles: @issue.pieces.select(&:article).map do |p|
        p.article.as_json only: [:id, :headline, :subhead]
      end
    }
  rescue ActiveRecord::RecordNotFound
    throw_not_found_error
  end

  private

  def throw_api_error(code, message)
    render json: {
      status: 'Error',
      code: code,
      message: message
    }, status: 500
  end

  def throw_not_found_error
    throw_api_error(1, 'Record not found')
  end

  def throw_missing_argument_error
    throw_api_error(2, 'Arguments missing')
  end
end
