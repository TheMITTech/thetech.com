class Article < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :authors, through: :authorships
  has_many :authorships
  has_many :article_versions

  belongs_to :piece

  validates :headline, presence: true, length: {minimum: 2}

  serialize :chunks
  serialize :author_ids

  before_save :parse_html
  before_save :update_authors_line
  after_save :update_authorships
  after_save :update_piece_web_template



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

  # The latest published version
  def display_version
    self.article_versions.published.first
  end

  # The latest version
  def latest_version
    self.article_versions.first
  end

  # The earliest published version
  def original_published_version
    self.article_versions.published.last
  end

  # The original publication time
  def published_at
    self.original_published_version.try(:created_at)
  end

  # The latest update time
  def updated_at
    self.display_version.try(:created_at)
  end

  def published?
    !self.display_version.nil?
  end

  def unpublished?
    self.display_version.nil?
  end

  def has_pending_draft?
    self.article_versions.first.try(:draft?)
  end

  def pending_draft
    has_pending_draft? ? self.article_versions.first : nil
  end

  # author_ids needs to be a comma separated string to fit the input format

  def author_ids=(author_ids)
    @author_ids = author_ids.split(',').map(&:to_i)
  end

  def author_ids
    (@author_ids ||= self.authorships.map(&:author_id)).join(',')
  end

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
    when :headline, :subhead, :bytitle, :intro, :updated_at, :published_at, :syndicated?
      self.send(name)
    when :authors
      Authorship.where(article_id: self.id).map(&:author)
    when :authors_line
      assemble_authors_line(self.meta(:authors))
    end
  end

  # virtual accessor intro for lede or automatically generated lede
  def intro
    if self.lede.blank?
      p = self.chunks.first

      if p
        Nokogiri::HTML.fragment(p).text
      else
        'A rather empty piece. '
      end
    else
      self.lede
    end
  end

  def as_xml(parts)
    article_parts = %w(headline subhead byline bytitle body) # array of strings
    parts_to_take = article_parts & parts # intersection
    p parts_to_take

    content = "<document>\n"

    if parts_to_take.include?('headline')
      content += "<headline>#{headline}</headline>\n"
    end

    if parts_to_take.include?('subhead')
      content += "<subhead>#{subhead}</subhead>\n"
    end

    if parts_to_take.include?('byline')
      content += "<byline>#{authors_line}</byline>\n"
    end

    if parts_to_take.include?('bytitle')
      content += "<bytitle>#{bytitle}</bytitle>\n"
    end

    if parts_to_take.include?('body')
      chunks.each do |chunk_node|
        chunk = Nokogiri::HTML.fragment(chunk_node)
        fc = chunk.children.first

        next if fc.name.to_sym != :p
        content += '<body>'
        fc.children.each do |c|
          case c.name.to_sym
          when :text
            content += c.text
          when :a
            content += c.content
          when :em
            content += "<em>#{c.text}</em>"
          when :strong
            content += "<strong>#{c.text}</strong>"
          end
        end
        content += "</body>\n"
      end
    end

    content += '</document>'
    content
  end

  # This will simulate the controller save_version behavior. However, the params will be generated instead of hand-crafted. This should only be used during importing data
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
        piece_attributes: self.piece.attributes
      }
    )

    version.published!

    version
  end

  def publish_datetime
    self.display_version.created_at
  end

  def as_display_json
    Rails.cache.fetch("#{cache_key}/display_json") do
      {
        slug: self.piece.slug,
        publish_status: self.published? ? '✓' : '',
        draft_pending: self.has_pending_draft? ? '✓' : '',
        section_name: self.piece.section.name,
        headline: self.headline,
        subhead: self.subhead,
        authors_line: self.authors_line,
        bytitle: self.bytitle,
        published_version_path: self.display_version && self.piece.frontend_display_path,
        draft_version_path: self.pending_draft && Rails.application.routes.url_helpers.article_article_version_path(self, self.pending_draft),
        latest_version_path: Rails.application.routes.url_helpers.article_article_version_path(self, self.latest_version),
        versions_path: Rails.application.routes.url_helpers.article_article_versions_path(self)
      }
    end
  end

  private

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

    def authors_line_from_author_ids
      authors = self.author_ids.split(',').map(&:to_i).map { |i| Author.find(i) }

      assemble_authors_line(authors)
    end

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
end
