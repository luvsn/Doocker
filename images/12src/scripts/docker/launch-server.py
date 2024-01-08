import os
import psycopg2
import logging

# Called by entrypoint.sh
# Checks whether a database exists before starting the server
# If not, let Odoo initialise it

_logger = logging.getLogger(__name__)

sql = None

try:
    sql = psycopg2.connect(
        host="postgres",
        port="5432",
        database="odoodb",
        user="odoo",
        password="odoo")

    cur = sql.cursor()
    
    cur.execute("SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_catalog='odoodb' AND table_schema='public' AND table_name='res_users');")
    res = cur.fetchone()
    cur.close()
    sql.close()
    if 'True' in str(res):
        os.system('python3 /src/odoo-bin --dev all')
    else:
        os.system('python3 /src/odoo-bin -i base')
        _logger.info('Database has been initialised.')

    _logger.info('Entrypoint terminated but container remains active.')
    os.system('tail -f /dev/null')
    
except (Exception, psycopg2.DatabaseError) as error:
    print(error)

