#!/bin/sh
# Runs the API on 3000 and nginx on $PORT (Render sets it) in one container.
set -e
PUBLIC_PORT="${PORT:-10000}"
HOST="${RENDER_EXTERNAL_HOSTNAME:-localhost}"
export RP_ID="${RP_ID:-$HOST}"
export ORIGIN="${ORIGIN:-${RENDER_EXTERNAL_URL:-http://localhost:$PUBLIC_PORT}}"
export RP_NAME="${RP_NAME:-JDTraker}"
export DATA_DIR="${DATA_DIR:-/data}"
export TRUST_PROXY=1
export PASSWORD_LOGIN="${PASSWORD_LOGIN:-1}"
export FIRST_USER_ADMIN="${FIRST_USER_ADMIN:-1}"

PORT=3000 node /app/server.js &

export NGINX_PORT="$PUBLIC_PORT" BACKEND=127.0.0.1 PORT=3000 RESOLVER=1.1.1.1 \
  CF_CONNECTING_IP="" BASE_PATH="" MEDIA_UPLOAD_MAX=48m
envsubst '${NGINX_PORT} ${BACKEND} ${PORT} ${RESOLVER} ${CF_CONNECTING_IP} ${BASE_PATH} ${MEDIA_UPLOAD_MAX}' \
  < /etc/nginx/nginx.conf.template > /etc/nginx/http.d/default.conf
rm -f /etc/nginx/http.d/default.conf.bak
exec nginx -g 'daemon off;'
