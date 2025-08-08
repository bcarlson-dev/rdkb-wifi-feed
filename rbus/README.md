# rbus for OpenWRT

OpenWRT port of the RDK Bus ([rbus](https://github.com/rdkcentral/rbus)) communication framework.

## What is rbus?

RBus is a messaging infrastructure for inter-process communication. It provides component registration, discovery, and method invocation across processes.

## Configuration Options

Configure via `make menuconfig` under Libraries -> rbus:

| Option | Default | Description |
|--------|---------|-------------|
| `RBUS_INCLUDE_SAMPLES` | OFF | Build sample applications |
| `RBUS_INCLUDE_TEST_APPS` | OFF | Build test applications |
| `RBUS_ENABLE_DEBUG` | OFF | Enable debug build (Debug vs Release) |
| `RBUS_RTROUTED_AUTO_START` | ON | Auto-start rtrouted daemon at boot |

## Building

```bash
# Update feeds
echo "src-git rdkb_wifi https://github.com/bcarlson-dev/rdkb-wifi-feed.git" >> feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a -p rdkb_wifi

# Configure
make menuconfig
# Select Libraries -> rbus

# Build
make package/rbus/compile V=s
```

## Components

- **Libraries**: librbus, librtmessage, librbuscore
- **Daemon**: rtrouted (message routing daemon)
- **CLI**: rbuscli (command-line utility)

## Dependencies

- libpthread
- librt
- libcurl
- cJSON
- msgpack-c

## Testing Results (OpenWRT 21.0.2)

```bash
###################################################
#                                                 #
#                  TEST RESULTS                   #
#                                                 #
# Test Name      |Pass Count     |Fail Count      #
# ---------------|---------------|--------------- #
# ElementTree    |116            |0               #
# ValueAPI       |3345           |0               #
# PropertyAPI    |161            |0               #
# ObjectAPI      |30             |0               #
# Value          |48             |0               #
# ValueChange    |66             |0               #
# Subscribe      |53             |0               #
# SubscribeEx    |4              |0               #
# Tables         |1228           |0               #
# Events         |69             |0               #
# Methods        |55             |0               #
# Filter         |54             |0               #
# PartialPath    |252            |0               #
#                                                 #
###################################################
```