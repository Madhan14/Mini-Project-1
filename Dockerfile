# Dockerfile
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy build artifacts
COPY dist/ /usr/share/nginx/html/

# Optional: SPA fallback (uncomment and add custom nginx.conf if you need client-side routing)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
