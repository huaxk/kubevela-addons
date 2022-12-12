package main

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

parameter: {
	// +usage=Clash image
	clashImage: *"dreamacro/clash-premium:2022.08.26" | string
	// +usage=Yacd image
	yacdImage: *"haishanh/yacd:v0.3.6" | string
	// +usage=Service type
	serviceType: *"ClusterIP" | "NodePort" | "LoadBalancer"
	// +usage=Clash config, just a kubernetes ConfigMap which name is clash-config and data key is "config.yaml"
	clashConfig: [...#ConfigMap] | *[
			{
			apiVersion: "v1"
			kind:       "ConfigMap"
			metadata: {
				name: "clash-config"
			}
			data: {
				"config.yaml": ""
			}
		},
	]
}
