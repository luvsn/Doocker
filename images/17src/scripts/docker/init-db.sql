create user odoo with encrypted password 'odoo' login createdb;
create database odoodb owner odoo;
grant all on database odoodb to odoo;
