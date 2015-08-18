'use strict';

var os = require('os');
var tmp = require('tmp');
var fs = require('fs');
var path = require('path');

var platform = os.platform();
tmp.setGracefulCleanup();

module.exports = function smartPipe(buffer, command, opts) {
	buffer = buffer || new Buffer(0);
	command = command || '';
	opts = opts || {};
	var result = {};
	switch (platform) {
		case 'win32':
			var tmpFile = tmp.fileSync({postfix: opts.postfix || '.tmp'});

			result.buffer = new Buffer(0);
			result.file = tmpFile.name;
			result.command = command;
			result.clean = function () {
				tmpFile.removeCallback();
			};

			fs.writeSync(tmpFile.fd, buffer);
			fs.closeSync(tmpFile.fd);
			break;
		case 'linux':
			result.buffer = buffer;
			result.clean = function () {};
			if (opts.dash) {
				result.command = command;
				result.file = '-';
			} else {
				result.command = 'LD_PRELOAD=' + path.join(__dirname, 'fddup.so') +
					' ' + command;
				result.file = '/dev/fd/0,nofork';
			}
			break;
		default:
			result.buffer = buffer;
			result.clean = function () {};
			result.command = command;
			result.file = opts.dash
				? '-'
				: '/dev/stdin';
			break;
	}

	return result;
};
