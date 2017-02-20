class NotNilValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must not be nil" if value.nil?
  end
end