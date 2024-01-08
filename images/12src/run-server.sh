#! /bin/bash

cd /src/;

while getopts "icta u:" option; do
   case $option in
      i) # init db
         echo "Initializing database...";
         python3 odoo-bin -i base;
         exit;;
     
       u) # upgrade given module
         m=$OPTARG
         echo "Upgrading ${m}";
         python3 odoo-bin -u "${m}" --dev all;
         exit;;
       *)
         exit;;
   esac
done

python3 odoo-bin --dev all;

