class Homepage < ActiveRecord::Base
  serialize :layout

  before_save :assign_uuids

  private
    def assign_uuids
      layout.each do |row|
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