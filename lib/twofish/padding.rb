class Twofish
  
  # Implements padding modes to make plaintext into a complete
  # number of blocks before encryption and to remove that padding
  # after successful decryption.
  #
  # The only implemented padding schemes are :none and
  # :zero_byte. Note that zero byte padding is potentially
  # dangerous because if the plaintext terminates in
  # zero bytes then these will be erroneously removed by #unpad.
  # A more sensible padding scheme should be used in this case.
  module Padding

    # Use no padding.
    NONE = :none

    # Use zero byte padding.
    ZERO_BYTE = :zero_byte

    # Use ISO 10126-2 padding.
    ISO10126_2 = :iso10126_2

    # Use PKCS7 byte padding.
    PKCS7 = :pkcs7

    # Array of all known paddings.
    ALL = [NONE, ZERO_BYTE, ISO10126_2, PKCS7]

    # Default padding (none).
    DEFAULT = NONE

    # Takes a string or symbol and returns the lowercased
    # symbol representation if this is a recognized padding scheme.
    # Otherwise, throws ArgumentError.
    def self.validate(scheme)
      scheme_sym = scheme.nil? ? DEFAULT : scheme.to_s.downcase.to_sym
      raise ArgumentError, "unknown padding scheme #{scheme.inspect}" unless ALL.include? scheme_sym
      scheme_sym
    end

    # Pad the given plaintext to a complete number of blocks,
    # returning a new string. See #pad!.
    def self.pad(plaintext, block_size, scheme=DEFAULT)
      self.pad!(plaintext.dup, block_size, scheme)
    end

    # Pad the given plaintext to a complete number of blocks,
    # returning a new string. If the padding scheme is :none
    # and the plaintext is not a whole number of blocks then
    # ArgumentError is thrown.
    def self.pad!(plaintext, block_size, scheme=DEFAULT)
      remainder = plaintext.length % block_size
      case validate(scheme)
      when NONE
        raise ArgumentError, "no padding scheme specified and plaintext length is not a multiple of the block size" unless remainder.zero?
        plaintext
      when ZERO_BYTE
        remainder.zero? ? plaintext : plaintext << "\0" * (block_size - remainder)
      when ISO10126_2
          number_of_pad_bytes = block_size - remainder
          # Create random bytes
          bytes = Array.new(number_of_pad_bytes - 1) {rand(256)}
          # The last byte specify the total pad byte size
          bytes << number_of_pad_bytes
          plaintext << bytes.pack("C*")
      when PKCS7
        padding_length = (block_size - remainder - 1) % block_size + 1
        plaintext << [padding_length].pack('C*') * padding_length
      end
    end

    # Unpad the given plaintext using the given scheme, returning
    # a new string. See #unpad!.
    def self.unpad(plaintext, block_size, scheme=DEFAULT)
      self.unpad!(plaintext.dup, block_size, scheme)
    end

    # Unpad the given plaintext in place using the given scheme.
    def self.unpad!(plaintext, block_size, scheme=DEFAULT)
      case validate(scheme)
      when NONE
        plaintext.dup
      when ZERO_BYTE
        plaintext.sub(/\000+\Z/, '')
      when ISO10126_2
        number_of_pad_bytes = plaintext.bytes.to_a[plaintext.length-1]
        plaintext[0, (plaintext.length - number_of_pad_bytes)]
      when PKCS7
        # the padding length equals to the codepoint of the last char
        padding_length = plaintext[-1..-1].unpack('C*')[0]
        plaintext[0..(-1 * (padding_length + 1))]
      end
    end
  end

end

