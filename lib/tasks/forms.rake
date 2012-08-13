namespace :usasearch do
  namespace :forms do
    desc "import forms"
    task :import => :environment do
      UscisForm.import
    end
  end
end
