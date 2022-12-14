package main

#Dns: {
	enable: bool
	ipv6:   bool
	"default-nameserver": [...string]
	"enhanced-mode": string
	"fake-ip-range": string
	"use-hosts":     bool
	nameserver: [...string]
	fallback: [...string]
	"fallback-filter": #FallbackFilter
}

#FallbackFilter: {
	geoip: true
	ipcidr: [...string]
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

#Proxy: #TrojanProxy | #ShadowsocksProxy | #VmessProxy | #SocketProxy | #HttpProxy | #SnellProxy | #ShadowsocksRProxy

#ProxyGroupType: "url-test" | "fallback" | "load-balance" | "select" | "relay"

#ProxyGroup: {
	name: string
	type: #ProxyGroupType
	proxies: [...string]
	url?:      string
	interval?: int
}

#ConfigMap: {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name: "clash-config"
	}
	data: {
		"config.yaml": string
	}
}

#ClashConfig: {
	"mixed-port":          int
	"allow-lan":           bool
	"bind-address":        string
	mode:                  string
	"log-level":           string
	"external-controller": string
	dns:                   #Dns
	proxies: [...#Proxy]
	"proxy-groups": [...#ProxyGroup]
	rules: [...string]
}

parameter: {
	// +usage=Clash image
	clashImage: *"dreamacro/clash-premium:2022.08.26" | string
	// +usage=Yacd image
	yacdImage: *"haishanh/yacd:v0.3.6" | string
	// +usage=Service type
	serviceType: *"ClusterIP" | "NodePort" | "LoadBalancer"
	// +usage=Clash config
	clashConfig: #ClashConfig | *{
		"mixed-port":          7890
		"allow-lan":           true
		"bind-address":        "*"
		mode:                  "rule"
		"log-level":           "info"
		"external-controller": ":9090"
		dns: {
			enable: true
			ipv6:   false
			"default-nameserver": ["223.5.5.5", "119.29.29.29"]
			"enhanced-mode": "redir-host"
			"fake-ip-range": "198.18.0.1/16"
			"use-hosts":     true
			nameserver: ["https://doh.pub/dns-query", "https://dns.alidns.com/dns-query"]
			fallback: [
				"https://doh.dns.sb/dns-query",
				"https://dns.cloudflare.com/dns-query",
				"https://dns.twnic.tw/dns-query",
				"tls://8.8.4.4:853",
			]
			"fallback-filter": {
				geoip: true
				ipcidr: ["240.0.0.0/4", "0.0.0.0/32"]
			}
		}
		proxies: []
		"proxy-groups": []
		rules: []
	}
}
