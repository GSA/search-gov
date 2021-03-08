require 'spec_helper'

describe Filetype do

  describe '#content_type' do
    { %w(jpg jpe jpeg) => 'image/jpeg',
      %w(tif tiff)     => 'image/tiff',
      %w(png)          => 'image/png',
      %w(gif)          => 'image/gif',
      %w(bmp)          => 'image/bmp',
      %w(txt)          => 'text/plain',
      %w(htm html)     => 'text/html',
      %w(csv)          => 'text/csv',
      %w(xml)          => 'text/xml',
      %w(css)          => 'text/css',
      %w(js)           => 'application/js',
      %w(foo)          => 'application/x-foo'
    }.each do |extensions, content_type|
      extensions.each do |extension|
        it "returns a content_type of #{content_type} for a file with extension .#{extension}" do
          file = double('file', path: "basename.#{extension}")
          class << file
            include Filetype
          end

          expect(file.content_type).to eq(content_type)
        end
      end
    end
  end
end
