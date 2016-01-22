rails_env = new_resource.environment["RAILS_ENV"]

# Make sure the DB exists before doing anything else
usasearch_rails_database :monolith do
  create_dir release_path
end

# Pre-compile assets
run "cd #{release_path} && RAILS_ENV=#{rails_env} RAILS_GROUPS=assets bundle exec rake assets:maybe_precompile"
