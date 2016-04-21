class FrontendIssuesController < FrontendController

  def show
    volume = params[:volume].to_d
    number = params[:number].to_d

    @issue = Issue.find_by(volume: volume, number: number)

    if @issue && @issue.published_at <= Time.now
      @next = Issue.published.where('published_at > ?', @issue.published_at).reorder('published_at ASC').first
      @prev = Issue.published.where('published_at < ?', @issue.published_at).first

      @images = @issue.pieces.map { |p| p.images + [p.image] }.flatten.compact.uniq { |p| p.id }
      @images = @images.select { |i| i.web_published? }
    else
      raise_404
    end

    set_cache_control_headers(24.hours)
  end

end