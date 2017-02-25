class Article < ActiveRecord::Base
  include ArticleXmlExportable

  default_scope -> { order('created_at DESC') }
  scope :web_published, -> { joins(:drafts).where('drafts.web_status = ?', Draft.web_statuses[:web_published]).distinct }

  has_many :drafts, dependent: :destroy
  has_many :legacy_comments, dependent: :destroy, as: :legacy_commentable
  belongs_to :section
  belongs_to :issue
  has_and_belongs_to_many :images

  acts_as_paranoid

  validates :slug, presence: true, uniqueness: true, length: {minimum: 5, maximum: 80}, format: {with: /\A[a-z0-9-]+\z/}
  validates :section, presence: true
  validates :issue, presence: true
  validates :rank, presence: true
  validates :syndicated, not_nil: true
  validates :allow_ads, not_nil: true

  RANKS = ([99] + (0..98).to_a)

  # REBIRTH_TODO: API

  # Frontend search related stuff
  searchkick ignore_above: 32767

  scope :search_import, -> { web_published }

  default_scope { includes([:section, :issue]) }

  def should_index?
    self.has_web_published_draft?
  end

  def search_data
    draft = self.newest_web_published_draft

    {
      headline: draft.headline,
      subhead: draft.subhead,
      lede: draft.lede,
      attribution: draft.attribution,
      text: draft.chunks.map { |c| Nokogiri::HTML.fragment(c).text }.join("\n"),
      authors: draft.authors_string,
      tags: draft.tag_list.join(","),
    }
  end

  # Accesses various Draft-s of the Article
  def has_print_ready_draft?
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.print_ready.any?
    end
  end

  def has_web_ready_draft?
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_ready.any?
    end
  end

  def has_web_published_draft?
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_published.any?
    end
  end

  def has_pending_draft?
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      newest_web_ready_draft = self.drafts.web_ready.order('created_at DESC').first
      next false if newest_web_ready_draft.nil?
      next true if !self.has_web_published_draft?
      next newest_web_ready_draft.created_at > self.newest_web_published_draft.created_at
    end
  end

  def newest_web_published_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_published.order('created_at DESC').first
    end
  end

  def oldest_web_published_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_published.order('created_at DESC').last
    end
  end

  def newest_web_ready_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_ready.order('created_at DESC').first
    end
  end

  def oldest_web_ready_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_ready.order('created_at DESC').last
    end
  end

  def newest_print_ready_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.print_ready.order('created_at DESC').first
    end
  end

  def oldest_print_ready_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.print_ready.order('created_at DESC').last
    end
  end

  def newest_draft
    Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.order('created_at DESC').first
    end
  end

  # TODO: Created specifically for _article_select.html.erb
  # Would rather not have
  delegate :headline, to: :newest_web_published_draft, prefix: 'newest_web_published'
  delegate :headline, to: :newest_draft, prefix: 'newest'

  # We define the publish time of an article to be the publish time of its oldest web_published draft
  delegate :published_at, to: :oldest_web_published_draft
end
