#!/bin/bash
# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
echo "编译固件大小为: $PROFILE MB"
echo "Include Docker: $INCLUDE_DOCKER"

echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入环境变量ENABLE_PPPOE等 写入配置文件 供99-custom.sh读取
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings
# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始编译..."



# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-app-airplay2"
#支持计划重启
PACKAGES="$PACKAGES luci-i18n-autoreboot-zh-cn"
PACKAGES="$PACKAGES luci-app-p910nd"
PACKAGES="$PACKAGES fail2ban"
PACKAGES="$PACKAGES znc-mod-fail2ban"
#KMS服务器
PACKAGES="$PACKAGES luci-app-vlmcsd"
#流量监控工具
PACKAGES="$PACKAGES luci-i18n-statistics-zh-cn"
#Client-Splash是无线MESH网络的一个热点认证系统
#PACKAGES="$PACKAGES luci-i18n-splash-zh-cn"
#BATMAN-adv协议软件包，用于在mesh网络中实现路由器之间的通信
#PACKAGES="$PACKAGES luci-app-bmx6"
#无线网络自组网（EasyMesh）的Web界面配置管理
#PACKAGES="$PACKAGES luci-app-easymesh"	
#分布式AP管理程序
#PACKAGES="$PACKAGES luci-i18n-dawn-zh-cn"
#ARP 绑定工具，可以将 IP 地址绑定到设备 MAC 地址上，防止 IP 地址被冒用
PACKAGES="$PACKAGES luci-i18n-splash-zh-cn"luci-app-arpbind
#一个抓包分析工具，用于网络监测和故障排除
PACKAGES="$PACKAGES luci-i18n-splash-zh-cn"luci-app-cshark	
#24.10
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
# 增加几个必备组件 方便用户安装iStore
PACKAGES="$PACKAGES fdisk"
PACKAGES="$PACKAGES script-utils"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
luci-app-store
#带宽控制，用于限制每个设备的带宽使用
luci-app-xlnetacc
#允许对网络访问进行控制，例如阻止某些设备访问互联网
luci-app-accesscontrol
#具有广告过滤、隐私保护、家长控制等功能的 DNS 服务器
luci-app-adguardhome
#防止IP欺诈攻击的插件，可以实现基于BCP 38规范的反欺诈功能
luci-app-bcp38


# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
