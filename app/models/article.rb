class Article < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :piece
  belongs_to :section

  validates :headline, presence: true, length: {minimum: 2}

  serialize :chunks

  before_save :parse_html
  before_save :create_associated_piece
  after_save :update_piece

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
    content += "<pstyle:ALL-Byline w\\/ Title>#{self.subhead} By #{self.byline}\n"
    content += "<pstyle:ALL-By Title>#{self.dateline}\n"

    self.chunks.each do |c|
      chunk = Nokogiri::HTML.fragment(c)
      fc = chunk.children.first

      if fc.name.to_sym == :p
        content += "<pstyle:ALL-Body>"
        fc.children.each do |c|
          case c.name.to_sym
          when :text
            content += c.text
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
    def create_associated_piece
      self.piece = Piece.create if self.piece.nil?
    end

    def parse_html
      require 'techplater'

      @parser = Techplater::Parser.new(self.html)
      @parser.parse!

      self.chunks = @parser.chunks
    end

    def update_piece
      self.piece.update(web_template: @parser.template)
    end
end
