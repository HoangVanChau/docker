FROM --platform=linux/amd64 webdevops/php-nginx-dev:8.0

RUN apt-get install -qq -y curl gnupg && \
            echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/20.04/prod focal main" > /etc/apt/sources.list.d/mssql.list && \
            curl -sS https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
            apt-get update -qq && \
            ACCEPT_EULA=Y apt-get install -qq -y \
                # To keep
                mssql-tools unixodbc-dev

RUN pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN wget -O "/usr/local/bin/go-replace" "https://github.com/webdevops/goreplace/releases/download/1.1.2/gr-arm64-linux" \
   && chmod +x "/usr/local/bin/go-replace" \
   && "/usr/local/bin/go-replace" --version

# Install OpenSSH and set the password for root to "Docker!". In this example, "apk add" is the install instruction for an Alpine Linux-based image.
RUN apt-install openssh-server \
     && echo "root:Docker!" | chpasswd

# Copy the sshd_config file to the /etc/ssh/ directory
# COPY docker/sshd_config /etc/ssh/

COPY --chown=application:application  . /app
WORKDIR /app
USER application

EXPOSE 80 443 2222
