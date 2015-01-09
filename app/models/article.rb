class Article < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pieces

  validates :title, presence: true, length: {minimum: 2}

  serialize :chunks

  before_save :parse_html!

  def parse_html!
    require 'techplater'

    parser = Techplater::Parser.new(self.html)
    parser.parse!

    self.chunks = parser.chunks
    self.pieces.each { |p| p.update(web_template: parser.template) }
  end

  def asset_images
    self.pieces.map { |p| p.images }.flatten.to_a.uniq(&:id)
  end

  def incopy_tagged_text
    content = ""

    content += "<ASCII-MAC>\n"
    content += "<pstyle:ALL-Byline w\\/ Title>#{self.title} By #{self.byline}\n"
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

    content
  end
end
