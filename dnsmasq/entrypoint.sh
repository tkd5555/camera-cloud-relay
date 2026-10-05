#!/bin/sh
# 起動のたびにホストの iptables を整えてから dnsmasq を起動する。
# ルールが消えていても（ホスト再起動など）ここで元に戻る。
LAN_IF=enp1s0

mkdir -p /var/log/dnsmasq
touch /var/log/dnsmasq/dnsmasq.log
chmod 644 /var/log/dnsmasq/dnsmasq.log

# カメラが 8.8.8.8:53 などへ直接送る DNS 問い合わせを、ローカルの dnsmasq へ吸い込む。
# カメラのゲートウェイをこのサーバーにしているので、その通信はここを通る。
iptables -t nat -C PREROUTING -i "$LAN_IF" -p udp --dport 53 -j REDIRECT --to-ports 53 2>/dev/null || \
iptables -t nat -I PREROUTING 1 -i "$LAN_IF" -p udp --dport 53 -j REDIRECT --to-ports 53

# カメラが pool.ntp.org などへ送る NTP（UDP 123）を、ホストの chrony へ吸い込む。
# ホスト側は chrony/lan-ntp-server.conf で LAN にだけ時刻を配る。
iptables -t nat -C PREROUTING -i "$LAN_IF" -p udp --dport 123 -j REDIRECT --to-ports 123 2>/dev/null || iptables -t nat -I PREROUTING 1 -i "$LAN_IF" -p udp --dport 123 -j REDIRECT --to-ports 123

# LAN から入って LAN へ出る転送を捨てる。
# Docker が IP 転送を有効にするため、これが無いとカメラの通信がここ経由で外へ抜ける。
iptables -C DOCKER-USER -i "$LAN_IF" -o "$LAN_IF" -j DROP 2>/dev/null || \
iptables -I DOCKER-USER 1 -i "$LAN_IF" -o "$LAN_IF" -j DROP

exec dnsmasq -k --conf-file=/etc/dnsmasq.conf
