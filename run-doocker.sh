#! /bin/bash

fresh=0;
version=-1;

while getopts ":fc v:" option; do
   case $option in
      f) # fresh install
         echo "Will create fresh containers...";
         fresh=1;;
      v)
         version=$OPTARG
         echo "Using Odoo version ${version}";;
      c)
        sudo docker compose -f compose/doocker-latest.yml down --volumes;
        exit;;
      *)
         exit;;
   esac
done


if [ $fresh = 1 ]
then


  if [ $version = -1 ]
  then
    sudo docker compose -f compose/doocker-latest.yml down --volumes;
    sudo ARGS="-i base" docker compose -f compose/doocker-latest.yml up;
  else
    sudo docker compose -f compose/doocker-"${version}".yml down --volumes;
    sudo ARGS="-i base" docker compose -f compose/doocker-"${version}".yml up;
  fi

else

  if [ $version = -1 ]
  then
    sudo docker compose -f compose/doocker-17.yml up;
  else
    sudo docker compose -f compose/doocker-"${version}".yml up;
  fi

fi
