class AbstractModel < ActiveRecord::Base
  self.abstract_class = true

  if ENV["tech_app_role"] == 'frontend'
    def self.delete_all
      raise ActiveRecord::ReadOnlyRecord
    end

    def readonly?
      true
    end

    def before_destroy
      raise ActiveRecord::ReadOnlyRecord
    end

    def delete
      raise ActiveRecord::ReadOnlyRecord
    end
  end
end