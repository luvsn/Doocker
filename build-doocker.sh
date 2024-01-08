#! /bin/bash

version=-1;

while getopts "v:" option; do
   case $option in
      v)
         version=$OPTARG
         echo "Building Odoo version ${version}";;
      *)
         exit;;
   esac
done

if [ $version = -1 ]
then
  echo "Please provide a version like: ./build-docker -v 16";
  exit;
fi

cd ./images/${version}
sudo docker build -t doocker:${version} .
