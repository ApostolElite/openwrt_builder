#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# --- First boot: enable Wi‑Fi 2.4/5 GHz and set WPA2 key ---
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-wifi <<'EOF'
#!/bin/sh

PASS='12345678'
SSID_24='OpenWrt-24'
SSID_5='OpenWrt-5G'
COUNTRY='DE'

# enable radios if present
for radio in radio0 radio1; do
  uci -q get wireless.$radio >/dev/null || continue
  uci set wireless.$radio.disabled='0'
  uci -q set wireless.$radio.country="$COUNTRY"
done

# configure default ifaces (usually default_radio0=2.4G, default_radio1=5G)
if uci -q get wireless.default_radio0 >/dev/null; then
  uci set wireless.default_radio0.ssid="$SSID_24"
  uci set wireless.default_radio0.encryption='psk2'
  uci set wireless.default_radio0.key="$PASS"
  uci set wireless.default_radio0.disabled='0'
fi

if uci -q get wireless.default_radio1 >/dev/null; then
  uci set wireless.default_radio1.ssid="$SSID_5"
  uci set wireless.default_radio1.encryption='psk2'
  uci set wireless.default_radio1.key="$PASS"
  uci set wireless.default_radio1.disabled='0'
fi

uci commit wireless
wifi reload

exit 0
EOF

chmod 0755 files/etc/uci-defaults/99-wifi

