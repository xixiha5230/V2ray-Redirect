# Model        : 3B+

## SoC MediaTek : BCM2710

* target          -> bcm27xx
* subtarget       -> bcm2710
* target Profile  -> 3B+

* target images
  * -> kernel -> 256M  
  * -> root -> 512M

* base system
  * -> bridge
  * -> Customize busybox option 
    * -> networking utils 
      * -> iproute
      * -> iprule
      * -> wget -> ALL
  * -> ca-certificates
  * -> dnsmasq-full
  
* administration
  * -> htop

* libraries
  * -> libustream-openssl (unset libustream-wolssl)

* luci
  * -> collections -> luci
  * -> modules -> translation -> chinese
  * -> application 
    * -> samaba
    * -> upnp
    * -> frpc/s
    * -> http-dns-proxy
  
* network
  * -> ip Adresses and names -> bind-dig
  * -> firewall -> iptables-mod-tproxy
  * -> ipset
  * -> xray-core
