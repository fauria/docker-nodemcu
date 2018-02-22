fauria/nodemcu
==================

![docker_logo](https://raw.githubusercontent.com/fauria/docker-nodemcu/master/docker_139x115.png)![docker_fauria_logo](https://raw.githubusercontent.com/fauria/docker-nodemcu/master/docker_fauria_161x115.png)

This Docker image is intended to build and customize [NodeMcu](http://www.nodemcu.com/index_en.html) [firmware](https://github.com/nodemcu/nodemcu-firmware). NodeMcu is a [Lua](https://www.lua.org/) open-source firmware based on [ESP8266](https://www.espressif.com/en/products/hardware/esp8266ex/overview) wifi-soc.

Installation from [Docker registry hub](https://registry.hub.docker.com/u/fauria/nodemcu/).
----

Pull the image using the following command:

```bash
docker pull fauria/nodemcu
```

Exposed volumes
----

This image exposes a `/firmware` directory, where the compiled firmware is built. It is important to link it to a volume on the host, to keep the firmware binaries once the container exits.

How to use it
----

#### Compile the firmware using the default settings

This command will compile the default firmware on a directory named ```nodemcu-firmware/``` in the current path:

```
docker run --rm -v ${PWD}/nodemcu-firmware:/firmware fauria/nodemcu
```

After exiting, there should be two files inside that directory named ```nodemcu/0x00000.bin``` and ```nodemcu/0x10000.bin``` ready to be flashed on an ESP8266 device.

#### Compile the firmware using a custom selection of modules.

NodeMcu modules are selected using directives on the [```app/include/user_modules.h```](https://github.com/nodemcu/nodemcu-firmware/blob/master/app/include/user_modules.h) file. The default behaviour of this image is to leave that file as it is.

If you want a customize module slection, you can run the container using environment variables in the form of ```ENABLE_ + module name```, such as ```ENABLE_WIFI``` or ```ENABLE_MQTT```.

Notice that **enabling a single module will disable every other module on the firmware**, unless explicitly enabled using ```ENABLE_ + module name```.

As a reference, release [2.1.0](https://github.com/nodemcu/nodemcu-firmware/releases/tag/2.1.0-master_20170824), supports the following modules:

- **ADC**
- ADS1115
- ADXL345
- AM2320
- APA102
- **BIT**
- BME280
- BMP085
- COAP
- CRON
- CRYPTO
- **DHT**
- DS18B20
- ENCODER
- ENDUSER_SETUP
- **FILE**
- GDBSTUB
- **GPIO**
- HDC1080
- HMC5883L
- HTTP
- HX711
- **I2C**
- L3G4200D
- MCP4725
- MDNS
- **MQTT**
- **NET**
- **NODE**
- **OW**
- PCM
- PERF
- PWM
- RC
- RFSWITCH
- ROTARY
- RTCFIFO
- RTCMEM
- RTCTIME
- SI7021
- SIGMA_DELTA
- SJSON
- SNTP
- SOMFY
- **SPI**
- STRUCT
- SWITEC
- TCS34725
- **TLS**
- TM1829
- **TMR**
- TSL2561
- U8G
- **UART**
- UCG
- WEBSOCKET
- **WIFI**
- WPS
- WS2801
- WS2812
- XPT2046

Note: bold modules are enabled by default.

Remember, any of these modules can be enabled using ```ENABLE_``` folowed by the module name.

For example, this command will have the same effect as running the container with no env vars, that is, a NodeMcu firmware with the default settings (same as the first example):

```docker run --rm -v ${PWD}/nodemcu-firmware:/firmware -e ENABLE_ADC=1 -e ENABLE_BIT=1 -e ENABLE_DHT=1 -e ENABLE_FILE=1 -e ENABLE_GPIO=1 -e ENABLE_I2C=1 -e ENABLE_MQTT=1 -e ENABLE_NET=1 -e ENABLE_NODE=1 -e ENABLE_OW=1 -e ENABLE_SPI=1 -e ENABLE_TLS=1 -e ENABLE_TMR=1 -e ENABLE_UART=1 -e ENABLE_WIFI=1 fauria/nodemcu```

You can use a file for those env vars and run Docker using the ```--env-file``` command line argument of [docker run](https://docs.docker.com/engine/reference/commandline/run/).
 

#### Flashing the firmware

Once you have the firmware files ```0x00000.bin``` and ```0x10000``` on your local directory, and a connected ESP8266 device, you can write the firmware using the command line tool [esptool](https://github.com/espressif/esptool).

The command used would be like:
```esptool.py --port /path/to/serial_port write_flash 0x00000 /host/volume/0x00000.bin 0x10000 /host/volume/0x10000.bin```

For example, on macOS:
```esptool.py --port /dev/cu.SLAB_USBtoUART write_flash 0x00000 nodemcu-firmware/0x00000.bin 0x10000 nodemcu-firmware/0x10000.bin```

Notice that this will vary, depending on the OS and the serial driver used.