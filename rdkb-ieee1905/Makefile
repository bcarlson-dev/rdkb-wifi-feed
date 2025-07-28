include $(TOPDIR)/rules.mk

PKG_NAME:=rdkb-ieee1905
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@github.com:rdkcentral/rdkb-ieee1905.git
PKG_SOURCE_VERSION:=main
PKG_SOURCE_DATE:=2024-01-01
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust-lang/host

include $(INCLUDE_DIR)/package.mk
include ../rust-lang/rust-package.mk

define Package/rdkb-ieee1905
  SECTION:=net
  CATEGORY:=Network
  TITLE:=IEEE 1905 implementation in Rust
  DEPENDS:=@(aarch64||arm) +libc +libpthread +librt +libstdcpp
  URL:=https://github.com/rdkcentral/rdkb-ieee1905.git
endef

define Package/rdkb-ieee1905/description
  Rust implementation of IEEE 1905 protocol for multi-AP networks
endef

# Override problematic RUSTFLAGS
RUSTC_LDFLAGS := -lssp_nonshared

# Override Build/Compile to fix the linker issue
define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	$(CARGO_PKG_CONFIG_VARS) \
	RUSTFLAGS="-Ctarget-feature=-crt-static $(RUSTC_LDFLAGS)" \
	cargo install -v \
		--profile release \
		$(if $(strip $(RUST_PKG_FEATURES)),--features "$(strip $(RUST_PKG_FEATURES))") \
		--root $(PKG_INSTALL_DIR) \
		--path "$(PKG_BUILD_DIR)" \
		$(if $(filter --jobserver%,$(PKG_JOBS)),,-j1)
endef

define Package/rdkb-ieee1905/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/ieee1905 $(1)/usr/bin/
endef

$(eval $(call RustBinPackage,rdkb-ieee1905))
$(eval $(call BuildPackage,rdkb-ieee1905))