'use strict';

var os = require('os');
var tmp = require('tmp');
var fs = require('fs');

var platform = os.platform();
var isWindows = platform === 'win32';
tmp.setGracefulCleanup();

module.exports = function smartPipe(buffer, opts) {
	opts = opts || {};
	var result = {};
	if (isWindows) {
		var tmpFile = tmp.fileSync({postfix: opts.postfix || '.tmp'});

		result.buffer = new Buffer(0);
		result.file = tmpFile.name;
		result.clean = function () {
			tmpFile.removeCallback();
		};

		fs.writeSync(tmpFile.fd, buffer);
		fs.closeSync(tmpFile.fd);
	} else {
		result.buffer = buffer;
		result.file = opts.dash
			? '-'
			: '/dev/stdin';
		result.clean = function () {};
	}

	return result;
};
