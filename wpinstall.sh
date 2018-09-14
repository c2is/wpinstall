#!/bin/bash

#####
dir=$1
install_path=$(pwd)/$dir"/web"

function gitignore () {
	echolor y "Mise en place du gitignore dans "$install_path
	cat << EOF > $install_path"/.gitignore"
# marmite
/.marmite

# OS or Editor folders
._*
.cache
.DS_Store
.idea
Thumbs.db
.tmp
nbproject

# Node
node_modules
npm-*.log

*.log
wp-config.php
wp-content/advanced-cache.php
wp-content/backup-db/
wp-content/backups/
wp-content/blogs.dir/
wp-content/cache/
wp-content/upgrade/
wp-content/uploads/
EOF
}

function conffiles () {
	echolor y "Mise en place des fichiers de configutations \"-at-preprod\" et \"-at-prod\" dans "$install_path
	cp $install_path"/wp-config-sample.php" $install_path"/wp-config.php-at-preprod"
	cp $install_path"/wp-config-sample.php" $install_path"/wp-config.php-at-prod"
}

function echolor () {
	red="\033[31m"
	green='\033[32m'
	yellow='\033[33m'
	std="\033[0m"
	case $1 in
		r)
		  color=$red
		  ;;
		g)
		 color=$green$
		  ;;
		y)
		  color=$yellow
		  ;;
		s)
		  color=$std
		  ;;

	esac

	echo -e $color$2$std
}

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


mkdir -p $install_path;
cd $install_path;


echolor y "Récupération de Wordpress dans "$install_path
curl -L http://wordpress.org/latest.tar.gz --output latest.tar.gz

echolor y "Décompression de Wordpress dans "$install_path
tar -zxf latest.tar.gz --strip 1
rm latest.tar.gz

gitignore

conffiles