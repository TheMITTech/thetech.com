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

  def authors_line
    read_attribute(:authors_line) || authors_line_from_author_ids
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

  def incopy_tagged_text
    content = ""

    content += "<UNICODE-MAC>\n"
    content += "<pstyle:ALL-Byline w\\/ Title>#{self.headline} By #{self.authors_line}\n"
    content += "<pstyle:ALL-By Title>#{self.bytitle}\n"

    self.chunks.each do |c|
      chunk = Nokogiri::HTML.fragment(c)
      fc = chunk.children.first

      if fc.name.to_sym == :p
        content += "<pstyle:ALL-Body>"
        fc.children.each do |c|
          case c.name.to_sym
          when :text
            content += c.text
          when :a
            content += c.content
          when :em
            content += "<ct:Italic>#{c.text}<ct:>"
          when :strong
            content += "<ct:Bold>#{c.text}<ct:>"
          end
        end
        content += "\n"
      end
    end

    content.encode('utf-16')
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
