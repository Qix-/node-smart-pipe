# node-smart-pipe [![Travis-CI.org Build Status](https://img.shields.io/travis/Qix-/node-smart-pipe.svg?style=flat-square)](https://travis-ci.org/Qix-/node-smart-pipe) [![Coveralls.io Coverage Rating](https://img.shields.io/coveralls/Qix-/node-smart-pipe.svg?style=flat-square)](https://coveralls.io/r/Qix-/node-smart-pipe)
Wrap STDIN buffers for programs that don't directly support stdin

## Example
The following works cross-platform.

```javascript
var smartPipe = require('smart-pipe');
var smartPipe = require('./');
var exec = require('child_process').execSync;

var buffer = new Buffer([1, 2, 3, 4]);
var piped = smartPipe(buffer);

var cmd = 'xxd ' + piped.file;

var result = exec(cmd, {input: piped.buffer});
console.log(result.toString());
```

## License
Licensed under the [MIT License](http://opensource.org/licenses/MIT).
You can find a copy of it in [LICENSE](LICENSE).
