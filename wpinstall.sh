#!/bin/bash

#####
dir=$1
install_path=$(pwd)/$dir

function gitignore () {
	echolor y "Mise en place du gitignore dans "$install_path
	cat << EOF > $install_path"/.gitignore"
*.log
wp-config.php
app/advanced-cache.php
app/backup-db/
app/backups/
app/blogs.dir/
app/cache/
app/upgrade/
app/uploads/
EOF
}

function conffiles () {
	echolor y "Mise en place des fichiers de configutations \"-at-preprod\" et \"-at-prod\" dans "$install_path
	cp $install_path"/.env.example" $install_path"/.env-at-preprod"
	cp $install_path"/.env.example" $install_path"/.env-at-prod"
	cp $install_path"/web/wp-config.php" $install_path"/web/wp-config.php-at-prod"
	cp $install_path"/web/wp-config.php" $install_path"/web/wp-config.php-at-prod"
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


echolor y "Installation de Wordpress dans "$install_path
composer create-project roots/bedrock $install_path

gitignore

conffiles