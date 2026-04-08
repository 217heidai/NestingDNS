# smartdns
FROM pymumu/smartdns:latest AS smartdns-builder
LABEL previous-stage=smartdns-builder

# mosdns
FROM irinesistiana/mosdns:latest AS mosdns-builder
LABEL previous-stage=mosdns-builder

# adguardhome
FROM adguard/adguardhome:latest AS adguardhome-builder
LABEL previous-stage=adguardhome-builder

# 合并smartdns、mosdns、adguardhome
FROM alpine:latest AS nestingdns-builder
LABEL previous-stage=nestingdns-builder

# 安装依赖
RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.tuna.tsinghua.edu.cn/alpine#g' /etc/apk/repositories && \
    apk --no-cache add ca-certificates curl

# 拷入文件
COPY nestingdns /nestingdns

# 创建目录
RUN mkdir -p /nestingdns/default/site && \
    mkdir -p /nestingdns/lib && \
    mkdir -p /nestingdns/www


# 下载 site 文件
RUN curl -sSL https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/direct.txt -o /nestingdns/default/site/direct.txt && \
    curl -sSL https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/proxy.txt -o /nestingdns/default/site/proxy.txt && \
    curl -sSL https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/private.txt -o /nestingdns/default/site/private.txt && \
    curl -sSL https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/ipv4_china.txt -o /nestingdns/default/site/ipv4_china.txt && \
    curl -sSL https://raw.githubusercontent.com/217heidai/RoutingRules/main/rules/ipv4_cloudflare.txt -o /nestingdns/default/site/ipv4_cloudflare.txt

# 拷入文件
COPY --from=smartdns-builder /usr/share/smartdns/wwwroot /nestingdns/www/smartdns
COPY --from=smartdns-builder /usr/local/lib/smartdns /nestingdns/lib/smartdns
RUN ln -s /nestingdns/lib/smartdns/run-smartdns /nestingdns/bin/smartdns
COPY --from=mosdns-builder /usr/bin/mosdns /nestingdns/bin/mosdns
COPY --from=adguardhome-builder /opt/adguardhome/AdGuardHome /nestingdns/bin/adguardhome

# 添加执行权限
RUN chmod +x /nestingdns/bin/*


# 生成 nestingdns 镜像
FROM alpine:latest
LABEL maintainer="217heidai"
LABEL name="nestingdns"

ENV TZ="Asia/Shanghai"
ENV SCHEDULE="0  4  *  *  *"

# 拷入文件
COPY --from=nestingdns-builder /nestingdns /nestingdns

# 安装依赖
RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.tuna.tsinghua.edu.cn/alpine#g' /etc/apk/repositories && \
    apk --no-cache add ca-certificates libcap tzdata curl tini && \
    rm -rf /var/cache/apk/* && \
    setcap 'cap_net_bind_service=+eip' /nestingdns/bin/adguardhome

# 测试用
#RUN apk --no-cache add nano busybox-extras bind-tools

# 设置 healthcheck
HEALTHCHECK --interval=60s --retries=1 CMD sh /nestingdns/bin/healthcheck.sh

# smartdns
# 6053   : TCP, UDP : DNS
# 7053   : TCP, UDP : DNS
# 8053   : TCP, UDP : DNS
# 4000   : TCP, UDP : HTTP(S) (alt, incl. HTTP/3)
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
       4000/tcp 4000/udp \
       5053/tcp 5053/udp \
       4053/tcp 4053/udp \
       3000/tcp 3000/udp

WORKDIR /nestingdns/
VOLUME ["/nestingdns/etc/", "/nestingdns/work/", "/nestingdns/log/"]
ENTRYPOINT ["/sbin/tini", "--", "/nestingdns/bin/entrypoint.sh"]