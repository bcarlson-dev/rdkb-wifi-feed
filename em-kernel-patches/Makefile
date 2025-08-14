include $(TOPDIR)/rules.mk

PKG_NAME:=em-kernel-patches
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=rdkwifi
  CATEGORY:=RDK Wi-Fi
  TITLE:=Custom kernel patches for EasyMesh
  DEPENDS:=@!PACKAGE_kmod-mac80211
  BUILDONLY:=1
endef

define Package/$(PKG_NAME)/description
  Applies patches to enable beacon frame reception in station mode
  for mac80211 and mt76 drivers
endef

MAC80211_PKG_DIR:=$(TOPDIR)/package/kernel/mac80211
MAC80211_SRC_DIR:=$(MAC80211_PKG_DIR)/src
MTK_SRC_DIR:=$(MAC80211_SRC_DIR)/drivers/net/wireless/mediatek

# Path to your apply-patches script
APPLY_PATCHES_SCRIPT:=$(CURDIR)/apply-patches.sh

# This runs before mac80211 builds
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)

	@echo "=== em-kernel-patches Build/Prepare starting ==="
	@echo "Looking for MAC80211_SRC_DIR at: $(MAC80211_SRC_DIR)"
	@echo "Looking for MTK_SRC_DIR at: $(MTK_SRC_DIR)"
	@echo "Current directory: $(CURDIR)"
	@echo "Patch directory: $(CURDIR)/custom-patches"

	
	# Make the script executable
	if [ -f "$(APPLY_PATCHES_SCRIPT)" ]; then \
		chmod +x $(APPLY_PATCHES_SCRIPT); \
	fi
	
	# Apply mac80211 patches
	if [ -d "$(MAC80211_SRC_DIR)" ]; then \
		echo "Found mac80211 source directory"; \
		if [ -f "$(APPLY_PATCHES_SCRIPT)" ]; then \
			$(APPLY_PATCHES_SCRIPT) "$(MAC80211_SRC_DIR)" "$(CURDIR)/custom-patches/mac80211" 2>&1; \
		else \
			echo "Error: apply-patches.sh script not found"; \
		fi \
	else \
		echo "Warning: mac80211 source not found at $(MAC80211_SRC_DIR)"; \
	fi
	
	# Apply mt76 patches
	if [ -d "$(MTK_SRC_DIR)" ]; then \
		echo "Found mediatek source directory"; \
		if [ -f "$(APPLY_PATCHES_SCRIPT)" ]; then \
			$(APPLY_PATCHES_SCRIPT) "$(MTK_SRC_DIR)" "$(CURDIR)/custom-patches/mt76" 2>&1; \
		else \
			echo "Error: apply-patches.sh script not found"; \
		fi \
	else \
		echo "Warning: mediatek source not found at $(MTK_SRC_DIR)"; \
	fi
endef

define Build/Configure
endef

define Build/Compile
endef

define Build/Install
endef

$(eval $(call BuildPackage,$(PKG_NAME)))