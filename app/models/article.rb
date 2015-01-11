class Article < ActiveRecord::Base
  has_and_belongs_to_many :users

  belongs_to :piece

  validates :headline, presence: true, length: {minimum: 2}

  serialize :chunks
  serialize :author_ids

  before_save :parse_html
  after_save :update_piece_web_template

  scope :search_query, lambda { |q|
    return nil if q.blank?

    terms = q.downcase.split(/\s+/)

    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conds = 2
    where(
      terms.map { |t|
        "(LOWER(articles.headline) LIKE ? OR LOWER(articles.subhead) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  def author_ids=(author_ids)
    write_attribute(:author_ids, author_ids.split(',').map(&:to_i))
  end

  def author_ids
    read_attribute(:author_ids).join(",")
  end

  def authors
    read_attribute(:author_ids).map { |x| Author.find(x) }
  end

  def authors_line
    case authors.size
    when 0
      ""
    when 1
      authors.first.name
    when 2
      "#{authors.first.name} and #{authors.last.name}"
    else
      (authors[0...-1].map(&:name) + ["and #{authors.last.name}"]).join(', ')
    end
  end

  def asset_images
    if self.piece
      self.piece.images
    else
      []
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
end
