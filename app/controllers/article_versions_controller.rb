class ArticleVersionsController < ApplicationController

  load_and_authorize_resource

  def index
    @article = Article.find(params[:article_id])
    @versions = @article.article_versions
  end

  def show
    @version = ArticleVersion.find(params[:id])

    @article = Article.new
    @article.assign_attributes(@version.article_attributes)
    @piece = Piece.new
    @piece.assign_attributes(@version.piece_attributes)

    @title = @article.headline

    require 'renderer'
    renderer = Techplater::Renderer.new(@piece.web_template, @article.chunks)
    @html = renderer.render

    @web_status_options = ArticleVersion::WEB_STATUS_NAMES.reject {|k, v|
      k == :web_published and not @version.web_published?
    }.keys.map {|k| [ArticleVersion::WEB_STATUS_NAMES[k], k]}

    render 'show', layout: 'bare'
  end

  def diff
    @version = ArticleVersion.find(params[:id])

    @previous_version = ArticleVersion.where("id < ? and article_id = ?", params[:id], @version.article_id).first

  @this_article = Article.new
  @this_article.assign_attributes(@version.article_attributes)
  @this_piece = Piece.new
  @this_piece.assign_attributes(@version.piece_attributes)

  @previous_article = Article.new
  @previous_article.assign_attributes(@previous_version.article_attributes)
  @previous_piece = Piece.new
  @previous_piece.assign_attributes(@previous_version.piece_attributes)


  require 'renderer'
  this_renderer = Techplater::Renderer.new(@this_piece.web_template, @this_article.chunks)
  previous_renderer = Techplater::Renderer.new(@previous_piece.web_template, @previous_article.chunks)

  @html_left =  Diffy::SplitDiff.new(previous_renderer.render, this_renderer.render, :format => :html, :include_plus_and_minus_in_html => true).left
  @html_right =  Diffy::SplitDiff.new(previous_renderer.render, this_renderer.render , :format => :html, :include_plus_and_minus_in_html => true).right

    @html = Diffy::Diff.new(previous_renderer.render, this_renderer.render).to_s(format= :html)

  render 'diff', layout: 'bare'

  end

  def revert
    @version = ArticleVersion.find(params[:id])

    article_params = @version.article_params
    piece_params = @version.piece_params

    # Permit access to the fields of article_params, piece_params.
    # (Ifs ensure that the permit! function is properly defined).
    article_params = article_params.permit! if article_params.respond_to?(:permit!)
    piece_params = piece_params.permit! if piece_params.respond_to?(:permit!)

    @article = @version.article
    @article.assign_attributes(article_params)
    @piece = @article.piece
    @piece.assign_attributes(piece_params)

    gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
    gon.prefilled_authors = @article.authors.map { |a| {id: a.id, name: a.name} } rescue []

    render 'articles/edit'
  end

  def update_web_status
    @version = ArticleVersion.find(params[:id])
    @version.update(params[:article_version].permit(:web_status))

    redirect_to article_article_versions_path(@version.article), flash: {success: 'You have successfully changed the status of this article version. '}
  end

  def mark_print_ready
    @version = ArticleVersion.find(params[:id])
    @version.dup.print_ready!

    redirect_to article_article_versions_path(@version.article), flash: {success: 'You have successfully marked the version as ready for print. '}
  end

  def publish
    require 'varnish/purger'

    ActionController::Base.new.expire_fragment("below_fold") # Invalidate below_fold fragment cache when new content is published

    @version = ArticleVersion.find(params[:id])
    @version.web_published!

    if @version.article.latest_published_version
      old_version = @version.article.latest_published_version

      Varnish::Purger.purge(frontend_section_path(old_version.build_piece.meta(:section)), true)
      Varnish::Purger.purge(frontend_section_path(old_version.build_piece.meta(:section)) + '/.*', false)

      old_version.build_article.meta(:authors).each do |a|
        Varnish::Purger.purge(frontend_author_path(a), true)
        Varnish::Purger.purge(frontend_author_path(a) + '/.*', false)
      end

      if old_version.meta(:primary_tag)
        slug = ActsAsTaggableOn::Tag.find_by(name: old_version.meta(:primary_tag)).slug
        Varnish::Purger.purge(frontend_tag_path(slug), true)
        Varnish::Purger.purge(frontend_tag_path(slug) + '/.*', false)
      end

      old_version.meta(:tags).each do |t|
        slug = ActsAsTaggableOn::Tag.find_by(name: t).slug
        Varnish::Purger.purge(frontend_tag_path(slug), true)
        Varnish::Purger.purge(frontend_tag_path(slug) + '/.*', false)
      end
    end

    @version.article.latest_published_version = @version
    @version.article.save

    @version.article_attributes[:latest_published_version_id] = @version.id
    @version.save

    Varnish::Purger.purge(@version.meta(:frontend_display_path), true)
    Varnish::Purger.purge(root_path, true)
    Varnish::Purger.purge(frontend_section_path(@version.article.piece.section), true)
    Varnish::Purger.purge(frontend_section_path(@version.article.piece.section) + '/.*', false)

    @version.article.authors.each do |a|
      Varnish::Purger.purge(frontend_author_path(a), true)
      Varnish::Purger.purge(frontend_author_path(a) + '/.*', false)
    end

    if @version.article.piece.primary_tag
      slug = ActsAsTaggableOn::Tag.find_by(name: @version.article.piece.primary_tag).slug
      Varnish::Purger.purge(frontend_tag_path(slug), true)
      Varnish::Purger.purge(frontend_tag_path(slug) + '/.*', false)
    end

    @version.article.piece.tags.each do |t|
      slug = ActsAsTaggableOn::Tag.find_by(name: t).slug
      Varnish::Purger.purge(frontend_tag_path(slug), true)
      Varnish::Purger.purge(frontend_tag_path(slug) + '/.*', false)
    end

    Varnish::Purger.purge(frontend_issue_path(@version.article.piece.issue.volume, @version.article.piece.issue.number), true)

    redirect_to publishing_dashboard_url, flash: {success: 'You have succesfully published that article version. '}
  end

  def below_fold_preview
    if params[:article_id].present?
      @article = Article.find(params[:article_id])
      @piece = @article.piece
    else
      @piece = nil
    end

    render 'below_fold_preview', layout: 'frontend_iframed'
  end
end
