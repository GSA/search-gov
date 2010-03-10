require 'sass'

if /production|test|cucumber/.match(RAILS_ENV)
  # Compress CSS (a small file is preferable in production)
  Sass::Plugin.options[:style] = :compressed
else
  # Expand CSS
  Sass::Plugin.options[:style] = :expanded

  # Generate CSS from SASS every time a controller is accessed
  Sass::Plugin.options[:always_update] = true

  # Insert comments in the CSS about the line numbers of the Sass source
  Sass::Plugin.options[:line_comments] = true
end