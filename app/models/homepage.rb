class Homepage < ActiveRecord::Base
  serialize :layout

  before_save :assign_uuids

  SUBMODULE_TYPES = {
    'Article' => 'article',
    'Image' => 'img',
    'Image without caption' => 'img_nocaption',
    'Links' => 'links'
  }

  enum status: [:draft, :publish_ready]

  def self.generate_uuid
    SecureRandom.uuid
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