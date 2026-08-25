# ─── Frontend: Nginx-served static app ───────────────────────────
FROM nginx:alpine

LABEL maintainer="Jesinder & Menaka - DevOps Team"
LABEL project="Employee Management System - Frontend"

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/

# Copy frontend files
COPY index.html /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
