class ChangeDataTypeForTwitterListMemberIds < ActiveRecord::Migration[6.1]
  def up
    TwitterList.all.each do |twitter_list|
      begin
        next if twitter_list.member_ids.nil?

        twitter_list.member_ids = YAML.load(twitter_list.member_ids).to_json
        twitter_list.save!

      rescue Exception => e
        puts "Could not fix twitter list #{twitter_list.id} for #{e.message}"
      end
    end

    change_column :twitter_lists, :member_ids, :json
  end

  def down
    change_column :twitter_lists, :member_ids, :text
  end
end
