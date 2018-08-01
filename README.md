# Wordpress installer

## Usage
```sh
wpinstall [subdirectory]
```

## Description
Installe la toute dernière version de Wordpress à l'endroit où est lancée la commande wpinstall et met en place :

- un gitignore basique,
- les fichiers d'environnement wp-config.php-at-prep et wp-config.php-at-prod.

## Installation

#### Linux/Bsd
```sh
curl -skL https://github.com/c2is/wpinstall/raw/master/wpinstall.sh --output /usr/local/bin/wpinstall; chmod +x /usr/local/bin/wpinstall;
```

#### Windows Mingw
```sh
mkdir ~/bin/; curl -skL https://github.com/c2is/wpinstall/raw/master/wpinstall.sh --output ~/bin/wpinstall; chmod +x ~/bin/wpinstall
```

### Update

#### Linux/Bsd
```sh
curl -skL https://github.com/c2is/wpinstall/raw/master/wpinstall.sh --output /usr/local/bin/wpinstall;
```

#### Windows Mingw
```sh
curl -skL https://github.com/c2is/wpinstall/raw/master/wpinstall.sh --output ~/bin/wpinstall;
```