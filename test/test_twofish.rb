
require 'test/unit'
require 'twofish'

# Define some useful constants and test some basic properties.
class TestBasics < Test::Unit::TestCase

  NULL_KEY_16_BYTES = ("\0" * 16).freeze
  NULL_KEY_24_BYTES = ("\0" * 24).freeze
  NULL_KEY_32_BYTES = ("\0" * 32).freeze
  NULL_BLOCK = ("\0" * Twofish::BLOCK_SIZE).freeze
  BLOCK_SIZE = Twofish::BLOCK_SIZE

  def test_16_byte_key_size
    tf = Twofish.new(NULL_KEY_16_BYTES)
    assert_equal(tf.key_size, 16)
  end

  def test_24_byte_key_size
    tf = Twofish.new(NULL_KEY_24_BYTES)
    assert_equal(tf.key_size, 24)
  end

  def test_32_byte_key_size
    tf = Twofish.new(NULL_KEY_32_BYTES)
    assert_equal(tf.key_size, 32)
  end

  def test_invalid_key_size
    assert_raise ArgumentError do
      Twofish.new('short key')
    end
  end

  def test_block_size
    assert_equal(16, BLOCK_SIZE)
  end

  def test_default_mode
    assert_equal(Twofish::Mode::DEFAULT, Twofish::Mode::ECB)
  end

end

# Test the encryption vectors as given in the specification
# using block encryption (Electronic Code Book mode).
# On the way we check that each encrypted block successfully
# decrypts to the given plaintext.
class TestEcbEncryption < TestBasics

  def test_16_byte_key_encryption
    assert_equal(
      pack_bytes('5d9d4eeffa9151575524f115815a12e0'),
      repeated_block_encrypt(NULL_KEY_16_BYTES, NULL_BLOCK, 49)
    )
  end

  def test_24_byte_key_encryption
    assert_equal(
      pack_bytes('e75449212beef9f4a390bd860a640941'),
      repeated_block_encrypt(NULL_KEY_24_BYTES, NULL_BLOCK, 49)
    )
  end

  def test_32_byte_key_encryption
    assert_equal(
      pack_bytes('37fe26ff1cf66175f5ddf4c33b97a205'),
      repeated_block_encrypt(NULL_KEY_32_BYTES, NULL_BLOCK, 49)
    )
  end

  def test_padding_exception
    plaintext = 'short' # < BLOCKSIZE == 16 bytes
    key = pack_bytes('37fe26ff1cf66175f5ddf4c33b97a205')
    tf = Twofish.new(key)
    assert_raise ArgumentError do
      tf.encrypt(plaintext)
    end
  end

  def test_null_in_plaintext
    plaintext = "xxxxxxx\0\0yyyyyyy"
    key = pack_bytes('37fe26ff1cf66175f5ddf4c33b97a205')
    tf = Twofish.new(key)
    ciphertext = tf.encrypt(plaintext)
    assert_equal(plaintext, tf.decrypt(ciphertext))
  end

  def test_utf8_plaintext_invalid_length
    # this string is 16 chars in length, but 18 bytes
    plaintext = pack_bytes('72c3a973657276c3a96573') + # 11 bytes, 9 chars
      '1234567' # 7 bytes, 7 chars
    plaintext.force_encoding('UTF-8')
    key = pack_bytes('37fe26ff1cf66175f5ddf4c33b97a205')
    tf = Twofish.new(key)
    assert_raise ArgumentError do
      tf.encrypt(plaintext)
    end
  end

  def test_utf8_plaintext
    # this string is 16 bytes in length (but 14 chars)
    plaintext = pack_bytes('72c3a973657276c3a96573') + # 11 bytes, 9 chars
      '12345' # 5 bytes, 5 chars
    plaintext.force_encoding('UTF-8')
    key = pack_bytes('37fe26ff1cf66175f5ddf4c33b97a205')
    tf = Twofish.new(key)
    ciphertext = tf.encrypt(plaintext)
    assert_equal(plaintext.force_encoding('ASCII-8BIT'), tf.decrypt(ciphertext))
  end

  private

  # Convert ASCII hex representation into binary.
  def pack_bytes(byte_string)
    [byte_string].pack('H*')
  end

  # Repeatedly encrypt the given plain text n times
  # with the same key.
  def repeated_block_encrypt(key, plain, iterations)
    key_length = key.length
    iterations.times do
      tf = Twofish.new(key)
      cipher = tf.encrypt(plain)
      assert_equal(plain, tf.decrypt(cipher))
      key = (plain + key)[0, key_length]
      plain = cipher
    end
    plain
  end

end

# Test the Cipher Block Chaining mode.
class TestCbcEncryption < TestBasics

  #                 123456781234567812345678123456781234567812
 #LONG_PLAINTEXT = 'this message is longer than the block size'
 #LONG_CIPHERTEXT = ['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'].pack('H*')
 #KEY = ['5d9d4eeffa9151575524f115815a12e0'].pack('H*')
 #IV = ['e75449212beef9f4a390bd860a640941'].pack('H*')
  LONG_PLAINTEXT = ("\0"*32).freeze
  LONG_CIPHERTEXT = ['9f589f5cf6122c32b6bfec2f2ae8c35ad491db16e7b1c39e86cb086b789f5419'].pack('H*').freeze

  def test_encryption_decryption_random_iv
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc)
    plaintext = LONG_PLAINTEXT
    ciphertext = tf.encrypt(plaintext)
    assert_equal(LONG_PLAINTEXT, plaintext)
    iv = tf.iv
    tf2 = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc, :iv => iv)
    assert_equal(LONG_PLAINTEXT, tf2.decrypt(ciphertext))
    assert_equal(LONG_PLAINTEXT, plaintext)
  end

  def test_encryption_given_null_iv
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc, :iv => NULL_BLOCK)
    ciphertext = tf.encrypt(LONG_PLAINTEXT)
    assert_equal(LONG_PLAINTEXT.size, ciphertext.size)
    assert_equal(LONG_CIPHERTEXT, ciphertext)
  end

  def test_decryption_given_null_iv
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc, :iv => NULL_BLOCK)
    assert_equal(LONG_PLAINTEXT, tf.decrypt(LONG_CIPHERTEXT))
  end

  def test_encryption_decryption_incomplete_block
    tf1 = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc, :padding => :zero_byte)
    plaintext = 'abcdefghijklmnopqrst'
    ciphertext = tf1.encrypt(plaintext)
    iv = tf1.iv
    tf2 = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc, :iv => iv, :padding => :zero_byte)
    assert_equal(plaintext, tf2.decrypt(ciphertext))
  end

end

class TestInitializationVector < TestBasics

  def test_nil_iv_for_ecb_mode
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :ecb)
    assert_equal(nil, tf.iv)
  end

  def test_cannot_assign_iv_ecb_mode
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :ecb)
    assert_raise ArgumentError do
      tf.iv = '1234567812345678'
    end
  end

  def test_assign_bad_iv
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc)
    assert_raise ArgumentError do
      tf.iv = '1234'
    end
  end

  def test_generated_length
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc)
    assert_equal(BLOCK_SIZE, tf.iv.length)
  end

  def test_generated_not_srand
    tf1 = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc)
    tf2 = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc)
    assert_not_equal(tf1.iv, tf2.iv)
  end

end

# Test the available encryption modes.
class TestModes < TestBasics

  def test_default_mode
    tf = Twofish.new(NULL_KEY_16_BYTES)
    assert_equal(:ecb, tf.mode)
  end

  def test_unknown_mode
    assert_raise ArgumentError do
      tf = Twofish.new(NULL_KEY_16_BYTES)
      tf.mode = :unknown
    end
  end

  def test_unknown_mode_constructor
    assert_raise ArgumentError do
      Twofish.new(NULL_KEY_16_BYTES, :mode => :unknown)
    end
  end

  def test_cbc_mode_constructor_string
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => 'cbc')
    assert_equal(:cbc, tf.mode)
  end

  def test_cbc_mode_constructor_symbol
    tf = Twofish.new(NULL_KEY_16_BYTES, :mode => :cbc)
    assert_equal(:cbc, tf.mode)
  end

  def test_ecb_mode
    tf = Twofish.new(NULL_KEY_16_BYTES)
    tf.mode = :ecb
    assert_equal(:ecb, tf.mode)
  end

  def test_cbc_mode
    tf = Twofish.new(NULL_KEY_16_BYTES)
    tf.mode = :cbc
    assert_equal(:cbc, tf.mode)
  end

  def test_symbolize_mode
    tf = Twofish.new(NULL_KEY_16_BYTES)
    tf.mode = 'ecb'
    assert_equal(:ecb, tf.mode)
  end

end

class TestPadding < TestBasics

  TO_PAD = 'abcdef'.freeze

  def test_cipher_zero_byte_padding
    tf = Twofish.new(NULL_KEY_16_BYTES)
    tf.padding = :zero_byte
    assert_equal(:zero_byte, tf.padding)
  end

  def test_cipher_zero_byte_padding_constructor
    tf = Twofish.new(NULL_KEY_16_BYTES, :padding => :zero_byte)
    assert_equal(:zero_byte, tf.padding)
  end

  def test_cipher_iso10126_2_padding
    tf = Twofish.new(NULL_KEY_16_BYTES)
    tf.padding = :iso10126_2
    assert_equal(:iso10126_2, tf.padding)
  end

  def test_cipher_iso10126_2_padding_constructor
    tf = Twofish.new(NULL_KEY_16_BYTES, :padding => :iso10126_2)
    assert_equal(:iso10126_2, tf.padding)
  end

  def test_cipher_unknown_padding
    tf = Twofish.new(NULL_KEY_16_BYTES)
    assert_raise ArgumentError do
      tf.padding = :unknown
    end
  end

  def test_cipher_unknown_padding_constructor
    assert_raise ArgumentError do
      Twofish.new(NULL_KEY_16_BYTES, :padding => :unknown)
    end
  end

  def test_symbolize_padding
    assert_equal(:zero_byte, Twofish::Padding::validate('zero_byte'))
  end

  def test_pad_none
    assert_raise ArgumentError do
      Twofish::Padding::pad(TO_PAD, BLOCK_SIZE, :none)
    end
  end

  def test_unpad_none
    assert_equal(TO_PAD+"\0"*10, Twofish::Padding::unpad(TO_PAD+"\0"*10, BLOCK_SIZE, :none))
  end

  def test_pad_zero_byte
    assert_equal(TO_PAD+"\0"*10, Twofish::Padding::pad(TO_PAD, BLOCK_SIZE, :zero_byte))
  end

  def test_unpad_zero_byte
    assert_equal(TO_PAD, Twofish::Padding::unpad(TO_PAD+"\0"*10, BLOCK_SIZE, :zero_byte))
  end

  def test_pad_block_size_zero_byte
    to_pad = TO_PAD * BLOCK_SIZE
    assert_equal(to_pad, Twofish::Padding::pad(to_pad, BLOCK_SIZE, :zero_byte))
  end

  def test_pad_iso10126_2
    padded_text = Twofish::Padding::pad(TO_PAD, BLOCK_SIZE, :iso10126_2)
    assert_match(/\A#{TO_PAD}/, padded_text)
    assert_equal(TO_PAD.length + 10, padded_text.length)
  end

  def test_unpad_iso10126_2
    bytes = Array.new(10 - 1) {rand(256)}
    bytes << 10
    assert_equal(TO_PAD, Twofish::Padding::unpad(TO_PAD+bytes.pack("C*"), BLOCK_SIZE, :iso10126_2))
  end

  def test_pad_block_size_iso10126_2
    to_pad = TO_PAD * BLOCK_SIZE
    padded_text = Twofish::Padding::pad(to_pad, BLOCK_SIZE, :iso10126_2)
    assert_equal(to_pad.length + BLOCK_SIZE, padded_text.length)
    assert_match(/\A#{to_pad}/, padded_text)
  end
end
