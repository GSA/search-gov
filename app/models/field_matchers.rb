class FieldMatchers
  def self.build(query, table_fields_hash)
    field_clauses = table_fields_hash.map do |table, substring_search_fields|
      substring_search_fields.map do |field|
        "#{table.to_s}.#{field} LIKE ?"
      end
    end.flatten.join(" OR ")
    values = Array.new(table_fields_hash.values.flatten.size, "%#{query}%")
    [field_clauses, *values]
  end

end