# node-smart-pipe [![Travis-CI.org Build Status](https://img.shields.io/travis/Qix-/node-smart-pipe.svg?style=flat-square)](https://travis-ci.org/Qix-/node-smart-pipe) [![Coveralls.io Coverage Rating](https://img.shields.io/coveralls/Qix-/node-smart-pipe.svg?style=flat-square)](https://coveralls.io/r/Qix-/node-smart-pipe)
Wrap STDIN buffers for programs that don't directly support stdin

## Example
The following work cross-platform.

#### Asynchronous
```javascript
var smartPipe = require('smart-pipe');
var exec = require('child_process').exec;

var buffer = new Buffer([1, 2, 3, 4]);
var piped = smartPipe(buffer);

var cmd = piped.command + 'xxd ' + piped.file;

var proc = exec(cmd, function(err, stdout, stderr) {
	console.log(stdout);
	piped.clean();
});

proc.stdin.write(piped.buffer);
proc.stdin.end();
```

#### Synchronous

```javascript
var smartPipe = require('smart-pipe');
var exec = require('child_process').execSync;

var buffer = new Buffer([1, 2, 3, 4]);
var piped = smartPipe(buffer);

var cmd = piped.command + 'xxd ' + piped.file;

var result = exec(cmd, {input: piped.buffer});
console.log(result.toString());
piped.clean();
```

### Explanation
You might be wondering, *this seems really overkill*.

- **Why do I even need this module?** Because different platforms handle
  piping differently. Some platforms (like Windows) don't handle it at all.
  This module identifies the correct way to pipe information to "stdin" through
  the use of file descriptors (file paths).
- **Does this change the syntax of my commands?** Slightly; you will need to use
  the filename version of the command. Whereas you would normally just pipe
  (i.e. `echo hello | cat`) you'll need to use the filename syntax
  (i.e. `cat some_file.txt`). This is because we pass the STDIN file descriptor
  as input.
- **Does this work on windows?** Sure does; On Windows, since there is only
  a quasi-STDIN at best, we write the buffer to a temporary file first and *that*
  becomes the filename.
- **Why does this require a native injection on Linux?**
  [This issue](https://github.com/joyent/node/issues/3530#issuecomment-6561239)
  explains a bit better, but essentially Node on Linux uses unix sockets to communicate
  with stdin of the child process instead of file descriptors. The native module
  handles this and performs small, cheap middleware operations upon opening the "file".
- **What's up with prefixing my commands?** As per the last question, this prefix
  will have the `LD_PRELOAD` information on Linux, and be completely blank on other
  platforms.
- **Why do I need to call `clean()`?** This is mainly on windows, but if a temporary
  file was written (on a platform that doesn't fully support STDIN), this will clean it.
  If you choose not to call `.clean()`, temporary files will be purged upon the exit
  of Node.

## License
Licensed under the [MIT License](http://opensource.org/licenses/MIT).
You can find a copy of it in [LICENSE](LICENSE).
