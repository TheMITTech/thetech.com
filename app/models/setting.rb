class Setting < ActiveRecord::Base

  validates :key, length: {minimum: 1, maximum: 100},
                  format: {with: /[a-zA-Z0-9_]+/}

  serialize :value

  def self.get(key)
    setting = Setting.find_by(key: key)
    setting ? setting.value : nil
  end

  def self.set(key, value)
    setting = Setting.find_or_create_by(key: key)
    setting.value = value
    setting.save!
  end

end
