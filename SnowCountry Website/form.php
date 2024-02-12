<?php
include 'top.php';

$dataIsGood = false;
$Message = '';

$firstName = '';
$lastName = '';
$email = '';

$Team = 'Mother Sluggers';

$favoriteMemory = getData('favorite_memory');
$favoriteMemory = htmlspecialchars($favoriteMemory);

function getData($field) {
    if (!isset($_POST[$field])) {
        $data = "";
    } else {
        $data = trim($_POST[$field]);
        $data = htmlspecialchars($data);
    }
    return $data;
}

function verifyAlphaNum($testString) {
    // Check for letters, numbers and dash, period, space and single quote only.
    // added & ; and # as a single quote sanitized with html entities will have
    return (preg_match ("/^([[:alnum:]]|-|\.| |\'|&|;|#)+$/", $testString));
}

?>

<main class="sluggersForm">
    <section class="formheader">
        <h2>Tell us your interests in Mario Sluggers</h2>
        <?php
        if($_SERVER["REQUEST_METHOD"] == 'POST') {
            // Sanitize Data
            $firstName = getData('txtFirstName');
            $lastName = getData('txtLastName');
            $email = getData('txtEmail');

            $Team = getData('radTeam');

            // validate form
            $dataIsGood = true;

            if($firstName == ""){
                print '<p class="mistake">Please type in your first name.</p>';
                $dataIsGood = false;
            }

            if($lastName == ""){
                print '<p class="mistake">Please type in your last name.</p>';
                $dataIsGood = false;
            }

            if($email == ""){
                print '<p class="mistake">Please type in your email address.</p>';
                $dataIsGood = false;
            } elseif(!filter_var($email, FILTER_VALIDATE_EMAIL)){
                print '<p class="mistake">Your email address contains invalid characters.</p>';
                $dataIsGood = false;
            }

            // Validate favorite team
            $validTeams = array("Boogaloo Boys", "Bowsers Batalion", "DK\'s Fart Factory", "Funky Shrooms", "Luigi\'s Lake Monsters", "Momma Mia Mario", "Monkey Madness", "Mother Sluggers");
            if (!in_array($Team, $validTeams)) {
                print '<p class="mistake">Please select your favorite team.</p>';
                $dataIsGood = false;
            }

            // Sanitize and validate text question
            if (empty($favoriteMemory)) {
                print '<p class="mistake">Please provide your favorite memory playing Mario Sluggers.</p>';
                $dataIsGood = false;
            }

            // save data
            if ($dataIsGood) {
                try {
                    $sql = 'INSERT INTO tblPSLForm (fldFirstName, fldLastName, fldEmail, fldTeam, fldFavoriteMemory)
                VALUES (?, ?, ?, ?, ?)';
                    $statement = $pdo->prepare($sql);
                    $data = array($firstName, $lastName, $email, $Team, $favoriteMemory);

                    if ($statement->execute($data)) {
                        $Message = '<h2>Thank you</h2>';
                        $Message .= '<p>Your information was successfully saved.</p>';

                        $to = $email;
                        $from = 'Ryan Potter <rjpotter@uvm.edu>';
                        $subject = 'CS 148 Professional Sluggers League';
                        $mailMessage = '<p style="font: 12pt Arial, sans-serif;">Thank you for filling out ';
                        $mailMessage .= 'our form.</p><p>Your info will definitely not go to the players heads as they gloat';
                        $mailMessage .= 'over winning this emotional roller coaster of a tournament<br>';
                        $mailMessage .= '<span style="color: #cc0000;">Professional Slugging League</span></p>';
                        $mailMessage .= $Message;

                        $headers = "MIME-Version: 1.0\r\n";
                        $headers .= "Content-type: text/html; charset=utf-8\r\n";
                        $headers .= "From: " . $from . "\r\n";

                        $mailSent = mail($to, $subject, $mailMessage, $headers);

                        if ($mailSent) {
                            print "<p>A copy of your form has been emailed to you.</p>";
                            print $mailMessage;
                        } else {
                            print "<p>Failed to send the email.</p>";
                        }
                    } else {
                        $Message = '<p>Record was NOT successfully saved.</p>';
                        $dataIsGood = false;
                    }
                } catch (PDOException $e) {
                    $Message = '<p>Couldn\'t insert the record, please contact someone</p>';
                    $dataIsGood = false;
                }
            }

        } // ends form submitted
        $Team = getData('radTeam');
    ?>

        <form action="#" id="frmPSLForm" method="post">
            <fieldset class="txt">
                <legend>Contact Information</legend>
                <p>
                    <label for="txtFirstName">First Name:</label>
                    <input type="text" name="txtFirstName" id="txtFirstName" placeholder="Jane" value="<?php echo $firstName; ?>">
                </p>
                <p>
                    <label for="txtLastName">Last Name:</label>
                    <input type="text" name="txtLastName" id="txtLastName" placeholder="Doe" value="<?php echo $lastName; ?>">
                </p>
                <p>
                    <label for="txtEmail">Email:</label>
                    <input type="email" name="txtEmail" id="txtEmail" placeholder="name@email.com" value="<?php echo $email; ?>" required>
                </p>
            </fieldset>

            <fieldset class="radio">
                <legend>Your Favorite Team Team</legend>
                <div>
                    <input type="radio" name="radTeam" value="Boogaloo Boys" id="radTeambooBoys" required checked<?php
                    if($Team == "Boogaloo Boys") print 'checked'; ?>>
                    <label for="radTeambooBoys">Boogaloo Boys</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="Bowsers Batalion" id="radTeambowBatalion" required <?php
                    if($Team == "Bowsers Batalion") print 'checked'; ?>>
                    <label for="radTeambowBatalion">Bowsers Batalion</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="DK\'s Fart Factory" id="radTeamdkFF" required <?php
                    if($Team == "DK's Fart Factory") print 'checked'; ?>>
                    <label for="radTeamdkFF">DK's Fart Factory</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="Funky Shrooms" id="radTeamfunkySh" required <?php
                    if($Team == "Funky Shrooms") print 'checked'; ?>>
                    <label for="radTeamfunkySh">Funky Shrooms</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="Luigi\'s Lake Monsters" id="radTeamLLM" required <?php
                    if($Team == "Luigi's Lake Monsters") print 'checked'; ?>>
                    <label for="radTeamLLM">Luigi's Lake Monsters</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="Momma Mia Mario" id="radTeamMMM" required <?php
                    if($Team == "Momma Mia Mario") print 'checked'; ?>>
                    <label for="radTeamMMM">Momma Mia Mario</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="Monkey Madness" id="radTeamMonkey" required <?php
                    if($Team == "Monkey Madness") print 'checked'; ?>>
                    <label for="radTeamMonkey">Monkey Madness</label>
                </div>
                <div>
                    <input type="radio" name="radTeam" value="Mother Sluggers" id="radTeamMSluggers" required <?php
                    if($Team == "Mother Sluggers") print 'checked'; ?>>
                    <label for="radTeamMSluggers">Mother Sluggers</label>
                </div>

            </fieldset>

            <fieldset class="text">
                <label for="favorite-memory">Favorite Memory Playing Mario Sluggers:</label>
                <input type="text" id="favorite-memory" name="favorite_memory" value="<?php echo isset($_POST['favorite_memory']) ? htmlspecialchars($_POST['favorite_memory']) : ''; ?>" required>
            </fieldset>

            <fieldset class="submit">
                <legend>Submit</legend>
                <p>
                    <input type="submit" name="btnSubmit" value="Submit">
                </p>
            </fieldset>
        </form>
    </section>
</main>

<?php
include 'footer.php';
?>