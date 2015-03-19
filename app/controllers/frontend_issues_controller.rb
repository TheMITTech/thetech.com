class FrontendIssuesController < FrontendController

  def show
    volume = params[:volume].to_d
    number = params[:number].to_d

    @issue = Issue.find_by(volume: volume, number: number)

    if @issue && @issue.published_at <= Time.now
      @next = Issue.where('id > ?', @issue.id).order('id ASC').first
      @prev = Issue.where('id < ?', @issue.id).order('id DESC').first

      @images = @issue.pieces.map { |p| p.images + [p.image] }.flatten.compact.uniq { |p| p.id }
    else
      raise_404
    end

    set_cache_control_headers(24.hours)
  end

end