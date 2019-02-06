#!/bin/bash
if [ "$(uname)" != "Linux" ]; then rpath=`readlink "$0"`; else rpath=`readlink -f "$0"`; fi;
abs_path=$(dirname "$rpath")

dir=$1
install_path=$(pwd)/$dir

. $abs_path/helpers.sh

if [ "$dir" == "" ]; then
	read -p "Vous n'avez pas indiqué de répertoire d'installation, Wordpress sera installé ici : "$install_path", ok [Y,n] : " yn
	if [[ ! $yn =~ ^[Yy]$ ]]
	then
	    echo "Ok, ok... on arrête tout."
	    exit 1
	fi
else
		if [ -d $dir ] || [ -f $dir ]; then echo "Ce répertoire existe déjà, on arrête tout."; exit 1; fi
fi

if [ -d  $install_path/web ]; then echo "Un projet wordpress est déjà présent, on arrête tout."; exit 1; fi

mkdir -p $install_path;

setfacl=$(which setfacl)
if [ "$?" -eq 0 ];
	then 
		sudo setfacl -dR -m u:`whoami`:rwx .
fi

sudo_opt=""
read -p "Avez-vous besoin de sudo pour les commandes docker ? [Y,n] : " yn
if [[ $yn =~ ^[Yy]$ ]]
then
    sudo_opt="sudo"
fi

cd $install_path;

. $abs_path/install.sh
. $abs_path/childthemeinstall.sh
. $abs_path/docker.sh


