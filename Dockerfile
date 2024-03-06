# smartdns
FROM pymumu/smartdns:latest as smartdns-builder
LABEL previous-stage=smartdns-builder

# mosdns
FROM irinesistiana/mosdns:latest as mosdns-builder
LABEL previous-stage=mosdns-builder

# adguardhome
FROM adguard/adguardhome:latest as adguardhome-builder
LABEL previous-stage=adguardhome-builder

# 合并smartdns、mosdns、adguardhome
FROM alpine:latest as nestingdns-builder
LABEL previous-stage=nestingdns-builder

# 安装依赖，配置时区
RUN apk --no-cache add curl

# 创建目录
RUN mkdir -p /nestingdns && \
    mkdir -p /nestingdns/bin && \
    mkdir -p /nestingdns/etc && \
    mkdir -p /nestingdns/work && \
    mkdir -p /nestingdns/log

# 拷入默认配置文件
COPY default /nestingdns/default

# 下载 site 文件
RUN mkdir -p /nestingdns/default/site  && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt > /nestingdns/default/site/direct-list.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt > /nestingdns/default/site/apple-cn.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/google-cn.txt > /nestingdns/default/site/google-cn.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt > /nestingdns/default/site/proxy-list.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt > /nestingdns/default/site/gfw.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt > /nestingdns/default/site/greatfire.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/private.txt > /nestingdns/default/site/private.txt && \
    curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/Hackl0us/GeoIP2-CN/release/CN-ip-cidr.txt > /nestingdns/default/site/CN-ip-cidr.txt && \
    curl https://www.cloudflare-cn.com/ips-v4/# > /nestingdns/default/site/cloudflare.txt

# 修正 private.txt 中 msftconnecttest.com、msftncsi.com 域名拦截，导致 windows 系统网络图标，显示网络不可用
RUN sed -i "/domain:msftncsi.com/d" /nestingdns/default/site/private.txt
RUN sed -i "/domain:msftconnecttest.com/d" /nestingdns/default/site/private.txt

# 拷入可执行文件
COPY --from=smartdns-builder /usr/sbin/smartdns /nestingdns/bin/smartdns
COPY --from=mosdns-builder /usr/bin/mosdns /nestingdns/bin/mosdns
COPY --from=adguardhome-builder /opt/adguardhome/AdGuardHome /nestingdns/bin/adguardhome

# 拷入entrypoint.sh、update.sh
COPY entrypoint.sh /nestingdns/bin/entrypoint.sh
COPY update.sh /nestingdns/bin/update.sh


# 生成 nestingdns 镜像
FROM alpine:latest
LABEL maintainer="217heidai"
LABEL name="nestingdns"

ENV TZ="Asia/Shanghai"
ENV SCHEDULE="0  4  *  *  *"

# 测试用
#RUN apk --no-cache add nano busybox-extras bind-tools

# 安装依赖，配置时区
RUN apk --no-cache add ca-certificates libcap tzdata curl && \
    rm -rf /var/cache/apk/*

# 拷入文件
COPY --from=nestingdns-builder /nestingdns /nestingdns

# 添加执行权限
RUN chmod +x /nestingdns/bin/*

RUN setcap 'cap_net_bind_service=+eip' /nestingdns/bin/adguardhome

# smartdns
# 6053   : TCP, UDP : DNS
# 7053   : TCP, UDP : DNS
# 8053   : TCP, UDP : DNS
# mosdns
# 5053   : TCP, UDP : DNS
# adguardhome
# 4053   : TCP, UDP : DNS
# 443    : TCP, UDP : HTTPS, DNS-over-HTTPS (incl. HTTP/3), DNSCrypt (main)
# 853    : TCP, UDP : DNS-over-TLS, DNS-over-QUIC
# 3000   : TCP, UDP : HTTP(S) (alt, incl. HTTP/3)
EXPOSE 6053/tcp 6053/udp \
       7053/tcp 7053/udp \
       8053/tcp 8053/udp \
       5053/tcp 5053/udp \
       4053/tcp 4053/udp \
       3000/tcp 3000/udp

WORKDIR /nestingdns/
VOLUME ["/nestingdns/etc/", "/nestingdns/work/", "/nestingdns/log/"]
ENTRYPOINT ["/nestingdns/bin/entrypoint.sh"]