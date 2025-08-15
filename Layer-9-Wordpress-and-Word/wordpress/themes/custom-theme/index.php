<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<?php echo get_stylesheet_uri(); ?>">
    <title><?php wp_title(); ?></title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    <div id="content">
        <h1><?php bloginfo('name'); ?></h1>
        <div id="controls">
            <button id="addBtn">Add Item</button>
            <button id="removeBtn">Remove Item</button>
            <button id="exportBtn">Export Word Doc</button>
        </div>
        <script src="<?php echo get_template_directory_uri(); ?>/assets/js/main.js"></script>
    </div>
    <?php wp_footer(); ?>
</body>
</html>