Gargoyle CC Patchs
========

```
branch_name="Chaos Calmer"
branch_id="15.05"

git clone  git://git.openwrt.org/15.05/openwrt.git openwrt-15.05
git checkout eadf19c0b43d2f75f196ea8d875a08c7c348530c
cp -R /patch/to/gargoyle_cc/* /patch/to/openwrt-15.05
```

```
make menuconfig

Advanced configuration options (for developers)  --->
 	Toolchain Options  --->
		C Library implementation (Use (e)glibc)  --->
		(e)glibc version (glibc 2.21)  --->

Firewall  --->
iptables-mod-xxx		/* 石像鬼的4个，或者全勾 */
l7-protocols
miniupnpd

Routing and Redirection --->
tc
ip

Web Servers/Proxies  --->
shellguilighttpd

Utilities  --->
haserl

Libraries  --->
jansson
libmosquitto
	database  --->
	libsqlite3

Network --->
wol
bw-mon
bw-utils
ipset
	File Transfer  --->
	wget
IP Addresses and Names  --->
	ddns-scripts

Base system --->
dnsmasq-full

Kernel modules > Network Support --->
kmod-sched

Utilities  ---> 
	shadow-utils --->

```
