#!/bin/sh

function init_dir(){
    dir=$1

    if [ ! -d ${dir} ]; then
        echo `date "+%Y/%m/%d %H:%M:%S"`' [info] init dir: '${dir}
        mkdir -p ${dir}
    fi
}

function init_file_conf(){
    filename=$1

    if [ ! -f /nestingdns/etc/conf/${filename} ]; then
        echo `date "+%Y/%m/%d %H:%M:%S"`' [info] init conf file: '${filename}
        cp /nestingdns/default/conf/${filename} /nestingdns/etc/conf/
    fi
}

function init_file_site(){
    filename=$1

    if [ ! -f /nestingdns/etc/site/${filename} ]; then
        echo `date "+%Y/%m/%d %H:%M:%S"`' [info] init site file: '${filename}
        if [ -f /nestingdns/default/site/${filename} ]; then
            cp /nestingdns/default/site/${filename} /nestingdns/etc/site/
        else
            touch /nestingdns/etc/site/${filename}
        fi
    fi
}


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
init_dir /nestingdns/etc/conf
init_file_conf smartdns.conf
init_file_conf mosdns.yaml
init_file_conf mosdns_load_rules.yaml
init_file_conf mosdns_forward.yaml
init_file_conf adguardhome.yaml


# /nestingdns/etc/site 初始化
init_dir /nestingdns/etc/site
init_file_site direct-list.txt
init_file_site apple-cn.txt
init_file_site google-cn.txt
init_file_site force-cn.txt

init_file_site proxy-list.txt
init_file_site gfw.txt
init_file_site greatfire.txt
init_file_site force-nocn.txt

init_file_site private.txt

init_file_site CN-ip-cidr.txt

init_file_site cloudflare.txt

init_file_site hosts.txt


# /nestingdns/work 初始化
init_dir /nestingdns/work/smartdns
init_dir /nestingdns/work/mosdns
if [ ! -f /nestingdns/work/mosdns/cache.dump ]; then
    echo `date "+%Y/%m/%d %H:%M:%S"`' [info] init: mosdns cache file'
    cp /nestingdns/default/cache/cache.dump /nestingdns/work/mosdns/
fi
init_dir /nestingdns/work/adguardhome


# 设置时区及定时任务
if [ -d /nestingdns/default ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
	echo $TZ > /etc/timezone
    echo "$SCHEDULE /nestingdns/bin/update.sh > /nestingdns/log/update.log 2>&1 &" >> /var/spool/cron/crontabs/root
    rm -rf /nestingdns/default
fi


# 启动应用
# 启动 smartdns
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] start smartdns: '`/nestingdns/bin/smartdns -v` | sed 's/smartdns /v/'
nohup /nestingdns/bin/smartdns -f -x -c /nestingdns/etc/conf/smartdns.conf > /dev/null 2>&1 &

# 启动 mosdns
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] start mosdns: '`/nestingdns/bin/mosdns version`
nohup /nestingdns/bin/mosdns start -c /nestingdns/etc/conf/mosdns.yaml -d /nestingdns/work/mosdns > /dev/null 2>&1 &

# 启动定时任务 crond，定时任务包含重启mosdns，放在 mosdns 后启动
crond

# 启动 adguardhome
echo `date "+%Y/%m/%d %H:%M:%S"`' [info] start adguardhome: '`/nestingdns/bin/adguardhome --version` | sed 's/AdGuard Home, version //'
/nestingdns/bin/adguardhome --no-check-update -c /nestingdns/etc/conf/adguardhome.yaml -w /nestingdns/work/adguardhome