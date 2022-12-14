package main

import "encoding/yaml"

config: {
	name: "config"
	type: "k8s-objects"
	properties: objects: [{
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name:      "clash-config"
		data: "config.yaml": yaml.Marshal(parameter.clashConfig)
	}]
}
