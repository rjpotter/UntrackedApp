<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Professional Slugging League</title>
    <meta name="author" content="Ryan Potter">
    <meta name="description" content="Professional Slugging League">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/x-icon" href="images/mario-favicon.png">

    <link rel="stylesheet" type="text/css"
          href="css/custom.css?version=<?php print time(); ?>">
    <link rel="stylesheet" type="text/css" media="(max-width: 800px)"
          href="css/mobile-custom.css?version=<?php print time(); ?>">
    <link rel="stylesheet" type="text/css" media="(max-width: 600px)"
          href="css/mobile-custom.css?version=<?php print time(); ?>">
</head>

<?php
print '<body>';
print PHP_EOL;
include 'connect-DB.php';
print PHP_EOL;
include 'header.php';
print PHP_EOL;
include 'nav.php';
print PHP_EOL;
?>
