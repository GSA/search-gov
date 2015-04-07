namespace :usasearch do
  namespace :nutshell do
    desc 'push users'
    task :push_users => :environment do
      adapter = NutshellAdapter.new
      User.all.each { |u| adapter.push_user u }
    end

    desc 'push users without nutshell_id'
    task :push_users_without_nutshell_id => :environment do
      adapter = NutshellAdapter.new
      User.where(nutshell_id: nil).each { |u| adapter.push_user u }
    end

    desc 'push sites'
    task :push_sites => :environment do
      adapter = NutshellAdapter.new
      Affiliate.all.each { |a| adapter.push_site a }
    end
  end
end
