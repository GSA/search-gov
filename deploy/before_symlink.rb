rails_env = new_resource.environment["RAILS_ENV"]

# Make sure the DB exists before doing anything else
dgsearch_rails_database :usasearch do
  create_dir release_path
  user 'search'
  group 'www-data'
end

# Compiled assets always end with 32 hex characters.
# Bash sux and doesn't support [0-9a-f]{32}, and if
# you type [0-9a=f] 32 times you get "File name too long",
# so we'll match using any 32 characters. Meh.
TTHC = "?"*32

# Pre-compile assets. Also, a very small subset of the assets
# need to be available without digest fingerprints in their
# filenames - assets that live "in the wild" and can't be
# updated whenever our asset fingerprints change.
run <<COMPILE
  cd #{release_path} && \
  RAILS_ENV=#{rails_env} bundle exec rake assets:precompile && \
  cd #{release_path}/public/assets && \
  for js in sayt_loader_libs sayt_loader stats; do cp ${js}-#{TTHC}.js ${js}.js && cp ${js}-#{TTHC}.js.gz ${js}.js.gz; done && \
  for css in sayt; do cp ${css}-#{TTHC}.css ${css}.css && cp ${css}-#{TTHC}.css.gz ${css}.css.gz; done && \
  for png in bootstrap/glyphicons-halflings bootstrap/glyphicons-halflings-white; do cp ${png}-#{TTHC}.png ${png}.png; done && \
  find . -type f -perm 600 | xargs --no-run-if-empty chmod 644
COMPILE
