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

end
