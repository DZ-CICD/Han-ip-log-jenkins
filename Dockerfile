# 아주 가벼운 Nginx 이미지를 기반으로 합니다.
FROM nginx:alpine

# 1. Nginx 기본 포트를 80 -> 8080으로 변경
RUN sed -i 's/80/8080/g' /etc/nginx/conf.d/default.conf

# 2. 파일 복사 및 권한 변경
COPY --chown=nginx:nginx --chmod=444 index.html /usr/share/nginx/html/index.html

# 3. Nginx 캐시/로그 디렉토리 권한 변경 (nginx 사용자가 쓸 수 있게)
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# 4. root 대신 'nginx' 사용자로 실행 전환 (보안 강화)
USER nginx
# 5. 변경된 포트 열
EXPOSE 8080
