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


echolor y "Installation de Wordpress dans "$install_path
composer create-project roots/bedrock $install_path/tmpinstall

cd $install_path/tmpinstall
mv .[!.]* ../
mv * ../
cd ../
rm -rf $install_path/tmpinstall

gitignore

conffiles