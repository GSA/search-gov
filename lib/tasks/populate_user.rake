# frozen_string_literal: true

namespace :usasearch do
  namespace :populate_user_fields do
    desc 'populate first and last name in the user table'
    task :update_first_last_name, [:path] => [:environment] do |_t, args|
      CSV.foreach(args.path, headers: true) do |row|
        record = row.to_h
        @user = User.find_by(email: record['Email'])
        @user&.update!(first_name: record['First Name'], last_name: record['Last Name'])
        puts "updating #{record['Email']} with " \
             "#{record['First Name']} #{record['Last Name']}"
      end
    end
  end
end
