require 'multi_json'
require 'keen/aes_helper'

module Keen
  class ScopedKey
    include AESHelper
    extend AESHelper

    attr_accessor :api_key
    attr_accessor :data

    def initialize(api_key, data)
      self.api_key = api_key
      self.data = data
    end

    def encrypt!
      json_str = MultiJson.dump(self.data)
      padded_api_key = pad(self.api_key)
      encrypted, iv = aes256_encrypt(padded_api_key, json_str)
      hexlify(iv) + hexlify(encrypted)
    end
  end
end
