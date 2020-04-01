FROM nginx:latest
RUN usermod -u 1001 nginx
RUN mkdir /app
COPY homework.html /app
COPY nginx.conf /etc/nginx/conf.d/
EXPOSE 8000