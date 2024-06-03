#!/bin/sh

function update_site(){
    filename=$1
    url=$2

    echo `date "+%Y/%m/%d %H:%M:%S"`' [info] update site file: '${filename}
    curl -s ${url} > /tmp/nestingdns/${filename}

    if [ -f /tmp/nestingdns/${filename} ]; then
        mini=2
        line=$(awk 'END{print NR}' /tmp/nestingdns/${filename})  # 获取文件行数，下载不到不更新

        if [ ${line} -ge ${mini} ]; then
            if ! grep -q "<html>" /tmp/nestingdns/${filename}; then
                if [ -f /nestingdns/etc/site/${filename} ]; then
                    rm -rf /nestingdns/etc/site/${filename}
                fi
                mv /tmp/nestingdns/${filename} /nestingdns/etc/site/
            fi
        fi
    fi
}


# 清空日志文件
rm -rf /nestingdns/log/*.gz
rm -rf /nestingdns/log/querylog.json.1
# 准备下载路径
if [ -d /tmp/nestingdns ]; then
    rm -rf /tmp/nestingdns
fi
mkdir -p /tmp/nestingdns


# site 文件下载
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] update site file'
update_site direct-list.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt
update_site apple-cn.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt
update_site google-cn.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/google-cn.txt

update_site proxy-list.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt
update_site gfw.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt
update_site greatfire.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt

update_site private.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/private.txt

update_site CN-ip-cidr.txt https://mirror.ghproxy.com/https://raw.githubusercontent.com/Hackl0us/GeoIP2-CN/release/CN-ip-cidr.txt

update_site cloudflare.txt https://www.cloudflare-cn.com/ips-v4/#

# 修正 private.txt 中 msftconnecttest.com、msftncsi.com 域名拦截，导致 windows 系统网络图标，显示网络不可用
sed -i "/domain:msftncsi.com/d" /nestingdns/etc/site/private.txt
sed -i "/domain:msftconnecttest.com/d" /nestingdns/etc/site/private.txt
# 修正 private.txt 中 captive.apple.com 域名拦截，导致 ios 设备显示网络不可用
sed -i "/domain:captive.apple.com/d" /nestingdns/etc/site/private.txt

# 重启 mosdns
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] restart mosdns: '`/nestingdns/bin/mosdns version`
pkill -f /nestingdns/bin/mosdns
rm -rf /nestingdns/log/mosdns.log
nohup /nestingdns/bin/mosdns start -c /nestingdns/etc/conf/mosdns.yaml -d /nestingdns/work/mosdns > /dev/null 2>&1 &