# frozen_string_literal: true

class MigrateBingAffiliatesToOpensearch < ActiveRecord::Migration[7.1]
  def up
    execute(<<~SQL.squish)
      UPDATE affiliates SET search_engine = 'OpenSearch'
      WHERE search_engine IN ('BingV7', 'bing_v7', 'Bing', 'BingV6')
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
