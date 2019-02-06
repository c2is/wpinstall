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