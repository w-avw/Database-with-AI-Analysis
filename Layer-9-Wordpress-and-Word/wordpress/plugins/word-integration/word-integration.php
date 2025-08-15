<?php
/**
 * Plugin Name: Word Integration
 * Description: A plugin to integrate Word document generation functionality into WordPress.
 * Version: 1.0
 * Author: Your Name
 */

// Exit if accessed directly
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

// Enqueue scripts and styles
function word_integration_enqueue_scripts() {
    wp_enqueue_script( 'word-integration-js', plugin_dir_url( __FILE__ ) . 'assets/js/main.js', array( 'jquery' ), '1.0', true );
    wp_enqueue_style( 'word-integration-css', plugin_dir_url( __FILE__ ) . 'assets/css/style.css' );
}
add_action( 'wp_enqueue_scripts', 'word_integration_enqueue_scripts' );

// Add a shortcode to display the control panel
function word_integration_control_panel() {
    ob_start();
    include plugin_dir_path( __FILE__ ) . 'templates/control-panel.php';
    return ob_get_clean();
}
add_shortcode( 'word_integration', 'word_integration_control_panel' );
?>