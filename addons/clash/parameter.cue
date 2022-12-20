package main

#FallbackFilter: {
	geoip:         bool
	"geoip-code"?: string
	ipcidr?: [...string]
	domain?: [...string]
}

#ProxyType: "trojan" | "ss" | "vmess" | "socks5" | "http" | "snell" | "ssr" | "wireguard"
#Port:      int | =~"^\\d+$"

#Proxy: {
	name:   string
	type:   #ProxyType
	server: string
	port:   #Port
	...
}

#TrojanProxy: {
	name:                string
	server:              string
	port:                #Port
	type:                "trojan"
	password:            string
	udp?:                bool
	sni?:                string
	"skip-cert-verify"?: bool
}

#ShadowsocksProxy: {
	name:     string
	server:   string
	port:     #Port
	type:     "ss"
	cipher:   string
	password: string
	udp:      bool
}

#VmessProxy: {
	name:    string
	server:  string
	port:    #Port
	type:    "vmess"
	uuid:    string
	alterId: int
	cipher:  string
}

#SocketProxy: {
	name:   string
	server: string
	port:   #Port
	type:   "socks5"
}

#HttpProxy: {
	name:   string
	server: string
	port:   #Port
	type:   "http"
}

#SnellProxy: {
	name:   string
	server: string
	port:   #Port
	type:   "snell"
	psk:    string
}

#ShadowsocksRProxy: {
	name:     string
	server:   string
	port:     #Port
	type:     "ssr"
	cipher:   string
	password: string
	obfs:     string
	protocol: string
}

#WireguardProxy: {
	name:             string
	server:           string
	port:             #Port
	type:             "wireguard"
	ip:               string
	ipv6?:            string
	"private-key":    string
	"public-key":     string
	"preshared-key"?: string
	dns?: [...string]
	mtu?: int
	udp:  bool | *true
}

#ProxyGroup: {
	name: *"PROXY" | string
	type: "url-test" | "fallback" | "load-balance" | "select" | "relay"
	proxies?: [...string]
	use?: [...string]
	"interface-name"?: string
	url?:              string
	interval?:         int
}

#HealthCheck: {
	enable:   *true | bool
	url:      *"http://www.gstatic.com/generate_204" | string
	interval: *300 | int
}

#HttpProxyProvider: {
	type:           "http"
	path:           string
	url:            string
	interval:       int
	"health-check": #HealthCheck
}

#HttpProxyProviderEditor: {
	name:           string
	type:           "http"
	path:           string
	url:            string
	interval:       *3600 | int
	"health-check": #HealthCheck
}

#RuleBehavior: *"domain" | "classical" | "ipcidr"

#HttpRuleProvider: {
	type:     "http"
	behavior: #RuleBehavior
	url:      string
	path:     string
	interval: int
}

#HttpRuleProviderEditor: {
	name:     string
	type:     "http"
	behavior: #RuleBehavior
	url:      string
	path:     string
	interval: *86400 | int
}

parameter: {
	//+usage=Namespace to deploy to, defaults to clash
	namespace: *"clash" | string	
	// +usage=Clash image
	clashImage: *"dreamacro/clash-premium:2022.08.26" | string
	// +usage=Yacd image
	yacdImage: *"haishanh/yacd:v0.3.6" | string
	// +usage=Service type
	serviceType: *"ClusterIP" | "NodePort" | "LoadBalancer"
	// +usage=Clash config
	clashConfig: {
		// +usage=Port of HTTP(S) proxy server on the local end
		mixedPort: *7890 | int
		// +usage=Allow connections to the local-end server from other LAN IP addresses
		allowLan: *true | bool
		// +usage= Bind IPv4 or IPv6 address, '*': bind all IP addresses, only applicable when 'allow-lan' is 'true'
		bindAddress: *"*" | string
		// +usage=Clash router working mode
		mode: *"rule" | "global" | "direct"
		// +usage=Clash log level
		logLevel: *"info" | "warning" | "error" | "debug" | "silent"
		ipv6:     *false | bool
		// +usage=RESTful web API listening address
		externalController: *":9090" | string
		// +usage=A relative path to the configuration directory or an absolute path to a directory in which you put some static web resource
		externalUI: *"/dashboard/ui" | string
		profile?: {
			// +usage=Open tracing exporter API
			tracing: *true | bool
		}
		// +usage=DNS server settings
		dns?: {
			enable: bool | *true
			// +usage=All DNS questions are sent directly to the nameserver, without proxies involved, clash answers the DNS question with the first result gathered, supports UDP, TCP, DoT, DoH. You can specify the port to connect to
			nameserver: [...string]
			listen?: string
			// +usage=When the false, response to AAAA questions will be empty
			ipv6?: bool
			// +usage=Nameservers are used to resolve the DNS nameserver hostnames below, specify IP addresses only
			"default-nameserver"?: [...string]
			"enhanced-mode"?: "fake-ip" | "redir-host"
			// +usage=Fake IP addresses pool CIDR
			"fake-ip-range"?: string
			// +usage=Lookup hosts and return IP record
			"use-hosts"?: bool
			// +usage=Hostnames in this list will not be resolved with fake IPs
			"fake-ip-filter"?: [...string]
			// +usage=DNS server will send concurrent requests to the servers in this section along with servers in 'nameservers'
			fallback?: [...string]
			"fallback-filter"?: #FallbackFilter
			"nameserver-policy"?: [...string]
		}
		// +usage=Proxy server settings
		proxies?: [...#Proxy]
		// +usage=Proxy server editor, will be merged into the proxies
		proxyEditor?: {
			trojanProxy?: [...#TrojanProxy]
			shadowsocksProxy?: [...#ShadowsocksProxy]
			vmessProxy?: [...#VmessProxy]
			socketProxy?: [...#SocketProxy]
			httpProxy?: [...#HttpProxy]
			snellProxy?: [...#SnellProxy]
			shadowsocksRProxy?: [...#ShadowsocksRProxy]
			wireguardProxy?: [...#WireguardProxy]
		}
		// +usage=Relay chains the proxies
		"proxy-groups"?: [...#ProxyGroup]
		"proxy-providers"?: [string]: #HttpProxyProvider
		// +usage=Proxy provider editor, will be merged into the proxy-providers
		proxyProviderEditor?: [...#HttpProxyProviderEditor]
		"rule-providers"?: [string]: #HttpRuleProvider
		// +usage=Rule provider editor, will be merged into the rule-providers
		ruleProviderEditor?: [...#HttpRuleProviderEditor]
		rules?: [...=~"^(DOMAIN-SUFFIX,|DOMAIN-KEYWORD,|DOMAIN,|SRC-IP-CIDR,|IP-CIDR,|IP-CIDR6,|GEOIP,|DST-PORT,|SRC-PORT,|MATCH,|RULE-SET,)"]
	}
}
