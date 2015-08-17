os = require 'os'
should = require 'should'
_require = require 'require-uncached'

platform = os.platform()
platformChecked = no
os.platform = ->
  platformChecked = yes
  platform

it 'should check the platform', ->
  pipe = _require '../'
  platformChecked.should.equal yes

it 'should specify /dev/stdin on linux', ->
  platform = 'linux'
  pipe = _require '../'
  res = pipe null
  res.file.should.equal '/dev/stdin'

it 'should specify /dev/stdin on macosx', ->
  platform = 'darwin'
  pipe = _require '../'
  res = pipe null
  res.file.should.equal '/dev/stdin'

it 'should specify a tmp file on windows', ->
  platform = 'win32'
  pipe = _require '../'
  res = pipe new Buffer 0
  (/\.tmp$/.test res.file).should.be.ok()

it 'should provide the source buffer on linux', ->
  platform = 'linux'
  pipe = _require '../'
  res = pipe (buf = new Buffer 0)
  res.buffer.should.equal buf

it 'should provide the source buffer on macosx', ->
  platform = 'darwin'
  pipe = _require '../'
  res = pipe (buf = new Buffer 0)
  res.buffer.should.equal buf

it 'should provide an empty buffer on windows', ->
  platform = 'win32'
  pipe = _require '../'
  res = pipe new Buffer 1
  res.buffer.length.should.equal 0

checkClean = (plat)->
  it "should provide a cleanup function on #{plat}", ->
    platform = plat
    pipe = _require '../'
    res = pipe null
    (should res.clean).be.a.Function()

checkClean 'darwin'
checkClean 'linux'
checkClean 'win32'
