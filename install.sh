#!/bin/bash
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

gitignore

conffiles