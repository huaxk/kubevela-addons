package main

#Dns: {
	enable: bool | *true
	listen: string | *"0.0.0.0:53"
	// +usage=When the false, response to AAAA questions will be empty
	ipv6: bool | *false
	// +usage=Nameservers are used to resolve the DNS nameserver hostnames below, specify IP addresses only
	"default-nameserver": [...string]
	"enhanced-mode": "fake-ip" | "redir-host"
	// +usage=Fake IP addresses pool CIDR
	"fake-ip-range": string
	// +usage=Lookup hosts and return IP record
	"use-hosts": bool
	// +usage=Hostnames in this list will not be resolved with fake IPs
	"fake-ip-filter"?: [...string]
	// +usage=All DNS questions are sent directly to the nameserver, without proxies involved, clash answers the DNS question with the first result gathered
	nameserver: [...string]
	// +usage=DNS server will send concurrent requests to the servers in this section along with servers in 'nameservers'
	fallback?: [...string]
	"fallback-filter"?: #FallbackFilter
	"nameserver-policy"?: [...string]
}

#FallbackFilter: {
	geoip:        true
	"geoip-code": bool
	ipcidr: [...string]
	domain: [...string]
}

#TrojanProxy: {
	name:     string
	type:     "trojan"
	server:   string
	port:     int
	password: string
	...
}

#ShadowsocksProxy: {
	name:     string
	type:     "ss"
	server:   string
	port:     int
	cipher:   string
	password: string
	udp:      bool
	...
}

#VmessProxy: {
	name:    string
	type:    "vmess"
	server:  string
	port:    int
	uuid:    string
	alterId: int
	cipher:  string
	...
}

#SocketProxy: {
	name:   string
	type:   "socks5"
	server: string
	port:   int
	...
}

#HttpProxy: {
	name:   string
	type:   "http"
	server: string
	port:   int
	...
}

#SnellProxy: {
	name:   string
	type:   "snell"
	server: string
	port:   int
	psk:    string
	...
}

#ShadowsocksRProxy: {
	name:     string
	type:     "ssr"
	server:   string
	port:     int
	cipher:   string
	password: string
	obfs:     string
	protocol: string
}

#WireguardProxy: {
	name:             string
	type:             "wireguard"
	server:           string
	port:             int
	ip:               string
	ipv6?:            string
	"private-key":    string
	"public-key":     string
	"preshared-key"?: string
	dns?: [...string]
	mtu?: int
	udp:  bool | *true
}

#Proxy: #TrojanProxy | #ShadowsocksProxy | #VmessProxy | #SocketProxy | #HttpProxy | #SnellProxy | #ShadowsocksRProxy | #WireguardProxy

#HealthCheck: {
	enable:   bool | *true
	url:      string | *"http://www.gstatic.com/generate_204"
	interval: int | *300
}

#HttpProxyProvider: {
	type:           "http"
	path:           string
	url:            string
	interval:       int | *3600
	"health-check": #HealthCheck
}

#FileProxyProvider: {
	type:           "file"
	path:           string
	"health-check": #HealthCheck
}

#ProxyProvider: #HttpProxyProvider | #FileProxyProvider

#ProxyGroupType: "url-test" | "fallback" | "load-balance" | "select" | "relay"

#ProxyGroup: {
	name: string | *"PROXY"
	type: #ProxyGroupType
	proxies: [...string]
	url?:      string
	interval?: int
	use?: [...string]
	proxies?: [...string]
}

#HTTPRuleProvider: {
	type:     "http"
	behavior: "classical" | "ipcidr" | "domain"
	url:      string
	path:     string
	interval: int | *86400
}

#FileRuleProvider: {
	type:     "file"
	behavior: "classical" | "ipcidr" | "domain"
	path:     string
}

#RuleProvider: #HTTPRuleProvider | #FileRuleProvider

#ClashConfig: {
	// +usage=Port of HTTP(S) proxy server on the local end
	"mixed-port": int | *7890
	// +usage=Allow connections to the local-end server from other LAN IP addresses
	"allow-lan": bool | *true
	// +usage= Bind IPv4 or IPv6 address, '*': bind all IP addresses, only applicable when 'allow-lan' is 'true'
	"bind-address": string | *"*"
	// +usage=Clash router working mode
	mode: "rule" | "global" | "direct" | *"rule"
	// +usage=Clash log level
	"log-level": "info" | "warning" | "error" | "debug" | "silent" | *"info"
	ipv6:        bool | *false
	// +usage=RESTful web API listening address
	"external-controller": string | *":9090"
	// +usage=A relative path to the configuration directory or an absolute path to a directory in which you put some static web resource
	"external-ui": string | *"ui"
	// +usage=DNS server settings
	dns?: #Dns
	// +usage=
	proxies?: [...#Proxy]
	"proxy-providers"?: {[string]: #ProxyProvider}
	// +usage=
	"proxy-groups"?: [...#ProxyGroup]
	"rule-providers"?: {[string]: #RuleProvider}
	// +usage=
	rules?: [...string]
}

parameter: {
	// +usage=Clash image
	clashImage: *"dreamacro/clash-premium:2022.08.26" | string
	// +usage=Yacd image
	yacdImage: *"haishanh/yacd:v0.3.6" | string
	// +usage=Service type
	serviceType: *"ClusterIP" | "NodePort" | "LoadBalancer"
	// +usage=Clash config
	clashConfig: #ClashConfig 
	// | *{
	// 	"mixed-port":          7890
	// 	"allow-lan":           true
	// 	"bind-address":        "*"
	// 	mode:                  "rule"
	// 	"log-level":           "info"
	// 	"external-controller": ":9090"
	// 	dns: {
	// 		enable: true
	// 		ipv6:   false
	// 		"default-nameserver": ["223.5.5.5", "119.29.29.29", ...]
	// 		"enhanced-mode": "redir-host"
	// 		"fake-ip-range": "198.18.0.1/16"
	// 		"use-hosts":     true
	// 		nameserver: ["https://doh.pub/dns-query", "https://dns.alidns.com/dns-query"]
	// 		fallback: [
	// 		 "https://doh.dns.sb/dns-query",
	// 		 "https://dns.cloudflare.com/dns-query",
	// 		 "https://dns.twnic.tw/dns-query",
	// 		 "tls://8.8.4.4:853",
	// 		]
	// 		"fallback-filter": {
	// 			geoip: true
	// 			 ipcidr: ["240.0.0.0/4", "0.0.0.0/32"]
	// 		}
	// 	}
	// }
}
