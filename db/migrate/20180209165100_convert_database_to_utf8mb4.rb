class ConvertDatabaseToUtf8mb4 < ActiveRecord::Migration
  DATABASE_NAME = Rails.configuration.database_configuration[Rails.env]['database']
  ALL_TABLES = ActiveRecord::Base.connection.tables.freeze
  CONVERT_DATA_TYPES=/( varchar\(\d+\) | text | mediumtext | longtext )/

  def do_sql(sql)
    execute sql
  end

  def change_database_charset(charset)
    collation = "#{charset}_unicode_ci"

    do_sql "ALTER DATABASE #{DATABASE_NAME} CHARACTER SET = #{charset} COLLATE = #{collation}"

    ALL_TABLES.each do |table|
      do_sql "ALTER IGNORE TABLE #{table} CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"

      columns_to_modify = ActiveRecord::Base.connection.select_all("SHOW CREATE TABLE #{table}").rows[0][1].split(/\n/).select { |col| col =~ CONVERT_DATA_TYPES }

      if columns_to_modify.any?
        modified = columns_to_modify.map do |field|
          stripped = field.gsub(/CHARACTER SET utf8(mb4)? /, '').gsub(/COLLATE utf8(mb4)?_(unicode|general)_ci/, '').gsub(/,$/, '')
          if stripped =~ CONVERT_DATA_TYPES
            "MODIFY " + stripped.gsub(CONVERT_DATA_TYPES, $1 + " CHARACTER SET #{charset} COLLATE #{collation}")
          else
            raise("can't find match for #{CONVERT_DATA_TYPES} in #{stripped}")
          end
        end 
        do_sql "ALTER IGNORE TABLE `#{table}` " + modified.join(', ') 
      end
    end
  end

  def up
    ALL_TABLES.each do |table|
      # Only do this ROW_FORMAT change when migrating up. When migrating down, it is
      # necessary to leave this change intact to avoid the dreaded InnoDB engine
      # "Index column size too large. The maximum column size is 767 bytes" error
      do_sql "ALTER IGNORE TABLE #{table} ROW_FORMAT=DYNAMIC"
    end

    change_database_charset(:utf8mb4)
  end

  def down
    change_database_charset(:utf8)
  end
end
