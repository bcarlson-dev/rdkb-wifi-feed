# RDKB Wi-Fi OpenWRT Feed

## New Packages

### rbus
   - OpenWRT port of RDK-Bus. 
   - More information in [rbus/README.md](rbus/README.md)

### easymesh
   - Contains Unified-Wifi-Mesh Agent and Controller
   - Contains OneWifi

### rdkb-ieee1905
   - Contains `ieee1905` daemon to manage 1905 traffic

## Backported packages

### avro-c

### libmariadb
   - Backports newer version that can be downloaded from mirror

### Rust (build environment)
   - Used to build the `rdkb-ieee1905` package
   - Not present in OpenWRT 21.0.2
   - Only changed to environment `gzip` and `TOOLCHAIN_ROOT_DIR` -> `TOOLCHAIN_DIR`


## Local Builds

### `easymesh`

- Custom `ONEWIFI_LOCAL_DIR`, `UWM_LOCAL_DIR`, `RDK_WIFI_HAL_LOCAL_DIR`, and `HALINTERFACE_LOCAL_DIR` make params have been added to build from a local copy of one or multiple of these repos.
- These can be provided is this method:
```bash
make package/easymesh/compile V=sc PKG_HASH=skip PKG_MIRROR_HASH=skip UWM_LOCAL_DIR=~/unified-wifi-mesh ONEWIFI_LOCAL_DIR=~/OneWifi
```

- These parameters must be given for each operation you want to perform on a local build otherwise it will default to the remote version. For example:
```bash
make package/easymesh/clean V=sc PKG_HASH=skip PKG_MIRROR_HASH=skip UWM_LOCAL_DIR=~/unified-wifi-mesh
```
will run all of the `make clean` targets in that `unified-wifi-mesh` directory and will cleanup the OpenWRT build environment for that package. 

- Running this on the other hand (without `UWM_LOCAL_DIR`)
```bash
make package/easymesh/clean V=sc PKG_HASH=skip PKG_MIRROR_HASH=skip
```
will just do the default cleanup operation.

- File changes in the local source directories provided are automatically detected so calling 
```bash
make package/easymesh/compile V=sc PKG_HASH=skip PKG_MIRROR_HASH=skip UWM_LOCAL_DIR=~/unified-wifi-mesh ONEWIFI_LOCAL_DIR=~/OneWifi
```
after changing a line in `~/OneWifi` will compile with that new code included. The `.o` files already exist in `~/OneWifi` so a full re-compilation does not occur unless you do a `clean` first.

### `rdkb-ieee1905`

- This should be able to be done by appending `USE_SOURCE_DIR=~/rdkb_ieee1905` to the `make package/rdkb-ieee1905/compile` command however that is un-tested at this time.

---

# RDKB Docker and OpenWRT Configuration Steps

## 1. OpenWRT Build Instruction

### 1.1. Building the Base Image

**Basic OpenWRT environments setup commands:**

Execute below commands to setup and build for the first time:

```bash
apt-get update
apt-get install git build-essential gcc binutils libncurses5-dev zlib1g-dev libssl-dev libncursesw5-dev gawk flex bison texinfo subversion gettext libxml2-dev libpcap-dev
apt-get install rsync wget file unzip python3 python3-distutils
apt-get install git openssh-server bridge-utils mariadb-server libmysqlcppconn-dev vim libdbus-1-dev dbus libev-dev libjansson-dev zlib1g-dev libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libavro-dev libssl-dev uuid-dev libreadline-dev iptables golang gcc gdb golang-go cscope exuberant-ctags make
apt-get install ca-certificates
git config --global http.sslVerify false
export FORCE_UNSAFE_CONFIGURE=1
```

**Start openWRT base build for the BPI Mediatek (MT7988) Board**

Follow the instruction in the link: [BPI Initial build](https://git01.mediatek.com/plugins/gitiles/openwrt/feeds/mtk-openwrt-feeds/+/refs/heads/master/autobuild/autobuild_5.4_mac80211_release/Readme.md), section Filogic 880/860 WiFi7 Kernel5.4 MP4.0 Release and choose the SKU to build as Filogic880/MT7996.

After the initial build, Ensure .config has the below entries to generate BPI based binary. If not please add these entries in .config.

```
CONFIG_TARGET_DEVICE_mediatek_mt7988_DEVICE_BPI-R4-SD=y
```

Then  refire the top level build command `make V=s PKG_HASH=skip PKG_MIRROR_HASH=skip`:

This completes the initial base build for BPI.

**NOTE: The base build and the EasyMesh/OneWifi build stages can not be combined! Finish building the base build (complete with the last "refire") then move to section 1.2**

### 1.2. Building EasyMesh and OneWifi on top of the base build

1. In the `openwrt` folder install this feed
```bash
echo "src-git rdkb_wifi https://github.com/bcarlson-dev/rdkb-wifi-feed.git" >> feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a -p rdkb_wifi
```

2. Copy the "golden" config file 
```bash
cp ./feeds/rdkb_wifi/easymesh/MT7966.config .config
```

3. Build:
```bash
make V=s PKG_HASH=skip PKG_MIRROR_HASH=skip
```

## 2. Flashing of Images and Running

After building the images, below are the steps to flash the image:

1. Flash the base build on SD card using balenaEtcher software - mtk-bpi-r4-MP4_1-SD-20241216.img  
   or General MediaTek Bin Link: https://drive.google.com/drive/folders/1YVb5-Yw2CGuUtm68cckPYMjlWQq7ebRA?usp=sharing

2. After that upgrade the image using the U-Boot Boot menu and TFTP.

3. Run Tftp server on your Macbook. The built .bin (for e.g. openwrt-mediatek-mt7988-BPI-R4-SD-squashfs-sysupgrade.bin) should be placed in `/private/tftpboot` on the Macbook

4. This flashes the updated image to the SD card.