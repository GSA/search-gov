namespace :usasearch do
  namespace :l10n do
    desc 'Update image and video navigation labels with localized text'
    task update_navigable_names: :environment do
      navigable_name_updater = NavigableNameUpdater.new
      navigable_name_updater.update
    end
  end
end
