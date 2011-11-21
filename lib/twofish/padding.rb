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

    # Array of all known paddings.
    ALL = [ NONE, ZERO_BYTE ]

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
      end
    end

  end

end

