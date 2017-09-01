# This is custom middleware based on the 'rashify' middleware from the faraday_middleware gem.
#
# Unfortunately, that middleware is based on the 'rash' gem...
# whose Hashie::Rash class conflicts with Hashie's newer (and unrelated) Hashie::Rash class.
# This middleware uses the Hashie::Mash::Rash class, which is the non-conflicting
# version from the rash_alt gem. The rash_alt gem, unfortunately, depends on hashie 3.4...
# which breaks our current implementation of all of the above, hence our
# custom branch of rash_alt that allows us to use a lesser version of hashie.
# A PR has been opened to update faraday_middleware...
# whose current version conflicts with the dependencies in the instagram gem...
# which was deprecated in 2015 and which only remains in our code because we haven't torn it out yet...

module FaradayMiddleware
  # Public: Converts parsed response bodies to a Hashie::Rash if they were of
  # Hash or Array type.
  class MRashify < Mashify
    dependency do
      require 'rash'
      self.mash_class = ::Hashie::Mash::Rash
    end
  end
end
