#! /bin/bash

cd /src/;

while getopts "icta u:" option; do
   case $option in
      i) # init db
         echo "Initializing database...";
         source /opt/venv/bin/activate;
         python3 odoo-bin -i base;
         exit;;
     
       u) # upgrade given module
         m=$OPTARG
         echo "Upgrading ${m}";
         source /opt/venv/bin/activate;
         python3 odoo-bin -u "${m}" --dev all;
         exit;;
       *)
         exit;;
   esac
done

source /opt/venv/bin/activate;
python3 odoo-bin --dev all;

