class Twofish

  # Encryption modes.
  #
  # The only currently implemented modes are ECB (Electronic Code Book)
  # and CBC (Cipher Block Chaining).
  module Mode

    # Electronic code book mode.
    ECB = :ecb

    # Cipher block chaining mode.
    CBC = :cbc

    # Array of all known modes.
    ALL = [CBC, ECB]

    # Default mode (ECB).
    DEFAULT = ECB

    # Takes a string or symbol and returns the lowercased
    # symbol representation if this is a recognized mode.
    # Otherwise, throws ArgumentError.
    def self.validate(mode)
      mode_sym = mode.nil? ? DEFAULT : mode.to_s.downcase.to_sym
      raise ArgumentError, "unknown cipher mode #{mode.inspect}" unless ALL.include? mode_sym
      mode_sym
    end

  end

end

