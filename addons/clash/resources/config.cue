package main

import (
	"encoding/yaml"
	"list"
)

_config: {
	"mixed-port":          parameter.clashConfig.mixedPort
	"allow-lan":           parameter.clashConfig.allowLan
	"bind-address":        parameter.clashConfig.bindAddress
	mode:                  parameter.clashConfig.mode
	"log-level":           parameter.clashConfig.logLevel
	ipv6:                  parameter.clashConfig.ipv6
	"external-controller": parameter.clashConfig.externalController

	"external-ui": parameter.clashConfig.externalUI

	if parameter.clashConfig.dns != _|_ {dns: parameter.clashConfig.dns}

	if parameter.clashConfig.proxies != _|_ {
		if parameter.clashConfig.proxyEditor != _|_ {
			proxies: parameter.clashConfig.proxies +
				list.FlattenN([ for proxy in parameter.clashConfig.proxyEditor {proxy}], 1)
		}
		if parameter.clashConfig.proxyEditor == _|_ {
			proxies: parameter.clashConfig.proxies
		}
	}
	if parameter.clashConfig.proxies == _|_ && parameter.clashConfig.proxyEditor != _|_ {
		proxies: list.FlattenN([ for proxy in parameter.clashConfig.proxyEditor {proxy}], 1)
	}

	if parameter.clashConfig["proxy-groups"] != _|_ {
		"proxy-groups": parameter.clashConfig["proxy-groups"]
	}

	if parameter.clashConfig["proxy-providers"] != _|_ || parameter.clashConfig.proxyProviderEditor != _|_ {
		"proxy-providers": {
			if parameter.clashConfig["proxy-providers"] != _|_ {
				parameter.clashConfig["proxy-providers"]
			}

			if parameter.clashConfig.proxyProviderEditor != _|_ {
				for provider in parameter.clashConfig.proxyProviderEditor {
					"\(provider.name)": {
						for k, v in provider {
							if k != "name" {"\(k)": v}
						}
					}
				}
			}
		}
	}

	if parameter.clashConfig["rule-providers"] != _|_ || parameter.clashConfig.ruleProviderEditor != _|_ {
		"rule-providers": {
			if parameter.clashConfig["rule-providers"] != _|_ {
				parameter.clashConfig["rule-providers"]
			}

			if parameter.clashConfig.ruleProviderEditor != _|_ {
				for provider in parameter.clashConfig.ruleProviderEditor {
					(provider.name): {
						for k, v in provider {
							if k != "name" {
								(k): v
							}
						}
					}
				}
			}
		}
	}

	if parameter.clashConfig.rules != _|_ {rules: parameter.clashConfig.rules}
}

config: {
	name: "config"
	type: "k8s-objects"
	properties: objects: [{
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name:      "clash-config"
		data: "config.yaml": yaml.Marshal(_config)
	}]
}
