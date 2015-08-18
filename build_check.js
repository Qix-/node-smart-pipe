var os = require('os');
var exec = require('child_process').exec;
var path = require('path');
if (os.platform() === 'linux') {
	var proc = exec(path.resolve(path.join(__dirname, 'build_linux.sh')), function (err) {
		if (err) {
			throw err;
		}
		console.log('built linux preload library');
	});

	proc.stdout.pipe(process.stdout);
	proc.stderr.pipe(process.stderr);
} else {
	console.log('no preload library required');
}
