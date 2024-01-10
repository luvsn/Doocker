# Original file: https://github.com/odoo/docker/blob/master/15.0/Dockerfile
# Modified to match Odoo 12 requirements running from source

FROM debian:buster

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

RUN apt-get update

RUN apt-get install --reinstall build-essential -y
RUN apt-get install --reinstall file -y

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get install -y --no-install-recommends \
        postgresql-client \
        wget \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        libsasl2-dev \
        libldap2-dev \
        libxml2 \
        libxml2-dev \
        node-less \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-dev \
        libpq-dev \
        gcc \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        procps \
        nano 

# Install wkhtmltox package
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Download Odoo sources
RUN curl -o odoo.tar.xz -sSL https://nightly.odoo.com/12.0/nightly/deb/odoo_12.0.latest.tar.xz
RUN tar -xf odoo.tar.xz
RUN rm odoo.tar.xz

# Copy requirements
COPY requirements.txt /src

# Install Python dependencies
RUN pip3 install wheel  
RUN pip3 install setuptools==57.5.0
RUN pip3 install -r src/requirements.txt
    
# Create user 'odoo:odoo' which runs the server and is owner of the database (peer)
RUN useradd -m odoo
RUN printf "odoo\nodoo" | passwd odoo

# Copy entrypoint script and Odoo configuration file
RUN mkdir /docker/
COPY odoo.conf /etc/odoo/
COPY entrypoint.sh /
COPY scripts/docker/wait-for-psql.py /docker/
COPY scripts/docker/launch-server.py /docker/
COPY scripts/run-server.sh /
COPY scripts/kill-server.sh /




# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chmod a+x entrypoint.sh
RUN chown odoo /etc/odoo/odoo.conf 
RUN mkdir -p /mnt/extra-addons
RUN chown -R odoo /mnt/extra-addons
RUN chown -R odoo /src
RUN mkdir /var/lib/odoo/
RUN chown -R odoo /var/lib/odoo/
RUN chmod -R 777 /var/lib/odoo/sessions
RUN chmod a+x run-server.sh
RUN chmod a+x kill-server.sh


VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY /scripts/docker/wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY /scripts/docker/launch-server.py /usr/local/bin/launch-server.py

RUN echo "alias rs='bash /run-server.sh'" > /home/odoo/.bashrc


# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]