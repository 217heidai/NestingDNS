#!/bin/sh

function update_site(){
    filename=$1
    url=$2

    echo `date "+%Y/%m/%d %H:%M:%S"`' [info] update site file: '${filename}
    curl -sSL ${url} -o /tmp/nestingdns/${filename}

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
#rm -rf /nestingdns/log/*.gz
#rm -rf /nestingdns/log/querylog.json.1
# 准备下载路径
if [ -d /tmp/nestingdns ]; then
    rm -rf /tmp/nestingdns
fi
mkdir -p /tmp/nestingdns


# site 文件下载
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] update site file'
update_site direct.txt https://ghfast.top/https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/direct.txt
update_site proxy.txt https://ghfast.top/https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/proxy.txt
update_site private.txt https://ghfast.top/https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/private.txt
update_site ipv4_china.txt https://ghfast.top/https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/ipv4_china.txt
update_site ipv4_cloudflare.txt https://ghfast.top/https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/ipv4_cloudflare.txt

# 重启 mosdns
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] restart mosdns: '`/nestingdns/bin/mosdns version`
pkill -f /nestingdns/bin/mosdns
rm -rf /nestingdns/log/mosdns.log
nohup /nestingdns/bin/mosdns start -c /nestingdns/etc/conf/mosdns.yaml -d /nestingdns/work/mosdns > /dev/null 2>&1 &