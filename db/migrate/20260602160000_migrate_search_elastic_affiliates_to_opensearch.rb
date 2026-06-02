# frozen_string_literal: true

class MigrateSearchElasticAffiliatesToOpenSearch < ActiveRecord::Migration[7.1]
  def up
    execute(<<~SQL.squish)
      UPDATE affiliates SET search_engine = 'OpenSearch' WHERE search_engine = 'SearchElastic'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
