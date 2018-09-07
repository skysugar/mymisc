iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

##### BEGIN ##### SSR ##
iptables -t nat -N SSR
iptables -t nat -A SSR -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SSR -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SSR -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SSR -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SSR -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SSR -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SSR -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SSR -d 240.0.0.0/4 -j RETURN

## ss server ip
iptables -t nat -A SSR -d ss_server_ip -j RETURN

## client use local network
#iptables -t nat -A SSR -s 192.168.1.104 -j RETURN

## set client way to out
#iptables -t nat -A SSR -p icmp -s 10.12.18.131 -j REDIRECT --to-ports 12004
#iptables -t nat -A SSR -p tcp -s 10.12.18.131 -j REDIRECT --to-ports 12004
#iptables -t nat -A SSR -p udp -s 10.12.18.131 -j REDIRECT --to-ports 13004

## set default way without iptables rules
#iptables -t nat -A SSR -p icmp -j RETURN
#iptables -t nat -A SSR -p tcp -j RETURN
#iptables -t nat -A SSR -p udp -j RETURN
#iptables -t nat -A SSR -p udp --dport 53 -j REDIRECT --to-ports 11053
iptables -t nat -A SSR -p icmp -j REDIRECT --to-ports 11000
iptables -t nat -A SSR -p tcp -j REDIRECT --to-ports 11000
iptables -t nat -A SSR -p udp -j REDIRECT --to-ports 11000
##### END ##### SSR ##


## Virtual Server portmap
#iptables -t nat -A PREROUTING -d router_wan_ip -p tcp --dport 8000 -j DNAT --to client_lan_ip:80
#iptables -t nat -A POSTROUTING -d client_lan_ip -p tcp --dport 80 -j SNAT --to router_lan_ip


## NAT enable or disable
#iptables -t nat -A OUTPUT -p icmp -j SSR
#iptables -t nat -A OUTPUT -p tcp -j SSR
#iptables -t nat -A OUTPUT -p udp -j SSR
iptables -t nat -A PREROUTING -s 192.168.2.0/24 -j SSR
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -j MASQUERADE
