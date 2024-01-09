#!/bin/sh

echo  "========================================================"
echo  " _   _           _   _             _____  _   _  _____ "
echo  "| \ | |         | | (_)           |  __ \| \ | |/ ____|"
echo  "|  \| | ___  ___| |_ _ _ __   __ _| |  | |  \| | (___  "
echo  "| . \` |/ _ \/ __| __| | '_ \ / _\` | |  | | . \` |\___ \ "
echo  "| |\  |  __/\__ \ |_| | | | | (_| | |__| | |\  |____) |"
echo  "|_| \_|\___||___/\__|_|_| |_|\__, |_____/|_| \_|_____/ "
echo  "                              __/ |                    "
echo  "                             |___/                     "
echo  "========================================================"

# /nestingdns/etc/conf 初始化
if [ ! -d /nestingdns/etc/conf ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: conf dir'
    mkdir -p /nestingdns/etc/conf
fi
if [ ! -f /nestingdns/etc/conf/smartdns.conf ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: smartdns config file'
    cp /nestingdns/default/conf/smartdns.conf /nestingdns/etc/conf/
fi
if [ ! -f /nestingdns/etc/conf/mosdns.yaml ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: mosdns config file'
    cp /nestingdns/default/conf/mosdns.yaml /nestingdns/etc/conf/
fi
if [ ! -f /nestingdns/etc/conf/adguardhome.yaml ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: adguardhome config file'
    cp /nestingdns/default/conf/adguardhome.yaml /nestingdns/etc/conf/
fi
# /nestingdns/etc/site 初始化
if [ ! -d /nestingdns/etc/site ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: site dir'
    mkdir -p /nestingdns/etc/site
fi
if [ ! -f /nestingdns/etc/site/apple-cn.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: apple-cn site file'
    cp /nestingdns/default/site/apple-cn.txt /nestingdns/etc/site/
fi
if [ ! -f /nestingdns/etc/site/CN-ip-cidr.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: CN-ip-cidr site file'
    cp /nestingdns/default/site/CN-ip-cidr.txt /nestingdns/etc/site/
fi
if [ ! -f /nestingdns/etc/site/direct-list.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: direct-list site file'
    cp /nestingdns/default/site/direct-list.txt /nestingdns/etc/site/
fi
if [ ! -f /nestingdns/etc/site/gfw.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: gfw site file'
    cp /nestingdns/default/site/gfw.txt /nestingdns/etc/site/
fi
if [ ! -f /nestingdns/etc/site/google-cn.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: google-cn site file'
    cp /nestingdns/default/site/google-cn.txt /nestingdns/etc/site/
fi
if [ ! -f /nestingdns/etc/site/proxy-list.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: proxy-list site file'
    cp /nestingdns/default/site/proxy-list.txt /nestingdns/etc/site/
fi
if [ ! -f /nestingdns/etc/site/force-cn.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: force-cn site file'
    touch /nestingdns/etc/site/force-cn.txt
fi
if [ ! -f /nestingdns/etc/site/force-nocn.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: force-nocn site file'
    touch /nestingdns/etc/site/force-nocn.txt
fi
if [ ! -f /nestingdns/etc/site/hosts.txt ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: hosts site file'
    touch /nestingdns/etc/site/hosts.txt
fi
# /nestingdns/work 初始化
if [ ! -d /nestingdns/work/smartdns ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: smartdns work dir'
    mkdir -p /nestingdns/work/smartdns
fi
#if [ ! -f /nestingdns/work/smartdns/cache.dump ]; then
#    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: smartdns cache file'
#    cp /nestingdns/default/cache/cache.dump /nestingdns/work/smartdns/
#fi
if [ ! -d /nestingdns/work/mosdns ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: mosdns work dir'
    mkdir -p /nestingdns/work/mosdns
fi
if [ ! -f /nestingdns/work/mosdns/cache.dump ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: mosdns cache file'
    cp /nestingdns/default/cache/cache.dump /nestingdns/work/mosdns/
fi
if [ ! -d /nestingdns/work/adguardhome ]; then
    echo `date "+%Y/%m/%d %H.%M.%S"`' [info] init: adguardhome work dir'
    mkdir -p /nestingdns/work/adguardhome
fi

# 设置时区及定时任务
if [ -d /nestingdns/default ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
	echo $TZ > /etc/timezone
    echo "$SCHEDULE /nestingdns/bin/update.sh >> /nestingdns/log/update.log 2>&1 &" >> /var/spool/cron/crontabs/root
    rm -rf /nestingdns/default
fi

# 启动应用
echo `date "+%Y/%m/%d %H.%M.%S"`' [info] start smartdns'
nohup /nestingdns/bin/smartdns -f -x -c /nestingdns/etc/conf/smartdns.conf > /dev/null 2>&1 &
#nohup /nestingdns/bin/smartdns -f -x -c /nestingdns/etc/conf/smartdns.conf > /nestingdns/log/run_smartdns.log 2>&1 &

echo `date "+%Y/%m/%d %H.%M.%S"`' [info] start mosdns'
nohup /nestingdns/bin/mosdns start -c /nestingdns/etc/conf/mosdns.yaml -d /nestingdns/work/mosdns > /dev/null 2>&1 &
#nohup /nestingdns/bin/mosdns start -c /nestingdns/etc/conf/mosdns.yaml -d /nestingdns/work/mosdns > /nestingdns/log/run_mosdns.log 2>&1 &

# 启动定时任务
crond

echo `date "+%Y/%m/%d %H.%M.%S"`' [info] start adguardhome'
/nestingdns/bin/adguardhome --no-check-update -c /nestingdns/etc/conf/adguardhome.yaml -w /nestingdns/work/adguardhome