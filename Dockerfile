ARG PHP_VERSION=8.1

FROM --platform=linux/amd64 php:${PHP_VERSION}-fpm

ARG NODE_VERSION
ARG INSTALL_SQLSRV
ARG INSTALL_MOGODB
ARG XDEBUG_ENABLE

# Cài đặt các dependencies cần thiết
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libssl-dev \
    libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Cài đặt tất cả các extensions cần thiết
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mysqli zip bcmath mbstring exif pcntl xml intl opcache soap sockets gettext

# Cài đặt MongoDB extension từ PECL
RUN if [ ! -z "$INSTALL_MOGODB" ]; then \
      pecl install mongodb && \
      echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini; \
    fi

# Nếu NODE_VERSION được set, cài đặt Node.js
RUN if [ ! -z "$NODE_VERSION" ]; then \
      curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - && \
      apt-get install -y nodejs && \
      npm install -g yarn pnpm && \
      node -v && npm -v && yarn -v && pnpm -v; \
    fi

RUN apt-get install -y openssh-server && \
    mkdir /var/run/sshd && echo 'root:root' | chpasswd

    RUN apt-get update && apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug;

# Cài đặt Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Xác nhận Composer đã cài đặt
RUN composer --version

CMD service ssh restart

WORKDIR /var/www