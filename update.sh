#!/bin/sh

# 清空日志文件
rm -rf /nestingdns/log/update.log
rm -rf /nestingdns/log/*.gz

# 准备下载路径
if [ -d /tmp/nestingdns ]; then
    rm -rf /tmp/nestingdns
fi
mkdir -p /tmp/nestingdns

# site 文件下载
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file'
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file: apple-cn.txt'
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt > /tmp/nestingdns/apple-cn.txt
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file: CN-ip-cidr.txt'
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Hackl0us/GeoIP2-CN/release/CN-ip-cidr.txt > /tmp/nestingdns/CN-ip-cidr.txt
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file: direct-list.txt'
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt > /tmp/nestingdns/direct-list.txt
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file: gfw.txt'
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt > /tmp/nestingdns/gfw.txt
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file: google-cn.txt'
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/google-cn.txt > /tmp/nestingdns/google-cn.txt
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] update site file: proxy-list.txt'
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt > /tmp/nestingdns/proxy-list.txt

# site 文件替换
if [ -f /tmp/nestingdns/apple-cn.txt ]; then
    if [ -f /nestingdns/etc/site/apple-cn.txt ]; then
        rm -rf /nestingdns/etc/site/apple-cn.txt
    fi
    mv /tmp/nestingdns/apple-cn.txt /nestingdns/etc/site/
fi
if [ -f /tmp/nestingdns/CN-ip-cidr.txt ]; then
    if [ -f /nestingdns/etc/site/CN-ip-cidr.txt ]; then
        rm -rf /nestingdns/etc/site/CN-ip-cidr.txt
    fi
    mv /tmp/nestingdns/CN-ip-cidr.txt /nestingdns/etc/site/
fi
if [ -f /tmp/nestingdns/direct-list.txt ]; then
    if [ -f /nestingdns/etc/site/direct-list.txt ]; then
        rm -rf /nestingdns/etc/site/direct-list.txt
    fi
    mv /tmp/nestingdns/direct-list.txt /nestingdns/etc/site/
fi
if [ -f /tmp/nestingdns/gfw.txt ]; then
    if [ -f /nestingdns/etc/site/gfw.txt ]; then
        rm -rf /nestingdns/etc/site/gfw.txt
    fi
    mv /tmp/nestingdns/gfw.txt /nestingdns/etc/site/
fi
if [ -f /tmp/nestingdns/google-cn.txt ]; then
    if [ -f /nestingdns/etc/site/google-cn.txt ]; then
        rm -rf /nestingdns/etc/site/google-cn.txt
    fi
    mv /tmp/nestingdns/google-cn.txt /nestingdns/etc/site/
fi
if [ -f /tmp/nestingdns/proxy-list.txt ]; then
    if [ -f /nestingdns/etc/site/proxy-list.txt ]; then
        rm -rf /nestingdns/etc/site/proxy-list.txt
    fi
    mv /tmp/nestingdns/proxy-list.txt /nestingdns/etc/site/
fi

# 重启 mosdns
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] restart mosdns'
pkill -f /nestingdns/bin/mosdns
rm -rf /nestingdns/log/mosdns.log
nohup /nestingdns/bin/mosdns start -c /nestingdns/etc/conf/mosdns.yaml -d /nestingdns/work/mosdns > /dev/null 2>&1 &