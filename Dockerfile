FROM crashvb/supervisord:202303200348@sha256:1c05cdea0ff8ab86c651273b4b9aae5f63e5763860f651f3624ac7f630ea10d4
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:1c05cdea0ff8ab86c651273b4b9aae5f63e5763860f651f3624ac7f630ea10d4" \
	org.opencontainers.image.base.name="crashvb/supervisord:202303200348" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing Happytimesoft ONVIF Server." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/onvif-server-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/onvif-server" \
	org.opencontainers.image.url="https://github.com/crashvb/onvif-server-docker"

# Install packages, download files ...
RUN docker-apt libasound2 libxcb1 ssl-cert stunnel

# Configure: onvif-server
ENV \
	ONVIF_SERVER_CONFIG=/etc/onvif-server \
	ONVIF_SERVER_HOME=/var/lib/onvif-server \
	RTSP_SERVER_HOME=/var/lib/rtsp-server
# TODO: Fix built-in HTTPS and remove temporary stunnel workaround
# hadolint ignore=DL3003,DL4006
RUN mkdir --parent ${ONVIF_SERVER_HOME} ${ONVIF_SERVER_CONFIG} ${RTSP_SERVER_HOME} && \
	wget --quiet \
		--output-document=/happytime-onvif-server.tar.gz \
		https://www.happytimesoft.com/downloads/happytime-onvif-server.tar.gz && \
	sha256sum /happytime-onvif-server.tar.gz && \
	tar --directory=/tmp \
		--extract \
		--file=/happytime-onvif-server.tar.gz \
		--gzip \
		--strip-components=1 && \
	rm --force /happytime-onvif-server.tar.gz && \
	mv /tmp/config.xml \
		/tmp/html \
		/tmp/*.so.* \
		/tmp/mklinks.sh \
		/tmp/onvifserver \
		/tmp/snapshot.jpg \
		${ONVIF_SERVER_HOME} && \
	sed --expression='/<http_enable>/s/1/1/g' \
		--expression='/<https_enable>/s/0/1/g' \
		--expression='/<need_auth>/s/0/1/g' \
		--expression='/<cert_file>/c<cert_file>/etc/ssl/certs/onvif-server.crt</cert_file>' \
		--expression='/<key_file>/c<key_file>/etc/ssl/private/onvif-server.key</key_file>' \
		--in-place=.dist ${ONVIF_SERVER_HOME}/config.xml && \
	mv /tmp/happytime-rtsp-server/config.xml /tmp/happytime-rtsp-server/*.so.* \
		/tmp/happytime-rtsp-server/mklinks.sh \
		/tmp/happytime-rtsp-server/rtspserver \
		/tmp/happytime-rtsp-server/test.mp4 \
		${RTSP_SERVER_HOME} && \
	sed --expression='/<cert_file>/c<cert_file>/etc/ssl/certificates/rtsp-server.crt</cert_file>' \
		--expression='/<key_file>/c<key_file>/etc/ssl/private/rtsp-server.key</key_file>' \
		--in-place=.dist ${RTSP_SERVER_HOME}/config.xml && \
	cd ${ONVIF_SERVER_HOME} && \
	${ONVIF_SERVER_HOME}/mklinks.sh && \
	cd ${RTSP_SERVER_HOME} && \
	${RTSP_SERVER_HOME}/mklinks.sh && \
	rm --force --recursive /tmp/* ${ONVIF_SERVER_HOME}/mklinks.sh ${RTSP_SERVER_HOME}/mklinks.sh

# Configure: stunnel
COPY stunnel.conf /etc/stunnel/

# Configure: supervisor
COPY supervisord.onvif-server.conf /etc/supervisor/conf.d/onvif-server.conf
COPY supervisord.rtsp-server.conf /etc/supervisor/conf.d/rtsp-server.conf
COPY supervisord.stunnel.conf /etc/supervisor/conf.d/stunnel.conf

# Configure: entrypoint
COPY entrypoint.onvif-server /etc/entrypoint.d/onvif-server
COPY entrypoint.rtsp-server /etc/entrypoint.d/rtsp-server

# Configure: healthcheck
COPY healthcheck.onvif-server /etc/healthcheck.d/onvif-server
COPY healthcheck.rtsp-server /etc/healthcheck.d/rtsp-server
COPY healthcheck.stunnel /etc/healthcheck.d/stunnel

EXPOSE 8443/tcp

VOLUME ${ONVIF_SERVER_CONFIG}
