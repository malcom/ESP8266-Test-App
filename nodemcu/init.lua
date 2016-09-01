--
-- NodeMCU implementation of 'ESP8266 Test App'
-- https://github.com/malcom/ESP8266-Test-App/
-- Copyright (c) 2016 by Marcin 'Malcom' Malich
-- Released under the MIT license
--

local ssid  = 'MalTest'
local passw = 'dupa123'

print('Connecting to WiFi...')
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid, passw)

tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
	if wifi.sta.getip() == nil then
		print('Waiting for IP address...')
	else
		tmr.stop(0)
		print('WiFi connection established')
		print('MAC address: ' .. wifi.sta.getmac())
		print(' IP address: ' .. wifi.sta.getip())

		if not file.exists('app.lua') then
			print('file app.lua does not exist')
			return
		end

		print('Starting app.lua in 3 seconds')
		print('To abort call abort() function')
		print('Waiting...')

		abort = function()
			tmr.stop(1)
			abort = nil
			print('Running app.lua aborted...')
		end

		tmr.alarm(1, 3000, tmr.ALARM_SINGLE, function()
			abort = nil
			print('Running app.lua')
			dofile('app.lua')
		end)

	end
end)
