# syntax=docker/dockerfile:1

# ---- build stage ----------------------------------------------------------
FROM ghcr.io/hugo/hugo-extended:latest AS builder
WORKDIR /src
COPY . .
RUN hugo --minify --baseURL "https://bramen.org/"

# ---- runtime stage --------------------------------------------------------
FROM ghcr.io/nginx/nginx-unprivileged:1.27-alpine AS runtime
COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
