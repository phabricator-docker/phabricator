FROM php:5.6-apache

# Required Components
# @see https://secure.phabricator.com/book/phabricator/article/installation_guide/#installing-required-comp
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
  && rm -rf /var/lib/apt/lists/*

# install the PHP extensions we need
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libcurl4-gnutls-dev \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		mbstring \
		iconv \
		mysqli \
		curl \
		pcntl \
	; \
	\
  # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# RUN pecl install apc \
#   && docker-php-ext-enable apc

ENV APACHE_DOCUMENT_ROOT /var/www/phabricator/webroot

COPY ./etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY ./ /var/www

ENV PATH "$PATH:/var/www/phabricator/bin"
