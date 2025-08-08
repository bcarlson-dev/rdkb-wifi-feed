#
# Copyright (C) 2024 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rbus
PKG_VERSION:=2.7.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rdkcentral/rbus.git

PKG_SOURCE_VERSION:=develop
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=RDK Bus communication framework with CLI
  URL:=https://github.com/rdkcentral/rbus
  DEPENDS:=+libpthread +librt +libcurl +cJSON +msgpack-c
  MENU:=1
endef

define Package/$(PKG_NAME)/config
	source "$(SOURCE)/Config.in"
endef

define Package/$(PKG_NAME)/description
  RBus is a messaging infrastructure that enables inter-process 
  communication between various processes running on the device.
  It provides a robust framework for component registration,
  discovery, and method invocation across different processes.
  This package includes the core libraries and rbuscli utility.
endef

# Configuration options from menuconfig
ifeq ($(CONFIG_RBUS_INCLUDE_SAMPLES),y)
  CMAKE_BUILD_SAMPLES:=ON
else
  CMAKE_BUILD_SAMPLES:=OFF
endif

ifeq ($(CONFIG_RBUS_ENABLE_DEBUG),y)
  CMAKE_BUILD_TYPE:=Debug
else
  CMAKE_BUILD_TYPE:=Release
endif

# CMake configuration options based on actual CMakeLists.txt
CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
	-DBUILD_FOR_DESKTOP=ON \
	-DBUILD_ONLY_RTMESSAGE=OFF \
	-DBUILD_RBUS_DAEMON=ON \
	-DBUILD_RBUS_SAMPLE_APPS=$(CMAKE_BUILD_SAMPLES) \
	-DBUILD_RBUS_TEST_APPS=$(CMAKE_BUILD_TEST_APPS) \
	-DBUILD_RTMESSAGE_SAMPLE_APP=OFF \
	-DBUILD_RTMESSAGE_DATAPROVIDER_LIB=OFF \
	-DBUILD_RBUSCORE_BENCHMARK_TEST=OFF \
	-DBUILD_RBUSCORE_TEST_APPS=OFF \
	-DBUILD_SESSIONMGR_SAMPLE_APPS=OFF \
	-DENABLE_UNIT_TESTING=OFF \
	-DENABLE_CODE_COVERAGE=OFF \
	-DENABLE_RDKLOGGER=OFF \
	-DRDKC_BUILD=OFF \
	-DWITH_SPAKE2=OFF \
	-DMSG_ROUNDTRIP_TIME=ON

TARGET_CPPFLAGS += -DFIX_MSGHDR_MUSL


TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/msgpack
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib -lpthread -lrt

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d

	# Install all libraries
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/

	# Install all binaries and shell scripts
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	
	# Copy over service files
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d/;
	
endef

$(eval $(call BuildPackage,rbus))