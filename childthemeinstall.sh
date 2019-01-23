function childtheme ( ){
    childpath=$install_path/web/app/themes/$dir

    echolor y "Mise du thème enfant dans "$childpath

    mkdir $childpath
    cd $childpath

    nicethemename="${dir//_/ }"
    nicethemename="${nicethemename^}"

    printf "/**
 * $nicethemename
 * Theme Name: $nicethemename
 * Author: Acti
 * Description: $nicethemename theme.
 * Template: acti-starter-theme
 */"  >> style.css


    # Theme root files
    touch frontpage.php
    touch 404.php
    touch index.php
    touch page.php
    touch search.php

    # Page templates
    mkdir page-templates

    # Assets
    mkdir assets

    # Functions
    mkdir functions
    cd functions
    printf "<?php

add_action('wp_enqueue_scripts', 'addOwnStyles');
add_action('wp_enqueue_scripts', 'addOwnScripts');

function addOwnStyles(){
    wp_enqueue_style( 'theme-styles', get_stylesheet_directory_uri() . '/assets/css/styles.css');
}

function addOwnScripts(){
    wp_enqueue_script('vendors', get_stylesheet_directory_uri() . '/assets/js/vendors.js', array(), false, true);
    wp_enqueue_script('script-front', get_stylesheet_directory_uri() . '/assets/js/scripts-front.js', array('vendors'), false, true);
}
" >> assets.php

    printf "<?php

add_filter('timber/context', 'addHeaderDataToContext');
add_filter('timber/context', 'addFooterDataToContext');

function addHeaderDataToContext(\$context)
{
    return \$context;
}

function addFooterDataToContext(\$context)
{
    return \$context;
}
" >> context.php

  printf "<?php

add_action('init', 'actiRegisterMenus');

function actiRegisterMenus()
{
    \$menus = array(
        'main-menu' => 'Menu Principal',
        'footer-menu' => 'Menu Footer'
    );

    register_nav_menus(\$menus);
}
" >> menus.php

  printf  "<?php
add_action('after_setup_theme', 'setThemeSupports');
function setThemeSupports()
{

    add_theme_support( 'title-tag' );
    add_theme_support( 'post-thumbnails' );
    add_theme_support( 'menus' );
}
" >> supports.php

  # Post Types
  mkdir post-types

  # Twig
  mkdir twig
  cd twig

  printf "<?php
add_filter('get_twig', 'addToTwig');

/** This is where you can add your own functions to twig.
 *
 * @param Twig_Environment \$twig get extension.
 * @return Twig_Environment \$twig
 */
function addToTwig(\$twig)
{
    // \$twig->addFunction(new Timber\Twig_Function('twig_fn_name', 'fn_name'));

    return \$twig;
}
" >> tools.php


  # Go back to theme root
  cd $childpath

  # Templates
  mkdir templates
  cd templates

  touch base.twig
  touch front-page.twig
  touch 404.twig
  touch page.twig
  touch search.twig

  mkdir page-templates


  # Go back to install path
  cd $install_path

}

childtheme