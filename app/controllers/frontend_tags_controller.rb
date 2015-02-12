class FrontendTagsController < FrontendController
  def show
    @tag = ActsAsTaggableOn::Tag.find_by(slug: params[:id])
    raise_404 if @tag.nil?

    query = Piece.where('published_tag_ids ~* ?', "\\y#{@tag.id}\\y")
    @pieces = query.page(params[:page]).per(20)
    @count = query.count
    @sections = query.pluck(:published_section_id).to_a.uniq
    @articles = @pieces.map(&:article).map(&:latest_published_version)

    @title = @tag.name.split.map(&:capitalize).join(' ')

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
