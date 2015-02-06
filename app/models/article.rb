class Article < AbstractModel
  has_and_belongs_to_many :users
  has_many :authors, through: :authorships
  has_many :authorships
  has_many :article_versions

  belongs_to :piece
  belongs_to :latest_published_version, foreign_key: :latest_published_version_id, class_name: 'ArticleVersion'

  validates :headline, presence: true, length: {minimum: 2}

  serialize :chunks
  serialize :author_ids

  before_save :parse_html
  before_save :update_authors_line
  before_save :update_piece_published_fields
  after_save :update_authorships
  after_save :update_piece_web_template

  scope :published, -> { where('latest_published_version_id IS NOT NULL') }

  RANKS = ([99] + (0..98).to_a)

  include ArticleXmlExportable

  scope :search_query, lambda { |q|
    return nil if q.blank?

    terms = q.downcase.split(/\s+/)

    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conds = 4
    where(
      terms.map { |t|
        "(LOWER(articles.headline) LIKE ? OR LOWER(articles.subhead) LIKE ? OR LOWER(articles.authors_line) LIKE ? OR LOWER(articles.bytitle) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  # Make sure that there is at least one version
  def article_versions
    self.save_version! if super.empty?
    super
  end

  # The latest published version.
  # Returns an instance of ArticleVersion
  def display_version
    ActiveSupport::Deprecation.warn("Article#display_version is deprecated. Use Article#latest_published_version instead. ")
    self.latest_published_version
  end

  # The latest version that has been marked ready for web publication.
  # Returns an instance of ArticleVersion
  def web_ready_version
    self.article_versions.web_ready.first
  end

  # The latest version which is ready for print
  def print_version
    self.article_versions.print_ready.first
  end

  # The latest version.
  # Returns an instance of ArticleVersion
  def latest_version
    self.article_versions.first
  end

  # The earliest published version.
  # Returns an instance of ArticleVersion
  def original_published_version
    self.article_versions.web_published.last
  end

  # Gives the publication time of the first version to be published.
  # Returns an instance of datetime. If the article has never been published,
  # returns nil.
  def published_at
    self.original_published_version.try(:updated_at)
  end

  # Gives the time of the most recent update to the latest published verison.
  # Returns an instance of datetime.
  def modified_at
    self.latest_published_version.try(:updated_at)
  end

  def published?
    ActiveSupport::Deprecation.warn("Article#published? is deprecated. Use Article#web_published? instead. ")
    self.web_published?
  end

  def web_published?
    !self.latest_published_version.nil?
  end

  def ready_for_print?
    !self.print_version.nil?
  end

  def unpublished?
    !self.published?
  end

  def has_pending_draft?
    first = self.article_versions.first
    first.web_status == "web_draft" and first.print_status == "print_draft"
  end

  # Returns the draft version of the article as an instance of Article_Version
  # if it exists. Otherwise, returns nil.
  def pending_draft
    has_pending_draft? ? self.article_versions.first : nil
  end

  # Parses a comma-separated string of author_ids into a list of
  # author_ids as integers.
  def author_ids=(author_ids)
    @author_ids = author_ids.split(',').map(&:to_i)
  end

  # Creates a comma separated string of author_ids, where the author_ids belong
  # to the authors of this article.
  def author_ids
    (@author_ids ||= self.authorships.map(&:author_id)).join(',')
  end

  # Returns a list of images associated with this article if there are any.
  # Otherwise, returns an empty list.
  def asset_images
    if self.piece
      self.piece.images
    else
      []
    end
  end

  def asset_article_lists
    self.piece.article_lists rescue []
  end

  def authors_line
    read_attribute(:authors_line) || authors_line_from_author_ids
  end

  # metas to be displayed
  def meta(name)
    case name
    when :headline, :subhead, :bytitle, :intro, :modified_at, :published_at, :syndicated?
      self.send(name)
    when :piece
      Piece.find_by(id: self.piece_id)
    when :authors
      Authorship.where(article_id: self.id).map(&:author)
    when :authors_line
      assemble_authors_line(self.meta(:authors))
    when :frontend_display_path
      self.piece.meta(:frontend_display_path)
    end
  end

  # virtual accessor intro for lede or automatically generated lede. If no lede
  # was specified, the lede is taken to be the first paragraph. If there is no
  # first paragraph, the string 'A rather empty piece.' is used as the lede.
  def intro
    if self.lede.blank?
      p = self.chunks.first

      if p
        Nokogiri::HTML.fragment(p).text
      else
        'A rather empty piece.'
      end
    else
      self.lede
    end
  end

  # This will simulate the controller save_version behavior. However, the params
  # will be generated instead of hand-crafted. This should only be used while
  # importing data
  def save_version!
    version = ArticleVersion.create(
      article_id: self.id,
      contents: {
        article_params: {
          headline: self.headline,
          subhead: self.subhead,
          bytitle: self.bytitle,
          html: self.html,
          author_ids: self.authorships.map(&:author_id).join(','),
          lede: self.lede
        },
        piece_params: {
          section_id: self.piece.section_id,
          primary_tag: self.piece.primary_tag,
          tags_string: self.piece.tags_string,
          issue_id: self.piece.issue_id
        },
        article_attributes: self.attributes,
        piece_attributes: self.piece.attributes,
        tag_ids: self.piece.taggings.map(&:tag_id).join(','),
        author_ids: self.authors.map(&:id).join(',')
      }
    )

    version.web_published!
    version.print_ready!

    version.created_at = self.updated_at
    version.updated_at = self.updated_at
    version.save

    self.latest_published_version = version
    save

    version
  end


  # Returns a json representation of the cached version of the article.
  def as_display_json
    Rails.cache.fetch("#{cache_key}/display_json") do
      {
        id: self.id,
        slug: self.piece.slug,
        rank: self.rank,
        is_published: self.published?,
        is_ready_for_print: self.ready_for_print?,
        has_pending_draft: self.has_pending_draft?,
        section_name: self.piece.section.name,
        headline: self.headline,
        subhead: self.subhead,
        authors_line: self.authors_line,
        bytitle: self.bytitle,
        issue: {volume: self.piece.issue.volume, number: self.piece.issue.number},
        publish_date: self.published_at,
        published_version_path: self.display_version && self.piece.frontend_display_path,
        print_version_path: self.print_version,
        latest_version_path: Rails.application.routes.url_helpers.article_article_version_path(self, self.latest_version),
        versions_path: Rails.application.routes.url_helpers.article_article_versions_path(self)
      }
    end
  end

  private

    # Parses the html content of the article and populates the chunks.
    def parse_html
      require 'parser'
      @parser = Techplater::Parser.new(self.html)
      @parser.parse!

      self.chunks = @parser.chunks
    end

    def update_piece_web_template
      self.piece.update(web_template: @parser.template)
    end

    def update_authors_line
      self.authors_line = authors_line_from_author_ids
    end

    # Creates a user-friendly string representation of the authors of this
    # article.
    def authors_line_from_author_ids
      authors = self.author_ids.split(',').map(&:to_i).map { |i| Author.find(i) }

      assemble_authors_line(authors)
    end

    # Given an array of Author instances, creates a user-friendly string
    # representation of the authors of this article.
    def assemble_authors_line(authors)
      case authors.size
      when 0
        "Unknown Author"
      when 1
        authors.first.name
      when 2
        "#{authors.first.name} and #{authors.last.name}"
      else
        (authors[0...-1].map(&:name) + ["and #{authors.last.name}"]).join(', ')
      end
    end

    def update_authorships
      self.authorships.destroy_all

      if @author_ids
        @author_ids.each_with_index do |author, order|
          self.authorships.create(
            author_id: author,
            rank: order
          )
        end
      end
    end

    def update_piece_published_fields
      return if self.latest_published_version.nil?

      self.piece.published_author_ids = self.latest_published_version.author_ids
      self.piece.published_tag_ids = self.latest_published_version.tag_ids
      self.piece.published_headline = self.latest_published_version.headline
      self.piece.published_subhead = self.latest_published_version.subhead
      self.piece.published_content = self.latest_published_version.content
      self.piece.published_section_id = self.latest_published_version.section_id

      self.piece.save
    end

end
