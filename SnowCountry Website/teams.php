<?php include 'top.php';
$selectedTeam = null;
?>

<main>
    <div class="teams-page-container">
        <div class="team-name-buttons">
            <?php
            // Define the SQL query
            $sql = 'SELECT pmkTeamName FROM tblTeams';
            $team = null;

            // Prepare and execute the query
            $statement = $pdo->prepare($sql);
            $statement->execute();

            // Get the records from the result set
            $records = $statement->fetchAll();
            foreach ($records as $record) {
                $team = $record['pmkTeamName'];
                print '<a href="teams.php?team=' . $team . '" class="team-link"><span class="team-button">' . $team . '</span></a>';
                print PHP_EOL;
            }
            ?>
        </div>
        <div class="team-box">
            <?php
                $selectedTeam = isset($_GET['team']) ? $_GET['team'] : 'Boogaloo Boys';
                $allowed_columns = ['Boogaloo Boys', 'Bowsers Batalion', 'DK\'s Fart Factory', 'Funky Shrooms',
                    'Luigi\'s Lake Monsters', 'Momma Mia Mario', 'Monkey Madness', 'Mother Sluggers'];
                if (!in_array($selectedTeam, $allowed_columns)) {
                    $selectedTeam = 'Boogaloo Boys';
                }

                // Define the SQL query
                $sql = 'SELECT pmkTeamName, fldDescription FROM tblTeams';
                $sql .= ' WHERE pmkTeamName = "' . $selectedTeam . '"';

                // Prepare and execute the query
                $statement = $pdo->prepare($sql);
                $statement->execute();
                // Get the records from the result set
                $records = $statement->fetchAll();
                foreach ($records as $record) {
            ?>
            <div class="team-box-2">
                   <?php echo '<h2>' . $record['pmkTeamName'] . '</h2>';?>
                <div class="team-page-description">
                    <h3>Team Description</h3>
                    <?php echo '<p>' . $record['fldDescription'] . '</p>'; }?>
                </div>
                <div class="team-game-history">
                    <h3>Game History</h3>
                    <div class="game-history-box">
                        <table>
                            <thead>
                            <tr>
                                <th>Opponent</th>
                                <th>Win / Loose</th>
                                <th>Score</th>
                            </tr>
                            </thead>
                            <tbody>
                            <?php
                            // Define the SQL query with a WHERE clause to filter by the selected team
                            $sql = 'SELECT pmkScheduleID, fldTeamHome, fldTeamAway, fldHomeScore, fldAwayScore FROM tblRegSeasonSchedule';
                            $selectedTeam = isset($_GET['team']) ? $_GET['team'] : 'Boogaloo Boys';
                            $allowed_columns = ['Boogaloo Boys', 'Bowsers Batalion', 'DK\'s Fart Factory', 'Funky Shrooms',
                                'Luigi\'s Lake Monsters', 'Momma Mia Mario', 'Monkey Madness', 'Mother Sluggers'];

                            if (!in_array($selectedTeam, $allowed_columns)) {
                                $selectedTeam = 'Boogaloo Boys';
                            }
                                $sql .= ' WHERE fldTeamHome = "' . $selectedTeam . '" OR fldTeamAway = "' . $selectedTeam . '"';

                            // Prepare and execute the query
                            $statement = $pdo->prepare($sql);
                            if ($selectedTeam != 'all') {
                                $statement = $pdo->prepare($sql);
                            }
                            $statement->execute();

                            // Get the records from the result set
                            $records = $statement->fetchAll();
                            foreach ($records as $record) {
                                echo $result = null;
                                echo $home = false;
                                echo '<tr>';
                                if ($record['fldTeamHome'] == $selectedTeam) {
                                    echo '<td>' . $record['fldTeamAway'] . '</td>';
                                } else {
                                    echo '<td>' . $record['fldTeamHome'] . '</td>';
                                }
                                if ($record['fldTeamHome'] == $selectedTeam) {
                                    if ($record['fldHomeScore'] >> $record['fldAwayScore']) {
                                        echo '<td>Win</td>';
                                        $result = 'win';
                                        $home = true;
                                    } else {
                                        echo '<td>Lose</td>';
                                        $result = 'lose';
                                        $home = true;
                                    }
                                } else {
                                    if ($record['fldHomeScore'] >> $record['fldAwayScore']) {
                                        echo '<td>Lose</td>';
                                        $result = 'lose';
                                    } else {
                                        echo '<td>Win</td>';
                                        $result = 'win';
                                    }
                                }
                                if ($home) {
                                    if ($result = 'win') {
                                        echo '<td>' . $record['fldHomeScore'] . ' - ' . $record['fldAwayScore'] . '</td>';
                                    }
                                    else {
                                        echo '<td>' . $record['fldAwayScore'] . ' - ' . $record['fldHomeScore'] . '</td>';
                                    }
                                }
                                else {
                                    if ($result = 'win') {
                                        echo '<td>' . $record['fldAwayScore'] . ' - ' . $record['fldHomeScore'] . '</td>';
                                    }
                                    else {
                                        echo '<td>' . $record['fldHomeScore'] . ' - ' . $record['fldAwayScore'] . '</td>';
                                    }
                                }
                                echo '</tr>';
                            }
                            ?>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="team-stats">
                    <h3>Statistics</h3>
                    <table>
                        <thead>
                        <tr>
                            <th>Wins</th>
                            <th>Loses</th>
                            <th>Runs Scored</th>
                            <th>Runs Against</th>
                            <th>Difference</th>
                        </tr>
                        </thead>
                        <tbody>
                        <?php
                        // Define the SQL query with a WHERE clause to filter by the selected team
                        $sql = 'SELECT pfkTeamName, fldWins, fldLoses, fldRunsScored, fldRunsAgainst FROM tblStandings';
                        $selectedTeam = isset($_GET['team']) ? $_GET['team'] : 'Boogaloo Boys';
                        $allowed_columns = ['Boogaloo Boys', 'Bowsers Batalion', 'DK\'s Fart Factory', 'Funky Shrooms',
                            'Luigi\'s Lake Monsters', 'Momma Mia Mario', 'Monkey Madness', 'Mother Sluggers'];

                        if (!in_array($selectedTeam, $allowed_columns)) {
                            $selectedTeam = 'Boogaloo Boys';
                        }
                        $sql .= ' WHERE pfkTeamName = "' . $selectedTeam . '"';

                        // Prepare and execute the query
                        $statement = $pdo->prepare($sql);
                        $statement->execute();

                        // Get the records from the result set
                        $records = $statement->fetchAll();
                        foreach ($records as $record) {
                            echo '<tr>';
                            echo '<td>' . $record['fldWins'] . '</td>';
                            echo '<td>' . $record['fldLoses'] . '</td>';
                            echo '<td>' . $record['fldRunsScored'] . '</td>';
                            echo '<td>' . $record['fldRunsAgainst'] . '</td>';
                            echo '<td>' . $record['fldRunsScored'] - $record['fldRunsAgainst'] . '</td>';
                            echo '</tr>';
                        }
                        ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="team-box-3">
                <h3>Roster</h3>
                <div class="team-roster">
                    <h3>Players</h3>
                    <div class="player stats">
                        <?php
                        // Define the SQL query with a WHERE clause to filter by the selected team
                        $sql = 'SELECT pmkPlayerName, fnkTeamName, fldPitching, fldBatting, fldFielding, fldRunning FROM tblPlayerStats';
                        $selectedTeam = isset($_GET['team']) ? $_GET['team'] : 'Boogaloo Boys';
                        $allowed_columns = ['Boogaloo Boys', 'Bowsers Batalion', 'DK\'s Fart Factory', 'Funky Shrooms',
                            'Luigi\'s Lake Monsters', 'Momma Mia Mario', 'Monkey Madness', 'Mother Sluggers'];

                        if (!in_array($selectedTeam, $allowed_columns)) {
                            $selectedTeam = 'Boogaloo Boys';
                        }
                        $sql .= ' WHERE fnkTeamName = "' . $selectedTeam . '"';

                        // Prepare and execute the query
                        $statement = $pdo->prepare($sql);
                        $statement->execute();

                        // Get the records from the result set
                        $records = $statement->fetchAll();
                        foreach ($records as $record) {
                            echo '<div class="player-item">';
                            echo '<h4 class="player-name">' . $record['pmkPlayerName'] . '</h4>';
                            echo '<p class="player-stat">Pitching: ' . $record['fldPitching'] . '</p>';
                            echo '<p class="player-stat">Batting: ' . $record['fldBatting'] . '</p>';
                            echo '<p class="player-stat">Fielding: ' . $record['fldFielding'] . '</p>';
                            echo '<p class="player-stat">Running: ' . $record['fldRunning'] . '</p>';
                            echo '</div>';
                        }
                        ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>


<?php include 'footer.php'; ?>
