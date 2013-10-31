class InitializeDapSettings < ActiveRecord::Migration
  def up
    execute 'update affiliates set dap_enabled=0 where id in (1024,1025)'
  end

  def down
  end
end
