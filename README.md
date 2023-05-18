# onvif-server-docker

[![version)](https://img.shields.io/docker/v/crashvb/onvif-server/latest)](https://hub.docker.com/repository/docker/crashvb/onvif-server)
[![image size](https://img.shields.io/docker/image-size/crashvb/onvif-server/latest)](https://hub.docker.com/repository/docker/crashvb/onvif-server)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/onvif-server-docker.svg)](https://github.com/crashvb/onvif-server-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [Happytimesoft ONVIF Server](https://www.happytimesoft.com/products/onvif-server/index.html).

## Entrypoint Scripts

### onvif-server

The embedded entrypoint script is located at `/etc/entrypoint.d/onvif-server` and performs the following actions:

1. The PKI certificates are generated or imported.
2. A new ONVIF Server configuration is optionally deployed from `/etc/onvif-server/config.xml`.

### rtsp-server

The embedded entrypoint script is located at `/etc/entrypoint.d/rtsp-server` and performs the following actions:

1. The configuration is modified from the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | ENABLE\_RTSP\_SERVER | _undefined_ | If undefined, rtsp-server will not be instantiated.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ entrypoint.d/
│  │  ├─ onvif-server
│  │  └─ rtsp-server
│  ├─ healthcheck.d/
│  │  ├─ onvif-server
│  │  └─ rtsp-server
│  ├─ onvif-server/
│  └─ supervisor/
│     └─ config.d/
│        ├─ onvif-server.conf
│        ├─ rtsp-server.conf
│        └─ stunnel.conf
└─ run/
   └─ secrets/
      ├─ onvif-server.crt
      ├─ onvif-server.key
      └─ onvif-serverca.crt
```

### Exposed Ports

* `8443/tcp` - ONVIF Server listening port.

### Volumes

* `/etc/onvif-server` - onvif-server configuration directory.

## Development

[Source Control](https://github.com/crashvb/onvif-server-docker)

