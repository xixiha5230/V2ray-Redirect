# Model : 斐讯k1

## SoC MediaTek : MT7620

* target          -> mediaTek Ralink MIPS
* subtarget       -> mt7620
* target Profile  -> Phicomm PSG1208

* base system
  * -> ca-certificates
  * -> dnsmasq-full

* libraries
  * -> libustream-openssl (unset libustream-wolssl)

* luci
  * -> collections -> luci
  * -> modules -> translation -> chinese
  * -> application -> upnp

* network
  * -> firewall -> iptables-mod-tproxy?
  * -> ipset?
