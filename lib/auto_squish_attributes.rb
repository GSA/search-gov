# inspired from https://github.com/holli/auto_strip_attributes/blob/master/lib/auto_strip_attributes.rb
module AutoSquishAttributes
  def auto_squish_attributes(*attributes)
    attributes.each do |attr|
      before_validation do |record|
        value = record[attr]
        record[attr] = value.squish if value.present?
      end
    end
  end
end
