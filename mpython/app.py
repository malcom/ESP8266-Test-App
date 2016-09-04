#
# MicroPython implementation of 'ESP8266 Test App'
# https://github.com/malcom/ESP8266-Test-App/
# Copyright (c) 2016 by Marcin 'Malcom' Malich
# Released under the MIT license
#

import network
import machine
import sys
import ure as re
import usocket as socket
import ubinascii

ssid  = 'MalTest';
passw = 'dupa123';

led = machine.Pin(2, machine.Pin.OUT)
led.value(1)	# off led

PAGE = b"""\
HTTP/1.1 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html><head><title>ESP8266 Test App</title></head><body>
<h2>Hello from ESP!</h2>
<p>LED status: %s<br/>
<a href="?action=enable">enable</a> | <a href="?action=disable">disable</a></p>
<p>MicroPython """ + '.'.join([str(i) for i in sys.implementation.version]) + """</p>
</body></html>
"""

def connect():
	wlan = network.WLAN(network.STA_IF)
	wlan.active(True)
	if not wlan.isconnected():
		print('Connecting to WiFi...')
		wlan.connect(ssid, passw)
		while not wlan.isconnected():
			pass
	print('WiFi connection established')
	print('MAC address: ', ubinascii.hexlify(wlan.config('mac'), ':').decode())
	print(' IP address: ', wlan.ifconfig()[0])


def getRequestInfo(str):
	# GET /foo/bar(?key=val) HTTP/1.1
	var = re.match('([A-Z]+) (.+) (HTTP/.+)', str)
	s = var.group(2)
	pname = s
	query = ''
	pos = s.find('?')
	if pos != -1:
		pname = s[0 : pos]
		query = s[pos + 1 : ]
	req = {
		'method': var.group(1),
		'path': var.group(2),
		'pathname': pname,
		'query': {},
		'version': var.group(3)
	}
	for s in query.split('&'):
		if len(s) == 0:
			break
		v = s.split('=')
		req['query'][v[0]] = v[1] if len(v) > 1 else ''
	
	return req


def main():
	
	connect()
	
	print('Starting server...')
	srv = socket.socket()
	srv.bind(socket.getaddrinfo('0.0.0.0', 80)[0][-1])
	srv.listen(5)
	
	while True:
		sck = srv.accept()[0]
		req = getRequestInfo(sck.readline())

		# skip the rest part of the header data
		while True:
			line = sck.readline()
			if line == b'' or line == b'\r\n':
				break
		
		print('Incomming request: ' + req['path']);
		
		if req['method'] != 'GET' or req['pathname'] != '/':
			print('Invalid method or path');
			sck.write('HTTP/1.1 404 Not Found\r\n')
			sck.close()
			continue
		
		if not 'action' in req['query']:
			# index page, do nothing
			pass
		
		elif req['query']['action'] == 'enable':
			print('Enable Led')
			led.value(0)
		
		elif req['query']['action'] == 'disable':
			print('Disable Led')
			led.value(1)
		
		else:
			# invalid action, do nothing
			print('Invalid action: ' + req['query']['action'])
		
		status = 'enabled' if not led.value() else 'disabled'
		print('Led status: ' + status);
		
		sck.write(PAGE % status)
		sck.close()


main()
