class Draft < ActiveRecord::Base
  # Associations
  belongs_to :article     # We omit touch: true here, and instead use a after_save callback to simulate
                          # its effect. The reason being: `touch: true' causes the Article to also be=
                          # touched when a Draft is being destroyed. However, currently the only scenario
                          # under which a Draft would be destroyed is when the Article it belongs to is
                          # being destroyed. This causes unnecessary and potentially invalid MessageBus
                          # model updates. Therefore, we use a callback so that touch is only being called
                          # when the model is updated, but not when it is destroyed.
  belongs_to :user

  has_many :authorships, -> { order('byline_order') }
  has_many :authors, -> { order('authorships.byline_order') }, through: :authorships

  # Representations
  serialize :chunks

  enum web_status: [:web_draft, :web_published, :web_ready]
  enum print_status: [:print_draft, :print_ready]

  WEB_STATUS_NAMES = {
    web_draft: 'Web Draft',
    web_published: 'Published on the Web',
    web_ready: 'Ready for Web'
  }.with_indifferent_access

  PRINT_STATUS_NAMES = {
    print_draft: "Print Draft",
    print_ready: "Ready for Print"
  }.with_indifferent_access

  validates :headline, presence: true, length: {minimum: 2}
  validates :user, presence: true
  validates :article, presence: true
  validates :headline, not_nil: true
  validates :subhead, not_nil: true
  validates :bytitle, not_nil: true
  validates :lede, not_nil: true
  validates :attribution, not_nil: true
  validates :notes, not_nil: true
  validates :redirect_url, not_nil: true
  validates :chunks, not_nil: true
  validates :web_template, not_nil: true

  validate :tag_list_is_valid

  acts_as_ordered_taggable
  acts_as_paranoid

  # Callbacks
  before_validation :parse_html
  before_save :normalize_fields
  before_save :fill_lede
  before_save :touch_article

  # Keyword search
  scope :search_query, lambda { |q|
    return nil if q.blank?

    terms = q.downcase.split(/\s+/).map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conds = 3
    where(
      terms.map { |t|
        "(LOWER(drafts.headline) LIKE ? OR LOWER(drafts.subhead) LIKE ? OR LOWER(drafts.bytitle) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  # TODO: Revisit naming
  def rendered_html
    require 'renderer'
    renderer = Techplater::Renderer.new(self.web_template, self.chunks)
    renderer.render
  end

  # Tag-related functionalities
  # Virtual attrs for 'primary_tag' and 'secondary_tags'
  NO_PRIMARY_TAG = 'NO_PRIMARY_TAG'.downcase

  def primary_tag
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.tag_list.first == NO_PRIMARY_TAG ?
        "" :
        self.tag_list.first
    end
  end

  def secondary_tags
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.tag_list.drop(1).join(", ")
    end
  end

  def primary_tag=(primary_tag)
    primary_tag.present? ?
      self.tag_list[0] = primary_tag.downcase :
      self.tag_list[0] = NO_PRIMARY_TAG
    self.touch unless self.new_record?
  end

  def secondary_tags=(secondary_tags)
    self.tag_list = [self.tag_list[0]] + secondary_tags.split(",").map(&:strip).map(&:downcase)
    self.touch unless self.new_record?
  end

  # Readable authors string
  # TODO: rename to attribution_text?
  def authors_string
    return (self.attribution || "Unknown Author") if self.article.syndicated?

    author_names = self.authors.map(&:name)

    case author_names.size
    when 0
      "Unknown Author"
    when 1
      authors.first.name
    when 2
      "#{authors.first.name} and #{authors.last.name}"
    when 3
      (authors[0...-1].map(&:name) + ["and #{authors.last.name}"]).join(", ")
    end
  end

  # TODO: better naming
  # Virtual attr: comma_separated_author_ids
  def comma_separated_author_ids
    self.author_ids.join(",")
  end

  def comma_separated_author_ids=(ids)
    self.authorships.destroy_all
    ids.split(",").map(&:strip).map(&:to_i).each_with_index do |id, i|
      self.authorships << Authorship.new(author_id: id, byline_order: i)
    end
  end

  # We allow the following web_status transitions:
  #   draft -> draft, ready
  #   ready -> ready
  #   published -> published
  # Note that the ready -> published transition is done through #publish.
  def valid_next_web_statuses
    return [:web_published] if self.web_published?
    return [:web_ready] if self.web_ready?
    [:web_draft, :web_ready]
  end

  # We allow the following print_status transitions:
  #   draft -> draft, ready
  #   ready -> ready
  def valid_next_print_statuses
    return [:print_ready] if self.print_ready?
    [:print_draft, :print_ready]
  end

  def text
    self.chunks.map { |c| c.gsub(/<\/?[^>]+>/, '') }.join("\n\n")
  end

  def as_react(ability, options = {})
    result = self.as_json(only: [:id, :headline, :subhead, :authors_string, :published_at, :print_status, :web_status, :created_at]).merge({
      primary_tag: self.primary_tag,
      authors_string: self.authors_string
    })
    result[:text] = self.text if options[:include_text]
    result
  end

  private
    def parse_html
      require 'parser'
      parser = Techplater::Parser.new(html)
      parser.parse!

      self.chunks = parser.chunks
      self.web_template = parser.template
    end

    def normalize_fields
      self.headline.strip!
      self.subhead.strip!
      self.bytitle.strip!
      self.lede.strip!
      self.attribution.strip!

      if self.redirect_url.present?
        (self.redirect_url = "http://" + self.redirect_url) unless self.redirect_url =~ /^http/
      end
    end

    def fill_lede
      if self.lede.blank?
        return if self.chunks.empty?
        self.lede = Nokogiri::HTML.fragment(self.chunks.first).text
      end
    end

    def touch_article
      self.article.touch
    end

    # This ensures that we at least have 1 tag as the primary tag
    # For Article without a primary tag, the first tag should be NO_PRIMARY_TAG
    def tag_list_is_valid
      errors.add(:base, "Invalid tag list: No primary tag slot. ") unless self.tag_list.size >= 1

      self.tag_list.each do |t|
        errors.add(:base, "Invalid tag list: Non-lowercase tag #{t}. ") unless t == t.downcase
      end
    end
end
