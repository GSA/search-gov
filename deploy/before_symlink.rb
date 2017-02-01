rails_env = new_resource.environment["RAILS_ENV"]

# Make sure the DB exists before doing anything else
dgsearch_rails_database :usasearch do
  create_dir release_path
end

# Pre-compile assets
run "cd #{release_path} && RAILS_ENV=#{rails_env} RAILS_GROUPS=assets bundle exec rake assets:maybe_precompile && cd #{release_path}/public/assets && find . -type f -perm 600 | xargs --no-run-if-empty chmod 644"
