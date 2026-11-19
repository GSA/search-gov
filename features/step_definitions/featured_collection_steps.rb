Given /^the following featured collections exist for the affiliate "([^"]*)":$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |attributes|
    attrs = attributes.except(* %w(image_file_path keywords publish_end_on publish_start_on))

    publish_start_on = attributes[:publish_start_on]
    if publish_start_on.blank? || publish_start_on == 'today'
      publish_start_on = Date.current
    elsif publish_start_on =~ /^[a-zA-Z_]+$/
      publish_start_on = Date.current.send(publish_start_on.to_sym)
    end
    attrs[:publish_start_on] = publish_start_on

    publish_end_on = attributes[:publish_end_on]
    if publish_end_on == 'today'
      publish_end_on = Date.current
    elsif publish_end_on =~ /^[a-zA-Z_]+$/
      publish_end_on = Date.current.send(publish_end_on.to_sym)
    end
    attrs[:publish_end_on] = publish_end_on

    if attributes[:image_file_path].present?
      image = File.open "#{Rails.root}/#{attributes[:image_file_path]}"
      attrs[:image] = image
    end

    if attributes[:keywords].present?
      index = -1
      keyword_attributes = attributes[:keywords].split(',').map do |keyword|
        index += 1
        [index.to_s, { value: keyword }]
      end
      attrs[:featured_collection_keywords_attributes] = Hash[keyword_attributes]
    end

    affiliate.featured_collections.create!(attrs)
    ElasticFeaturedCollection.commit
  end
end
