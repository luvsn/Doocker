# Original files:
# https://github.com/odoo/docker/blob/master/15.0/Dockerfile
# https://github.com/veivaa/docker/blob/master/10.0/Dockerfile
# Adapted to match Odoo 10 requirements

FROM debian:buster-slim

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

#Copy equivs python-pypd file
COPY ./python-pypdf /

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl \
        dirmngr \
        npm \ 
        node-less \
        python-gevent \
        python-ldap \
        python-pip \
        python-qrcode \
        python-renderpm \
        python-vobject \
        python-watchdog \
        equivs\
        python3\
        python3-pip\
        python3-psycopg2\
        xz-utils

# Install fake python-pydf package necessary to complete the installation
RUN equivs-build python-pypdf\
    && dpkg -i ./python-pypdf_1.13_all.deb
    
# Setup pip packages
RUN pip install setuptools\
    && pip install pyPdf\
    && pip install psycopg2-binary

# Install python-imaging package
RUN curl -o python-imaging.deb http://archive.debian.org/debian-security/pool/updates/main//p/pillow/python-imaging_4.0.0-4+deb9u4_all.deb\
    && dpkg -i ./python-imaging.deb
    

# Install wkhtmltox package
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install latest Odoo build
RUN curl -o odoo.deb -sSL https://nightly.odoo.com/10.0/nightly/deb/odoo_10.0.latest_all.deb \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    #&&  dpkg --ignore-depends=python-imaging,python-pypdf -i odoo.deb\
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY entrypoint.sh /
COPY odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
