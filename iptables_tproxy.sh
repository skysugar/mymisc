ip rule add fwmark 1 table 100
ip route add local default dev lo table 100

#gateway
iptables -t mangle -N V2RAY
iptables -t mangle -A V2RAY -s 192.168.0.0/16 -p tcp -j TPROXY --on-port 12345 --tproxy-mark 1
iptables -t mangle -A V2RAY -s 192.168.0.0/16 -p udp -j TPROXY --on-port 12345 --tproxy-mark 1
iptables -t mangle -A PREROUTING -j V2RAY

#local
iptables -t mangle -N V2RAY_MASK
iptables -t mangle -A V2RAY_MASK -d server_ip -j RETURN
iptables -t mangle -A V2RAY_MASK -s 192.168.0.0/16 -p tcp -j MARK --set-mark 1
iptables -t mangle -A V2RAY_MASK -s 192.168.0.0/16 -p udp -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -j V2RAY_MASK
