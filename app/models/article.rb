class Article < ActiveRecord::Base
  include ArticleXmlExportable
  include MessageBusPublishable

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
  searchkick ignore_above: 32767, index_prefix: (ENV["ELASTICSEARCH_PREFIX"].presence || "development"), batch_size: 100

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
      published_at: self.oldest_web_published_draft.published_at,
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

  def pending_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      newest_web_ready_draft = self.drafts.web_ready.order('created_at DESC').first
      next nil if newest_web_ready_draft.nil?
      next newest_web_ready_draft.id if !self.has_web_published_draft?
      next newest_web_ready_draft.id if newest_web_ready_draft.created_at > self.newest_web_published_draft.created_at
      nil
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def newest_web_published_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_published.order('created_at DESC').first.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def oldest_web_published_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_published.order('created_at DESC').last.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def newest_web_ready_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_ready.order('created_at DESC').first.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def oldest_web_ready_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.web_ready.order('created_at DESC').last.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def newest_print_ready_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.print_ready.order('created_at DESC').first.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def oldest_print_ready_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.print_ready.order('created_at DESC').last.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def newest_draft
    id = Rails.cache.fetch("#{self.cache_key}/#{__method__}") do
      self.drafts.order('created_at DESC').first.try(:id)
    end

    id.nil? ? nil : self.drafts.detect { |d| d.id == id }
  end

  def as_react(ability)
    self.as_json(only: [:id, :slug, :rank]).merge({
      has_web_published_draft: self.has_web_published_draft?,
      has_web_ready_draft: self.has_web_ready_draft?,
      has_print_ready_draft: self.has_print_ready_draft?,
      has_pending_draft: self.has_pending_draft?,
      section: self.section.as_react(ability),
      issue: self.issue.as_react(ability),
      newest_draft: self.newest_draft.try(:as_react, ability),
      oldest_web_published_draft: self.oldest_web_published_draft.try(:as_react, ability),
      pending_draft: self.pending_draft.try(:as_react, ability),
      brief: self.brief?,

      can_update: ability.can?(:update, self),
      can_ready: ability.can?(:ready, self),
      can_publish: ability.can?(:publish, self),
      can_unpublish: ability.can?(:unpublish, self),
      can_destroy: ability.can?(:destroy, self),
      can_update_rank: ability.can?(:update_rank, self)
    })
  end

  # TODO: Created specifically for _article_select.html.erb
  # Would rather not have
  delegate :headline, to: :newest_web_published_draft, prefix: 'newest_web_published'
  delegate :headline, to: :newest_draft, prefix: 'newest'

  # We define the publish time of an article to be the publish time of its oldest web_published draft
  delegate :published_at, to: :oldest_web_published_draft
end
