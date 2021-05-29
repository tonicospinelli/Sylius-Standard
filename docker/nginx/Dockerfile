ARG NGINX_VERSION=${NGINX_VERSION:-1.16}

FROM nginx:${NGINX_VERSION}-alpine AS sylius_nginx

ENV SYLIUS_WORKSPACE=${SYLIUS_WORKSPACE}

COPY conf.d/* /etc/nginx/conf.d

WORKDIR ${SYLIUS_WORKSPACE}

COPY --from=sylius_php /srv/sylius/public public/
COPY --from=sylius_node /srv/sylius/public public/
