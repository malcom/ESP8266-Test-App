# ESP8266 Test App

This is a very simple test app for ESP9266 modules, that allows you to control
the LED diode by web browser.

Project was created during reviewing and testing
avaiable firmwares for ESP8266 chipset. More information in the author's blog
post: [ESP8266: Spojrzenie na firmware](http://blog.malcom.pl/2016/esp8266-spojrzenie-na-firmware.html) [PL only].


## Hardware

The controlled LED is connected to GPIO2 pin of ESP module. The author used
ESP-01 module for testing purpose, but this pin is avaiable on every version
of the module. Therefore the GPIO2 is involved in a boot process, so the active
state should be low (0) for the output mode.

![schematic](/schematic.png)

Maximum current for pin in ESP8266 is only 12mA ([datasheet](http://espressif.com/sites/default/files/documentation/0a-esp8266ex_datasheet_en.pdf): 5.1. Electrical Characteristics),
so you need a current limiting resistor diodes for a safe output value.

<img src="/breadboard.jpg" width="400">


## Software

The project contains the source code for the most popular ESP8266 firmwares.
For each of them, the source code is located in individual dir with the
screenshot showing the operation of the system (browser/terminal).

Currently the code is available on the platforms:
* [NodeMCU](http://nodemcu.com/index_en.html) (Lua)
* [Espruino](http://www.espruino.com/) (JavaScript)
* [MicroPython](http://micropython.org/) (Python)

Presented code doesn't have to be of very high quality, author mainly focused on
reviewing and testing given platform rather than creating high quality code.
However, if you think that some elements could be simpler, feel free to do it.


## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
