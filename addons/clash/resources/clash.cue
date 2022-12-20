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
		{
			type: "init-container"
			properties: {
				name:  "yacd"
				image: parameter.yacdImage
				cmd: ["cp", "-r", "/usr/share/nginx/html", "/dashboard/ui"]
				mountName:     "dashboard"
				initMountPath: "/dashboard"
				appMountPath:  "/dashboard"
			}
		},
	]
}
