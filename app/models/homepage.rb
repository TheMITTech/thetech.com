class Homepage < ActiveRecord::Base
  serialize :layout

  before_save :assign_uuids

  SUBMODULE_TYPES = {
    'Article' => 'article',
    'Image' => 'img',
    'Image without caption' => 'img_nocaption',
    'Links' => 'links'
  }

  ROW_TYPES = {
    "1-1-1-1" => '1,1,1,1',
    "2-1-1" => '2,1,1',
    "1-2-1" => '1,2,1',
    "1-1-2" => '1,1,2',
    "3-1" => '3,1',
    "1-3" => '1,3',
    "2-2" => '2,2',
    "4" => '4'
  }

  enum status: [:draft, :publish_ready]

  def self.generate_uuid
    SecureRandom.uuid
  end

  def self.published
    self.order('created_at DESC').publish_ready.first
  end

  def published?
    self == self.class.published
  end

  private
    def assign_uuids
      self.layout = self.layout.map(&:with_indifferent_access)

      self.layout.each do |row|
        row[:uuid] ||= generate_uuid

        row[:modules].each do |mod|
          mod[:uuid] ||= generate_uuid

          mod[:submodules].each do |submod|
            submod[:uuid] ||= generate_uuid
          end
        end
      end
    end

    def generate_uuid
      SecureRandom.uuid
    end
end
