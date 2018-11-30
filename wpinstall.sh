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
	cp $install_path"/web/wp-config.php" $install_path"/web/wp-config.php-at-prod"
	cp $install_path"/web/wp-config.php" $install_path"/web/wp-config.php-at-prod"
}


echolor y "Installation de Wordpress dans "$install_path
composer create-project roots/bedrock $install_path/tmpinstall

cd $install_path/tmpinstall
mv .[!.]* ../
mv * ../
cd ../
rm -rf $install_path/tmpinstall

gitignore

conffiles

function dockerize () {

	netstat=$(netstat)
	if [ "$?" -ne 0 ]; 
		then 
			echolor y  "netstat n'est pas installé sur votre machine, il est vivement conseillé de l'installer"; 
	fi

	port="[0-9]"
	if [ -f docker-compose.yml ]; then

		read -p "Le fichier docker-compose.yml existe déjà, on l'écrase ? [y,N] " resp
		if [ $resp != "y" ]; then echo "Ok..."; return 0; fi
		echo "Arrêts des containers de cet environnement..."
		$sudo_opt docker-compose stop
	fi

	docker_compose_write

	ports_wanted=$(grep -A3 "ports" docker-compose.yml | grep "[0-9]" | cut -c12-25 | sed 's/"//' | cut -d':' -f1)

	for port in $ports_wanted; do
		if [ "$(is_used $port)" == "y" ]; then
			if [ "$port" == "80" ] || [ "$port" == "443" ]; then
				read -p "Voulez-vous stopper les containers des autres projets tournant sur le port 80 ? [y,N] " resp
		    	if [ $resp == "y" ]; then docker stop $(docker ps |grep ":80->" | cut -d " " -f1); fi
			fi
		fi

		if [ "$(is_used $port)" == "y" ]; then
			newport=$(get_next_free_port $port)
			echo $port" est occupé, on le remplace par : "$newport
			perl -pi -e "s/\"$port:/\"$newport:/" docker-compose.yml
		fi
	done

	read -p "Domaine pour le vhost (s'il se finit par dev.acti vous aurez un certificat ssl valide) : "$'\n' domain
	perl -pi -e "s/- WEBSITE_HOST=unprojet.dev.acti/- WEBSITE_HOST=$domain/" docker-compose.yml

	perl -pi -e "s/- CERTIFICAT_CNAME=unprojet.dev.acti/- CERTIFICAT_CNAME=$domain/" docker-compose.yml

	perl -pi -e "s/- maildomain=unprojet.dev.acti/- maildomain=$domain/" docker-compose.yml

	read -p "Voulez-vous ajouter la ligne \"127.0.0.1 $domain\" à votre fichier hosts ? [y,N] " resp
	if [ $resp != "y" ]; then 
		echo "Ok, ok, on touche pas au fichier hosts..."; 
	else
		host_file="/etc/hosts"
		(sudo echo "127.0.0.1 $domain" && sudo cat $host_file) > temp && sudo mv temp $host_file
	fi
	echo '""""""""""""""""'
	echo -e "Démarrage des containers...\n"
	$sudo_opt docker-compose up -d
	if [ "$?" -ne 0 ]; then return 0; fi


	if [ -d ./web/app/uploads]; 
	then
		docker-compose exec php chown -R www-data /var/www/website/web/app/uploads
	fi


	mysql_container=`basename $(pwd) | sed "s/_//g"`
	echo '""""""""""""""""'
	echolor g "Maintenant vous pouvez importer un dump mysql, par exemple :"
	echo ""
	echolor g "docker exec -i "$mysql_container"_db_1 mysql website < ./dump.sql"
}




function is_used() {
	if [ "$(uname)" == "Darwin" ]; then
		port_used=`$sudo_opt netstat -anv | awk 'NR>2{print $4}' | grep -E '\.'$port | sed 's/.*\.//' | sort -n | uniq`
	else
		port_used=`$sudo_opt netstat -lnt | awk 'NR>2{print $4}' | grep -E '0.0.0.0:$port' | sed 's/.*://' | sort -n | uniq`
	fi

	port=$1
	res="n"
	for i in ${port_used[@]}
	do
		if [ "$i" == ${port} ]; then
	    	res="y"; break;
	    fi
	done
	echo $res
}


function get_next_free_port() {
	port=$1

	#si le dernier chiffre est 0, on le retire
	if [ "${port:(${#port}-1):1}" == "0" ]; then
		port=$(echo $port | sed 's/.$//')
	fi
	limit="10000"
	counter=1
	while [  $counter -lt $limit ]; do
             newport=$port"$counter"
             if [ "$(is_used $newport)" == "n" ]; then
             	break;
             fi
             
        let counter=counter+1
    done

    echo $newport
	
}

function docker_compose_write () {
	cat << EOF > $install_path/docker-compose.yml
application:
    image: debian:stretch
    volumes:
        - ./:/var/www/website
    tty: true
db:
    image: mysql
    ports:
        - "3306:3306"
    environment:
        MYSQL_DATABASE: website
        MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
php:
    image: c2is/ubuntu-php
    volumes_from:
        - application
    links:
        - db
        - mail
composer:
    image: composer
    volumes_from:
        - application
    links:
        - db
apache:
    image: c2is/debian-apache
    environment:
        - WEBSITE_HOST=unprojet.dev.acti
        - CERTIFICAT_CNAME=unprojet.dev.acti
        - VHOST_SUFFIX=web
    ports:
        - "80:80"
        - "443:443"
    links:
        - php
    volumes_from:
        - application
mail:
    image: catatnight/postfix
    environment:
        - maildomain=unprojet.dev.acti
        - smtp_user=web:web
    ports:
        - "25"
EOF

}

dockerhere=$(docker)
if [ "$?" -ne 0 ]; 
	then 
		echolor y  "Docker n'est pas installé sur votre machine : ce script ne mettera pas en place l'environnement docker."; 
	else
		echolor y  "Docker est installé, mise en place de l'environnement docker du projet"; 
		dockerize
fi

: <<'COMMENT'
TODO

COMMENT



