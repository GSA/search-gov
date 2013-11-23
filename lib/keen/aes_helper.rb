require 'openssl'
require 'digest'
require 'base64'

module Keen
  module AESHelper

    BLOCK_SIZE = 32

    def aes256_encrypt(key, plaintext)
      aes = OpenSSL::Cipher::AES.new(256, :CBC)
      aes.encrypt
      aes.key = key
      iv = aes.random_iv
      [aes.update(plaintext) + aes.final, iv]
    end

    def hexlify(msg)
      msg.unpack('H*')[0]
    end

    def pad(msg)
      pad_len = BLOCK_SIZE - (msg.length % BLOCK_SIZE)
      padding = pad_len.chr * pad_len
      padded = msg + padding
      padded
    end
  end
end
