# Wordpress installer

## Usage
```sh
wpinstall [subdirectory]
```

Si subdirectory n'est pas indiqué, Worpress sera installé à la racine du répertoire courant.  
Si subdirectory est indiqué, ce sous-répertoire sera créé et Worpress sera installé dedans. 

## Description
Installe la toute dernière version de Wordpress dans un répertoire nommé "web" à l'endroit où est lancée la commande et met en place :

- un gitignore basique,
- les fichiers d'environnement wp-config.php-at-prep et wp-config.php-at-prod.

## Installation

#### Linux/Bsd
```sh
curl -skL https://raw.githubusercontent.com/c2is/wpinstall/oldschool/wpinstall.sh --output /usr/local/bin/wpinstall; chmod +x /usr/local/bin/wpinstall;
```

#### Windows Mingw
```sh
mkdir ~/bin/; curl -skL https://raw.githubusercontent.com/c2is/wpinstall/oldschool/wpinstall.sh --output ~/bin/wpinstall; chmod +x ~/bin/wpinstall;
```

### Update

#### Linux/Bsd
```sh
curl -skL https://raw.githubusercontent.com/c2is/wpinstall/oldschool/wpinstall.sh --output /usr/local/bin/wpinstall;
```

#### Windows Mingw
```sh
curl -skL https://raw.githubusercontent.com/c2is/wpinstall/oldschool/wpinstall.sh --output ~/bin/wpinstall;
```