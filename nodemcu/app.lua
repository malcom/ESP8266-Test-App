--
-- NodeMCU implementation of 'ESP8266 Test App'
-- https://github.com/malcom/ESP8266-Test-App/
-- Copyright (c) 2016 by Marcin 'Malcom' Malich
-- Released under the MIT license
--

LedPin = 4
gpio.mode(LedPin, gpio.OUTPUT)
gpio.write(LedPin, gpio.HIGH)	-- led off

-- version info
a, b, c = node.info()
ver = a..'.'..b..'.'..c

function GetRequestInfo(request)
	-- GET /foo/bar(?key=val) HTTP/1.1
	local _, _, method, path, ver = string.find(request, '([A-Z]+) (.+) (HTTP/.+)')

	local pname = path
	local query = ''
	local pos = string.find(path, '?')
	if pos ~= nil then
		pname = string.sub(path, 1, pos - 1)
		query = string.sub(path, pos + 1)
	end

	local req = {}
	req.method = method
	req.path = path
	req.pathname = pname
	req.query = {}
	for k, v in string.gmatch(query, '(%w+)=(%w+)&*') do
		req.query[k] = v
	end
	req.version = ver

	return req
end

function OnConnection(c)

	c:on('receive', function(sck, request)

		local req = GetRequestInfo(request)

		print('Incomming request: '..req.path);

		if (req.method ~= 'GET' or req.pathname ~= '/') then
			print('Invalid method or path')
			sck:send('HTTP/1.1 404 Not Found\r\n')
			return
		end

		local action = req.query['action']

		if (action == nil) then
			-- index page, do nothing

		elseif (action == 'enable') then
			print('Enable Led')
			gpio.write(LedPin, gpio.LOW)
		
		elseif (action == 'disable') then
			print('Disable Led')
			gpio.write(LedPin, gpio.HIGH)
		else
			-- invalid action, do nothing
			print('Invalid action: '..action)
		end

		local status = gpio.read(LedPin)
		if (status == 0) then
			status = 'enabled'
		else
			status = 'disabled'
		end
		print('Led status: '..status)

		sck:send(
			'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n'..
			'<!DOCTYPE html>'..
			'<html><head><title>ESP8266 Test App</title></head><body>'..
			'<h2>Hello from ESP!</h2>'..
			'<p>LED status: '..status..'<br/>'..
			'<a href="?action=enable">enable</a> | <a href="?action=disable">disable</a></p>'..
			'<p>NodeMCU '..ver..'</p>'..
			'</body></html>'
		)

	end)

	c:on('sent', function(sck)
		sck:close()
	end)
end

function App()
	srv = net.createServer(net.TCP)
	srv:listen(80, OnConnection)
end

App()
