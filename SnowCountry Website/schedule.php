<?php include 'top.php';
$selectedTeam = null;
?>

    <main>
        <div class="schedule-page-container">
            <div class="season-container">
                <h2>Regular Season Schedule</h2>
                <p>Here are the schedule and results for the Professional Slugging League Tournament. Click on the filter drop
                    down to filter what team is displayed.</p>
                <div class="choose-team regular-season">
                    <form method="get">
                        <label for="team-select">Select a team:</label>
                            <div class="selectTeam">
                                <select id="team-select" name="team">
                                    <option value="all">All teams</option>
                                        <?php
                                        // Define the SQL query to fetch the team names
                                        $sql = 'SELECT pmkTeamName FROM tblTeams';

                                        // Prepare and execute the query
                                        $statement = $pdo->prepare($sql);
                                        $statement->execute();

                                        // Get the records from the result set
                                        $records = $statement->fetchAll();
                                        foreach ($records as $record) {
                                            echo '<option value="' . $record['pmkTeamName'] . '"';
                                            if (isset($_GET['team']) && $_GET['team'] == $record['pmkTeamName']) {
                                                echo ' selected';
                                            }
                                            echo '>' . $record['pmkTeamName'] . '</option>';
                                        }
                                        ?>
                                </select>
                                <button type="submit">Filter</button>
                            </div>
                        </form>


                    <table>
                        <thead>
                        <tr>
                            <th>Week</th>
                            <th>Home Team</th>
                            <th>Away Team</th>
                            <th>Date</th>
                        </tr>
                        </thead>
                        <tbody>
                            <?php
                            // Define the SQL query with a WHERE clause to filter by the selected team
                            $sql = 'SELECT pmkScheduleID, fldWeek, fldTeamHome, fldTeamAway, fldDate FROM tblRegSeasonSchedule';
                            $selectedTeam = isset($_GET['team']) ? $_GET['team'] : 'all';
                            $allowed_columns = ['Boogaloo Boys', 'Bowsers Batalion', 'DK\'s Fart Factory', 'Funky Shrooms',
                                'Luigi\'s Lake Monsters', 'Momma Mia Mario', 'Monkey Madness', 'Mother Sluggers'];

                            if (!in_array($selectedTeam, $allowed_columns)) {
                                $selectedTeam = 'all';
                            }
                            if ($selectedTeam != 'all') {
                                $sql .= ' WHERE fldTeamHome = "' . $selectedTeam . '" OR fldTeamAway = "' . $selectedTeam . '"';
                            }

                            // Prepare and execute the query
                            $statement = $pdo->prepare($sql);
                            if ($selectedTeam != 'all') {
                                $statement = $pdo->prepare($sql);
                            }
                            $statement->execute();

                            // Get the records from the result set
                            $records = $statement->fetchAll();
                            foreach ($records as $record) {
                                echo '<tr>';
                                echo '<td>' . $record['fldWeek'] . '</td>';
                                echo '<td>' . $record['fldTeamHome'] . '</td>';
                                echo '<td>' . $record['fldTeamAway'] . '</td>';
                                echo '<td>' . $record['fldDate'] . '</td>';
                                echo '</tr>';
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="season-container">
                <h2>Post Season Schedule</h2>
                <p>Here are the schedule and results for the Post Season / Playoffs & Championship of the Professional Slugging League Tournament.
                    Go to the select team dropdown menu at the top to filter what team is displayed.</p>
                <div class="choose-team post-season">
                    <table>
                        <thead>
                        <tr>
                            <th>Game Type</th>
                            <th>Home Team</th>
                            <th>Away Team</th>
                            <th>Date</th>
                        </tr>
                        </thead>
                        <tbody>
                            <?php
                            $sql = 'SELECT pmkPostSeasonID, fldGameType, fldHomeTeam, fldAwayTeam, fldPostDate ';
                            $sql .= 'FROM tblPostSeasonSchedule';
                            $sql .= " JOIN tblPostSeasonScores ON pmkPostSeasonID = pmkPostSeasonScoreID ";
                            if ($selectedTeam != 'all') {
                                $sql .= ' WHERE fldHomeTeam = "' . $selectedTeam . '" OR fldAwayTeam = "' . $selectedTeam . '"';
                            }

                            // Prepare and execute the query
                            $statement = $pdo->prepare($sql);
                            $statement->execute();
                            // Get the records from the result set
                            $records = $statement->fetchAll();
                            foreach ($records as $record) {
                                echo '<tr>';
                                echo '<td>' . $record['fldGameType'] . '</td>';
                                echo '<td>' . $record['fldHomeTeam'] . '</td>';
                                echo '<td>' . $record['fldAwayTeam'] . '</td>';
                                echo '<td>' . $record['fldPostDate'] . '</td>';
                                echo '</tr>';
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

<?php include 'footer.php'; ?>
