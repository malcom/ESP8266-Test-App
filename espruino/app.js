//
// Espruino implementation of 'ESP8266 Test App'
// https://github.com/malcom/ESP8266-Test-App/
// Copyright (c) 2016 by Marcin 'Malcom' Malich
// Released under the MIT license
//

var ssid  = 'MalTest';
var passw = 'dupa123';

var led = new Pin(D2);
led.mode('output');

function onPageRequest(req, res) {

	var info = url.parse(req.url, true);
	// query is null if not provided any params
	info.query = info.query || {};

	print('Incomming request: ' + info.path);

	if (info.method != 'GET' || info.pathname != '/') {
		print('Invalid method or path');
		res.writeHead(404, { 'Content-Type': 'text/plain' });
		res.end();
		return;
	}

	var action = info.query.action;

	if (action == undefined) {
		// index page, do nothing

	} else if (action == 'enable') {
		print('Enable Led');
		led.write(LOW);

	} else if (action == 'disable') {
		print('Disable Led');
		led.write(HIGH);

	} else {
		// invalid action, do nothing
		print('Invalid action: ' + action);
	}

	var status = !led.read() ? 'enabled' : 'disabled';
	print('Led status: ' + status);

	res.writeHead(200, { 'Content-Type': 'text/html' });
	res.write('<!DOCTYPE html>');
	res.write('<html><head><title>ESP8266 Test App</title></head><body>');
	res.write('<h2>Hello from ESP!</h2>');
	res.write('<p>LED status: ' + status + '<br/>');
	res.write('<a href="?action=enable">enable</a> | <a href="?action=disable">disable</a></p>');
	res.write('<p>Espruino ' + process.version + '</p>');
	res.end('</body></html>');
}

function app() {

	led.write(HIGH);	// led off

	var srv = require('http').createServer(onPageRequest);
	srv.listen(80);

}

function onInit() {

	print('Connecting to WiFi...');
	var wifi = require('Wifi');
	wifi.connect(ssid, { password: passw }, function (err) {

		if (err) {
			print('Connection error: ', err);
			return;
		}

		var info = wifi.getIP();
		print('WiFi connection established');
		print('MAC address: ', info.mac);
		print(' IP address: ', info.ip);

		print('Running app...');
		app();

	});
}

onInit();
