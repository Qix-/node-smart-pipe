os = require 'os'
should = require 'should'
path = require 'path'
fs = require 'fs'
{exec} = require 'child_process'
{execSync} = require 'child_process'
_require = require 'require-uncached'

_platform = os.platform
platform = _platform()
typeCat = if platform is 'win32' then 'type' else 'cat'
platformChecked = no
os.platform = ->
  platformChecked = yes
  platform

it 'should check the platform', ->
  pipe = _require '../'
  platformChecked.should.equal yes

it 'should specify /dev/fd/0,nofork on linux', ->
  platform = 'linux'
  pipe = _require '../'
  res = pipe null
  res.file.should.equal '/dev/fd/0,nofork'

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

if execSync # node 0.10 doesn't have execSync for some reason.
  it 'should execute cat/type correctly (sync)', ->
    platform = _platform()
    pipe = _require '../'
    inputSource = fs.readFileSync path.resolve path.join __dirname,
      '../package.json'
    res = pipe inputSource
    output = execSync "#{res.command} #{typeCat} #{res.file}",
      input: res.buffer
    res.clean()
    (JSON.parse output).name.should.equal 'smart-pipe'

it 'should execute cat/type correctly (async)', (done)->
  platform = _platform()
  pipe = _require '../'
  inputSource = fs.readFileSync path.resolve path.join __dirname,
    '../package.json'
  res = pipe inputSource
  proc = exec "#{res.command} #{typeCat} #{res.file}", (err, stdout, stderr)->
    (JSON.parse stdout).name.should.equal 'smart-pipe'
    res.clean()
    done()
  proc.stdin.write res.buffer
  proc.stdin.end()
