# Wordpress installer

## Usage
```sh
wpinstall [subdirectory]
```

## Description
Installe la toute dernière version de Wordpress façon bedrock à l'endroit où est lancée la commande et met en place :

- un gitignore basique,
- les fichiers d'environnement wp-config.php-at-prep, wp-config.php-at-prod, .env-at-preprod, .env-at-prod.

## Installation

#### Linux/Bsd
```sh
curl -skL https://raw.githubusercontent.com/c2is/wpinstall/master/wpinstall.sh --output /usr/local/bin/wpinstall; chmod +x /usr/local/bin/wpinstall;
```

#### Windows Mingw
```sh
mkdir ~/bin/; curl -skL https://raw.githubusercontent.com/c2is/wpinstall/master/wpinstall.sh --output ~/bin/wpinstall; chmod +x ~/bin/wpinstall;
```

### Update

#### Linux/Bsd
```sh
curl -skL https://raw.githubusercontent.com/c2is/wpinstall/master/wpinstall.sh --output /usr/local/bin/wpinstall;
```

#### Windows Mingw
```sh
curl -skL https://raw.githubusercontent.com/c2is/wpinstall/master/wpinstall.sh --output ~/bin/wpinstall;
```