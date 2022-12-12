package main

clash: {
	name: "clash"
	type: "webservice"
	properties: {
		image:           parameter.clashImage
		imagePullPolicy: "IfNotPresent"
		ports: [
			{
				name:   "proxy"
				port:   7890
				expose: true
			},
			{
				name:   "socket"
				port:   7891
				expose: true
			},
			{
				name:   "api"
				port:   9090
				expose: true
			},
			// {
			// 	name:   "yacd"
			// 	port:   80
			// 	expose: true
			// },
		]
		exposeType: parameter.serviceType
		livenessProbe: {
			tcpSocket: {
				port: 7890
			}
			initialDelaySeconds: 5
		}
		readinessProbe: {
			tcpSocket: {
				port: 7890
			}
			initialDelaySeconds: 5
		}
		volumeMounts: {
			hostPath: [
				{
					name:      "localtime"
					mountPath: "/etc/localtime"
					path:      "/usr/share/zoneinfo/Asia/Shanghai"
				},
			]
			configMap: [
				{
					name:      "config"
					mountPath: "/root/.config/clash/config.yaml"
					subPath:   "config.yaml"
					cmName:    "clash-config"
				},
			]
		}
	}
	traits: [
		{
			type: "resource"
			properties: {
				requests: {
					cpu:    0.1
					memory: "100Mi"
				}

				limits: {
					cpu:    0.5
					memory: "500Mi"
				}
			}
		},
		// {
		// 	type: "sidecar"
		// 	properties: {
		// 		name:  "yacd"
		// 		image: parameter.yacdImage
		// 		env: [{
		// 			name:  "YACD_DEFAULT_BACKEND"
		// 			value: "http://192.168.88.111:9090"
		// 		}]
		// 		volumnes: [{
		// 			name: "localtime"
		// 			path: "/etc/localtime"
		// 		}]
		// 		livenessProbe: {
		// 			httpGet: {
		// 				path: "/"
		// 				port: 80
		// 			}
		// 			initialDelaySeconds: 5
		// 		}
		// 		readinessProbe: {
		// 			httpGet: {
		// 				path: "/"
		// 				port: 80
		// 			}
		// 			initialDelaySeconds: 5
		// 		}
		// 	}
		// },
	]
}
