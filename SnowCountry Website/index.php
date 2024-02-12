<?php include 'top.php'; ?>

<main>
    <div class="container">
        <h1>Mario Sluggers Tournament</h1>
        <div class="index-page-container">
            <div class="tournament-description">
                <p>A very exhilarating and serious tournament among friends. The game is
                Mario Sluggers. It is hosted at Dance Ct on the wii. This multi-week tournament
                is designed as if it were an actual sport with team drafts, a weekly schedule,
                standings, transactions, and a post season (playoffs & championship).</p>
            </div>
            <div class="teams">
                <h2>Teams</h2>
                <?php
                // Define the SQL query
                $sql = 'SELECT pmkTeamName, fldRound1, pfkTeamName, fldImageLink FROM tblTeams ';
                $sql .= 'JOIN tblImages ON pmkTeamName = pfkTeamName';

                // Prepare and execute the query
                $statement = $pdo->prepare($sql);
                $statement->execute();

                // Get the records from the result set
                $records = $statement->fetchAll();

                foreach($records as $record) {
                    echo "<div class='team-card'>";
                    echo "<h1 class='team-name'>" . $record['pmkTeamName'] . "</h1>";
                    echo "<div class='team-description'>";
                    print "<img class='captain-photo' alt='captain-photo' src='" . $record['fldImageLink'] . "'>";
                    echo "<div class='captain-description'>";
                    echo "<p class='captain'>Captain:</p>";
                    echo "<p class='captain-name'>" . $record['fldRound1'] . "</p>";
                    echo "</div>";
                    echo "</div>";
                    echo "</div>";
                }
                ?>
            </div>
        </div>
    </div>
</main>

<?php include 'footer.php'; ?>
