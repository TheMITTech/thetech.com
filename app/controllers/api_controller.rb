class ApiController < ApplicationController
  require 'json/ext'
  require 'digest'

  # the style mapping is defined in a concern
  include ApiIndesignStyleMapping

  def style_mapping
    respond_with_checksum MAPPING
  end

  def article_parts
    respond_with_checksum parts: Article::ARTICLE_PARTS
  end

  # return the newest issue
  def newest_issue
    newest = Issue.order('volume DESC, number DESC').first
    respond_with_checksum issue: newest.number, volume: newest.volume
  end

  # return the article as xml
  def article_as_xml
    article = Article.find(params[:id])
    parts = params[:parts].try(:split, ',') # by default get everything

    xml_text = article.as_xml(parts)
    respond_with_checksum xml: xml_text
  rescue ActiveRecord::RecordNotFound
    throw_not_found_error
  end

  # return the list of articles in a given issue
  def issue_lookup
    @issue = Issue.find_by!(volume: params[:volume], number: params[:issue])

    data_hash = {
      id: @issue.id,
      number: @issue.number,
      volume: @issue.volume,
      articles: @issue.articles.map(&method(:article_metadata))
    }

    respond_with_checksum data_hash
  rescue ActiveRecord::RecordNotFound
    throw_not_found_error
  end

  private

  def respond_with_checksum(data, status = 200)
    if data.is_a? String
      json = data
    else
      json = data.to_json
    end
    checksum = Digest::SHA256.hexdigest json

    render json: { data: json.html_safe, checksum: checksum },
           status: status
  end

  def article_metadata(article)
    draft = article.xml_export_draft

    {
      id: article.id,
      headline: draft.headline,
      section: article.section.name,
      slug: article.slug,
      ready_for_print: draft.print_ready?
    }
  end

  def throw_api_error(code, message)
    data = {
      status: 'Error',
      code: code,
      message: message
    }
    respond_with_checksum data, 500
  end

  def throw_not_found_error
    throw_api_error(1, 'Record not found')
  end

  def throw_missing_argument_error
    throw_api_error(2, 'Arguments missing')
  end
end
