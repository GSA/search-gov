# This module is shamelessly stolen from the deprecated paperclip-cloudfiles gem, which is no longer in our repo:
# https://github.com/mrrooijen/paperclip-cloudfiles/blob/ff5cb2adcdb2ef62e7c07b38db44525b47cd1dd3/lib/paperclip/upfile.rb
# At some point, we should probably do this a bit smrter.

module Filetype
  # Infer the MIME-type of the file from the extension.
  def content_type
    type = (self.path.match(/\.(\w+)$/)[1] rescue "octet-stream").downcase
    case type
    when %r"jp(e|g|eg)"            then "image/jpeg"
    when %r"tiff?"                 then "image/tiff"
    when %r"png", "gif", "bmp"     then "image/#{type}"
    when "txt"                     then "text/plain"
    when %r"html?"                 then "text/html"
    when "js"                      then "application/js"
    when "csv", "xml", "css"       then "text/#{type}"
    else
      # On BSDs, `file` doesn't give a result code of 1 if the file doesn't exist.
      content_type = (Paperclip.run("file", "--mime-type", self.path).split(':').last.strip rescue "application/x-#{type}")
      content_type = "application/x-#{type}" if content_type.match(/\(.*?\)/)
      content_type
    end
  end
end

class File #:nodoc:
  include Filetype
end
