
require 'benchmark'

require 'twofish'

m = 10000
n = 100000
key = ['5d9d4eeffa9151575524f115815a12e0'].pack('H*')
block = ['e75449212beef9f4a390bd860a640941'].pack('H*')
tf = Twofish.new(key)

Benchmark.bm(7) do |x|
  x.report('new') { m.times do ; Twofish.new(key) ; end }
  x.report('encrypt') { n.times do ; tf.encrypt(block) ; end }
  x.report('decrypt') { n.times do ; tf.decrypt(block) ; end }
end

