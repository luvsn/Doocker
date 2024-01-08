FROM debian:bookworm

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
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-dev \
        libpq-dev \
        gcc \
        g++ \
        libffi-dev \
        python3-venv \
        python3-psycopg2 \
        python3-pypdf2 \
        python3-werkzeug \
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
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb


# Download Odoo sources
RUN curl -o odoo.tar.xz -sSL https://nightly.odoo.com/16.0/nightly/deb/odoo_16.0.latest.tar.xz
RUN tar -xf odoo.tar.xz


# Copy requirements
COPY requirements.txt /src

# Create virtual environment
RUN python3 -m venv /opt/venv && chmod -R a+x /opt/venv

# Install Python dependencies (override original Odoo requirements.txt)
RUN . /opt/venv/bin/activate \
    && pip install wheel \
    && pip install setuptools \
    && pip install -r /src/requirements.txt
    
# Create user 'odoo:odoo' which runs the server and is owner of the database (peer)
RUN useradd -m odoo
RUN printf "odoo\nodoo" | passwd odoo

# Copy entrypoint script and Odoo configuration file
COPY odoo.conf /etc/odoo/
COPY entrypoint.sh /
COPY wait-for-psql.py /
COPY init.py /
COPY run-server.sh /
COPY kill-python.sh /




# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chmod a+x entrypoint.sh
RUN chown odoo /etc/odoo/odoo.conf 
RUN mkdir -p /mnt/extra-addons
RUN chown -R odoo /mnt/extra-addons
RUN chown -R odoo /src
RUN mkdir /var/lib/odoo/
RUN chown -R odoo /var/lib/odoo/
RUN chmod a+x run-server.sh
RUN chmod a+x kill-python.sh


VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY init.py /usr/local/bin/init.py

RUN echo "alias rs='bash /run-server.sh'" > /home/odoo/.bashrc


# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]