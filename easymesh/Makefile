include $(TOPDIR)/rules.mk

PKG_NAME:=easymesh
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=0
PKG_HASH:=skip

ifneq ($(strip $(ONEWIFI_LOCAL_DIR)$(UWM_LOCAL_DIR)$(RDK_WIFI_HAL_LOCAL_DIR)$(HALINTERFACE_LOCAL_DIR)),)
  # Check if any local directory has files newer than .built
  WATCH_DIRS:=$(ONEWIFI_LOCAL_DIR) $(UWM_LOCAL_DIR) $(RDK_WIFI_HAL_LOCAL_DIR) $(HALINTERFACE_LOCAL_DIR)
  ifneq ($(wildcard $(PKG_BUILD_DIR)/.built),)
    NEWEST_FILE:=$(shell find $(WATCH_DIRS) -type f -newer $(PKG_BUILD_DIR)/.built 2>/dev/null | head -n1)
    ifneq ($(NEWEST_FILE),)
      $(shell rm -f $(PKG_BUILD_DIR)/.built*)
    endif
  endif
endif


include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=rdkwifi
  CATEGORY:=RDK Wi-Fi
  TITLE:=EasyMesh with OneWifi
  DEPENDS:=+avro-c +libopenssl +cJSON +libev +libnl +libnl-genl +libnl-route +libuuid +libstdcpp +libmariadb-fixed +libmariadb-fixed-plugin-auth-gssapi-client +libmariadb-fixed-plugin-remote-io +libreadline +rdkb-ieee1905
endef

define Package/$(PKG_NAME)/description
  EasyMesh implementation with OneWifi replacing hostapd functionality
endef

define Package/$(PKG_NAME)/config
  config CRYPTO_OFFLOAD_INLINE
    bool
    default y if PACKAGE_$(PKG_NAME)

  config CRYPTO_XFRM_OFFLOAD_MTK_PCE
    bool
    default y if PACKAGE_$(PKG_NAME)
endef

# Git repositories
ONEWIFI_REPO:=https://github.com/bcarlson-dev/OneWifi.git
UNIFIED_WIFI_MESH_REPO:=https://github.com/bcarlson-dev/unified-wifi-mesh.git
RDK_WIFI_HAL_REPO:=https://github.com/rdkcentral/rdk-wifi-hal.git
HALINTERFACE_REPO:=https://github.com/rdkcentral/rdkb-halif-wifi.git
UPSTREAM_HOSTAP_URL:=git://w1.fi/hostap.git
HOSTAP_PATCHES_REPO:=https://github.com/rdkcentral/hostap-patches.git
OW_BASE64_REPO:=https://github.com/xmidt-org/trower-base64.git

# Hostap version and commit
SRCREV_2_10:=9d07b9447e76059a2ddef2a879c57d0934634188

HOSTAP_PATCHES:= \
	hostap-patches/0001-OneWifi-related-hostap-patch-for-2.10-based-hostap.patch \
	hostap-patches/0002-radius_failover_2.10.patch \
	hostap-patches/0003-mbssid_support_2.10.patch \
	hostap-patches/wpa3_compatibility_hostap_2_10.patch \
	hostap-patches/0005-RDKB-58414-Dynamically-update-NAS_2_10.patch \
	hostap-patches/0006-RDKB-59523-connectivity-via-supplicant.patch \
	hostap-patches/mdu_radius_psk_auth_2_10.patch

TARGET_CFLAGS+= -ggdb3 -O0
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl3
TARGET_LDFLAGS+= -lgcc -lc

# Common build environment variables between OneWifi and unified-wifi-mesh
# WIFI_DEVICE_HAL=$(PKG_BUILD_DIR)/halinterface/include/wifi \
#	WIFI_CJSON=$(STAGING_DIR)/usr/include/cjson \
#	INSTALLDIR=$(PKG_BUILD_DIR)/OneWifi/install \
#	INSTALLDIR=$(PKG_BUILD_DIR)/unified-wifi-mesh/install \

define BuildEnvironment
	ONE_WIFI_HOME=$(PKG_BUILD_DIR)/OneWifi \
	ONEWIFI_HOME=$(PKG_BUILD_DIR)/OneWifi \
	BASE_DIR=$(PKG_BUILD_DIR) \
	BASE=$(PKG_BUILD_DIR) \
	ONE_WIFI_EM_HOME=$(PKG_BUILD_DIR)/unified-wifi-mesh \
	ONEWIFI_EM_HOME=$(PKG_BUILD_DIR)/unified-wifi-mesh \
	ONEWIFI_EM_SRC=$(PKG_BUILD_DIR)/unified-wifi-mesh/src \
	AL_SAP_HOME=$(PKG_BUILD_DIR)/unified-wifi-mesh/src/al-sap \
	WIFI_RDK_HAL=$(PKG_BUILD_DIR)/rdk-wifi-hal \
	WIFI_HOSTAP_BASE=$(PKG_BUILD_DIR)/rdk-wifi-libhostap/source/hostap-2.10 \
	WIFI_HOSTAP_SRC=$(PKG_BUILD_DIR)/rdk-wifi-libhostap/source/hostap-2.10/src \
	WIFI_HOSTAP_SUPPLICANT=$(PKG_BUILD_DIR)/rdk-wifi-libhostap/source/hostap-2.10/wpa_supplicant \
	WIFI_HAL_INTERFACE=$(PKG_BUILD_DIR)/halinterface/include \
	ONEWIFI_HAL_INTF_HOME=$(PKG_BUILD_DIR)/halinterface/include \
	ONEWIFI_BUS_LIB_HOME=$(PKG_BUILD_DIR)/OneWifi/lib/bus \
	WIFI_TROWER_BASE=$(PKG_BUILD_DIR)/trower-base64/include/ \
	WITH_SAP=1 \
	ENABLE_DEBUG_MODE=OFF
endef

define Build/Prepare
	# Create build directory structure
	mkdir -p $(PKG_BUILD_DIR)
	
	# Clone all repositories while allowing for local overrides
	# Handle OneWifi repository
ifdef ONEWIFI_LOCAL_DIR
	@echo "Using local OneWifi source from: $(ONEWIFI_LOCAL_DIR)"
	ln -sf $(ONEWIFI_LOCAL_DIR) $(PKG_BUILD_DIR)/OneWifi
else
	@echo "Cloning OneWifi from git repository"
	cd $(PKG_BUILD_DIR) && git clone --branch feature/owrt-feed-build $(ONEWIFI_REPO) OneWifi
endif
	
	# Handle unified-wifi-mesh repository
ifdef UWM_LOCAL_DIR
	@echo "Using local unified-wifi-mesh source from: $(UWM_LOCAL_DIR)"
	ln -sf $(UWM_LOCAL_DIR) $(PKG_BUILD_DIR)/unified-wifi-mesh
else
	@echo "Cloning unified-wifi-mesh from git repository"
	cd $(PKG_BUILD_DIR) && git clone --branch feature/owrt-feed-build $(UNIFIED_WIFI_MESH_REPO) unified-wifi-mesh
endif
	
	# Handle rdk-wifi-hal repository
ifdef RDK_WIFI_HAL_LOCAL_DIR
	@echo "Using local rdk-wifi-hal source from: $(RDK_WIFI_HAL_LOCAL_DIR)"
	ln -sf $(RDK_WIFI_HAL_LOCAL_DIR) $(PKG_BUILD_DIR)/rdk-wifi-hal
else
	@echo "Cloning rdk-wifi-hal from git repository"
	cd $(PKG_BUILD_DIR) && git clone $(RDK_WIFI_HAL_REPO) rdk-wifi-hal
endif
	
	# Handle halinterface repository
ifdef HALINTERFACE_LOCAL_DIR
	@echo "Using local halinterface source from: $(HALINTERFACE_LOCAL_DIR)"
	ln -sf $(HALINTERFACE_LOCAL_DIR) $(PKG_BUILD_DIR)/halinterface
else
	@echo "Cloning halinterface from git repository"
	cd $(PKG_BUILD_DIR) && git clone $(HALINTERFACE_REPO) halinterface
endif

	git clone $(OW_BASE64_REPO) $(PKG_BUILD_DIR)/trower-base64
	
	# Create install directories
	mkdir -p $(PKG_BUILD_DIR)/OneWifi/install/bin
	mkdir -p $(PKG_BUILD_DIR)/OneWifi/install/lib
	
	# Setup hostap
	mkdir -p $(PKG_BUILD_DIR)/rdk-wifi-libhostap/source
	cd $(PKG_BUILD_DIR)/rdk-wifi-libhostap/source && \
	git clone $(UPSTREAM_HOSTAP_URL) hostap-2.10 && \
	cd hostap-2.10 && \
	git reset --hard $(SRCREV_2_10) && \
	git clone $(HOSTAP_PATCHES_REPO) hostap-patches && \
	git am $(HOSTAP_PATCHES) && \
	rm -rf hostap-patches
endef

define Build/Compile

	if [ -n "$(UWM_LOCAL_DIR)" ] || [ -n "$(ONEWIFI_LOCAL_DIR)" ] || [ -n "$(RDK_WIFI_HAL_LOCAL_DIR)" ] || [ -n "$(HALINTERFACE_LOCAL_DIR)" ]; then \
		rm -f $(PKG_BUILD_DIR)/.built*; \
	fi

	# First, build OneWifi (provides libraries for unified-wifi-mesh)
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/OneWifi/build/openwrt/ \
		$(TARGET_CONFIGURE_OPTS) \
		INSTALLDIR="$(PKG_BUILD_DIR)/OneWifi/install" \
		$(BuildEnvironment)
	
	# Build unified-wifi-mesh components
	# Build libalsap first
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/unified-wifi-mesh/build/openwrt/libalsap/ \
		$(TARGET_CONFIGURE_OPTS) \
		INSTALLDIR="$(PKG_BUILD_DIR)/unified-wifi-mesh/install" \
		$(BuildEnvironment)
	
	# Build agent
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/unified-wifi-mesh/build/openwrt/agent/ \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		INSTALLDIR="$(PKG_BUILD_DIR)/unified-wifi-mesh/install" \
		$(BuildEnvironment)
	
	# Build controller
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/unified-wifi-mesh/build/openwrt/ctrl/ \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		INSTALLDIR="$(PKG_BUILD_DIR)/unified-wifi-mesh/install" \
		$(BuildEnvironment)


	# Clean CLI Objects (for library re-build)
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/unified-wifi-mesh/build/openwrt/cli/ clean \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		INSTALLDIR="$(PKG_BUILD_DIR)/unified-wifi-mesh/install" \
		$(BuildEnvironment)

	# Build CLI
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/unified-wifi-mesh/build/openwrt/cli/ \
		$(TARGET_CONFIGURE_OPTS) \
		STAGING_DIR="$(STAGING_DIR)" \
		INSTALLDIR="$(PKG_BUILD_DIR)/unified-wifi-mesh/install" \
		$(BuildEnvironment)
endef

define Build/Clean
	# Clean local directories if they're being used
	if [ -n "$(ONEWIFI_LOCAL_DIR)" ]; then \
		echo "Cleaning OneWifi in local directory: $(ONEWIFI_LOCAL_DIR)"; \
		if [ -d "$(ONEWIFI_LOCAL_DIR)/build/openwrt" ]; then \
			CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			$(MAKE) $(PKG_JOBS) -C $(ONEWIFI_LOCAL_DIR)/build/openwrt/ clean \
				$(TARGET_CONFIGURE_OPTS) \
				INSTALLDIR="$(ONEWIFI_LOCAL_DIR)/install" \
				ONE_WIFI_HOME=$(ONEWIFI_LOCAL_DIR) \
				ONEWIFI_HOME=$(ONEWIFI_LOCAL_DIR); \
		fi; \
	fi

	if [ -n "$(UWM_LOCAL_DIR)" ]; then \
		echo "Cleaning unified-wifi-mesh in local directory: $(UWM_LOCAL_DIR)"; \
		if [ -d "$(UWM_LOCAL_DIR)/build/openwrt/libalsap" ]; then \
			CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			$(MAKE) $(PKG_JOBS) -C $(UWM_LOCAL_DIR)/build/openwrt/libalsap/ clean \
				$(TARGET_CONFIGURE_OPTS) \
				INSTALLDIR="$(UWM_LOCAL_DIR)/install" \
				ONE_WIFI_EM_HOME=$(UWM_LOCAL_DIR) \
				ONEWIFI_EM_HOME=$(UWM_LOCAL_DIR); \
		fi; \
		if [ -d "$(UWM_LOCAL_DIR)/build/openwrt/agent" ]; then \
			CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			$(MAKE) $(PKG_JOBS) -C $(UWM_LOCAL_DIR)/build/openwrt/agent/ clean \
				$(TARGET_CONFIGURE_OPTS) \
				STAGING_DIR="$(STAGING_DIR)" \
				INSTALLDIR="$(UWM_LOCAL_DIR)/install" \
				ONE_WIFI_EM_HOME=$(UWM_LOCAL_DIR) \
				ONEWIFI_EM_HOME=$(UWM_LOCAL_DIR); \
		fi; \
		if [ -d "$(UWM_LOCAL_DIR)/build/openwrt/ctrl" ]; then \
			CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			$(MAKE) $(PKG_JOBS) -C $(UWM_LOCAL_DIR)/build/openwrt/ctrl/ clean \
				$(TARGET_CONFIGURE_OPTS) \
				STAGING_DIR="$(STAGING_DIR)" \
				INSTALLDIR="$(UWM_LOCAL_DIR)/install" \
				ONE_WIFI_EM_HOME=$(UWM_LOCAL_DIR) \
				ONEWIFI_EM_HOME=$(UWM_LOCAL_DIR); \
		fi; \
		if [ -d "$(UWM_LOCAL_DIR)/build/openwrt/cli" ]; then \
			CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			$(MAKE) $(PKG_JOBS) -C $(UWM_LOCAL_DIR)/build/openwrt/cli/ clean \
				$(TARGET_CONFIGURE_OPTS) \
				STAGING_DIR="$(STAGING_DIR)" \
				INSTALLDIR="$(UWM_LOCAL_DIR)/install" \
				ONE_WIFI_EM_HOME=$(UWM_LOCAL_DIR) \
				ONEWIFI_EM_HOME=$(UWM_LOCAL_DIR); \
		fi; \
	fi

	@echo "Clean completed for local directories"
endef

define Package/$(PKG_NAME)/install
	# Install binaries
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/OneWifi/install/bin/OneWifi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/bin/onewifi_em_agent $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/bin/onewifi_em_ctrl $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/bin/onewifi_em_cli $(1)/usr/bin/

	# Install libraries
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/lib/libemcli.so $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/lib/libalsap.a $(1)/usr/lib/
	
	# Install configuration files
	$(INSTALL_DIR) $(1)/banana-pi
	$(INSTALL_DIR) $(1)/nvram
	$(INSTALL_DIR) $(1)/etc/init.d
	
	# Copy OneWifi configs
	if [ -d "$(PKG_BUILD_DIR)/OneWifi/config/openwrt/banana-pi" ]; then \
		$(CP) $(PKG_BUILD_DIR)/OneWifi/config/openwrt/banana-pi/* $(1)/banana-pi/; \
		if [ -d "$(PKG_BUILD_DIR)/OneWifi/config/openwrt/banana-pi/etc/init.d" ]; then \
			$(INSTALL_BIN) $(PKG_BUILD_DIR)/OneWifi/config/openwrt/banana-pi/etc/init.d/* $(1)/etc/init.d/; \
		fi; \
	fi
	
	# Copy unified-wifi-mesh configs
	if [ -d "$(PKG_BUILD_DIR)/unified-wifi-mesh/config/openwrt/banana-pi" ]; then \
		$(CP) $(PKG_BUILD_DIR)/unified-wifi-mesh/config/openwrt/banana-pi/* $(1)/banana-pi/; \
		if [ -d "$(PKG_BUILD_DIR)/unified-wifi-mesh/config/openwrt/banana-pi/etc/init.d" ]; then \
			$(INSTALL_BIN) $(PKG_BUILD_DIR)/unified-wifi-mesh/config/openwrt/banana-pi/etc/init.d/* $(1)/etc/init.d/; \
		fi; \
	fi
	
	# Copy certificates
	if [ -f "$(PKG_BUILD_DIR)/unified-wifi-mesh/install/config/test_cert.crt" ]; then \
		$(CP) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/config/test_cert.crt $(1)/nvram/; \
	fi
	if [ -f "$(PKG_BUILD_DIR)/unified-wifi-mesh/install/config/test_cert.key" ]; then \
		$(CP) $(PKG_BUILD_DIR)/unified-wifi-mesh/install/config/test_cert.key $(1)/nvram/; \
	fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))