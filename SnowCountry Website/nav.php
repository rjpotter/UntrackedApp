<?php
// Get the current file name
$currentURL = $_SERVER['PHP_SELF'];
$pathParts = pathinfo($currentURL);

// Define the filename
$filename = $pathParts['filename'];
?>

<nav>
    <a class="<?php
    if ($pathParts['filename'] == "index") {
        print 'active-page';
    }
    ?>" href="index.php">Home</a>

    <a class="<?php
    if ($pathParts['filename'] == "schedule") {
        print 'active-page';
    }
    ?>" href="schedule.php">Schedule</a>

    <a class="<?php
    if ($pathParts['filename'] == "teams") {
        print 'active-page';
    }
    ?>" href="teams.php?team=Boogaloo&nbspBoys">Teams</a>

    <a class="<?php
    if ($pathParts['filename'] == "standings") {
        print 'active-page';
    }
    ?>" href="standings.php">Standings</a>

    <a class="<?php
    if ($pathParts['filename'] == "form") {
        print 'active-page';
    }
    ?>" href="form.php">Form</a>

    <a class="<?php
    if ($pathParts['filename'] == "adminForm") {
        print 'active-page';
    }
    ?>" href="admin/adminForm.php">Admin</a>
</nav>
