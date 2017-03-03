class Homepage < AbstractModel
  serialize :layout

  before_save :assign_uuids

  SUBMODULE_TYPES = {
    'Article' => 'article',
    'Image' => 'img',
    'Image without caption' => 'img_nocaption',
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

  enum status: [:draft, :publish_ready, :published]

  def self.generate_uuid
    SecureRandom.uuid
  end

  def self.latest_published
    self.published.order('created_at DESC').first
  end

  def fold_article_ids
    output = []
    self.layout.each do |r|
      r[:modules].each do |m|
        m[:submodules].each do |s|
          output << s[:article_id].to_i if s[:type] == 'article'
        end
      end
    end
    output.uniq
  end

  def fold_image_ids
    output = []
    self.layout.each do |r|
      r[:modules].each do |m|
        m[:submodules].each do |s|
          output << s[:image_id] if (s[:type] == 'img' || s[:type] == 'img_nocaption')
        end
      end
    end
    output.uniq
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
