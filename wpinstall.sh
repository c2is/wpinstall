#!/bin/bash
if [ "$(uname)" != "Linux" ]; then rpath=`readlink "$0"`; else rpath=`readlink -f "$0"`; fi;
abs_path=$(dirname "$rpath")

dir=$1
install_path=$(pwd)/$dir



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
		 color=$green
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


###########################
# INSTALL
###########################
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
web/app/advanced-cache.php
web/app/backup-db/
web/app/backups/
web/app/blogs.dir/
web/app/cache/
web/app/upgrade/
web/app/uploads/
web/app/plugins/*
!web/app/plugins/advanced-custom-fields-pro
!web/app/plugins/sitepress-multilingual-cms
!web/app/plugins/wpml-string-translation
!web/app/plugins/wpml-translation-management
web/app/themes/acti-starter-theme
web/wp/

# Composer
/vendor/
EOF
}

function conffiles () {
	echolor y "Mise en place des fichiers de configutations \"-at-preprod\" et \"-at-prod\" dans "$install_path
	cp $install_path"/.env.example" $install_path"/.env-at-preprod"
	cp $install_path"/.env.example" $install_path"/.env-at-prod"
}

echolor y "Installation de Wordpress dans "$install_path
composer create-project roots/bedrock $install_path/tmpinstall

cd $install_path/tmpinstall
mv .[!.]* ../
mv * ../
cd ../
rm -rf $install_path/tmpinstall

# Require plugins
composer require acti/acti-starter-theme:dev-master
composer require timber/timber
composer require tedivm/stash
composer require wpackagist-plugin/cookie-law-info
composer require wpackagist-plugin/kint-debugger
composer require wpackagist-plugin/autodescription
composer require wpackagist-plugin/breadcrumb-navxt


gitignore

conffiles
function childtheme ( ){
    childpath=$install_path/web/app/themes/$dir

    nicethemename="${dir//_/ }"
    nicethemename="${nicethemename^}"

    echolor y "Clone du thème enfant dans "$childpath

    # Clone the child theme from github
    git clone https://github.com/c2is/acti-starter-theme-child.git clonetmp
    cd clonetmp

    # Creation of the child theme directory
    mkdir $childpath

    # Move child theme folders and files from tmp to final directory
    mv * $childpath

    # Remove clonetmp
    cd ../
    rm -rf clonetmp

    cd $childpath

    # Generation of style.css's informations
    printf  "/**
 * $nicethemename
 * Theme Name: $nicethemename
 * Author: Acti
 * Description: $nicethemename theme.
 * Template: acti-starter-theme
 */"  > style.css

    cd $install_path

}

childtheme
#. $abs_path/docker.sh


