<?php include 'top.php';
?>

<main>
    <div class="schedule-page-container">
        <div class="season-container">
            <h2>Standings</h2>
            <p>Here are the results for the Professional Slugging League Tournament. Click on any of the table
                headers to sort by that column. Teams highlighted in red are winner's of that respective game.</p>
            <div class="choose-team regular-season">
                <table>
                    <thead>
                    <tr>
                        <th><a href="?sort=pfkTeamName">Team Name</a></th>
                        <th><a href="?sort=fldWins">Wins</a></th>
                        <th><a href="?sort=fldLoses">Loses</a></th>
                        <th><a href="?sort=fldRunsScored">Runs Scored</a></th>
                        <th><a href="?sort=fldRunsAgainst">Runs Against</a></th>
                        <th><a href="?sort=fldDifference">Difference</a></th>
                    </tr>
                    </thead>
                    <tbody>
                    <?php
                    // Define the SQL query
                    $sort = isset($_GET['sort']) ? $_GET['sort'] : 'fldWins';
                    $allowed_columns = ['pfkTeamName', 'fldWins', 'fldLoses', 'fldRunsScored', 'fldRunsAgainst', 'fldDifference'];
                    if (!in_array($sort, $allowed_columns)) {
                        $sort = 'fldWins';
                    }
                    $sql = "SELECT pfkTeamName, fldWins, fldLoses, fldRunsScored, ";
                    $sql .= "fldRunsAgainst, fldDifference FROM tblStandings ORDER BY $sort";

                    // Prepare and execute the query
                    $statement = $pdo->prepare($sql);
                    $statement->execute();

                    // Get the records from the result set
                    $records = $statement->fetchAll();
                    foreach ($records as $record) {
                        echo "<tr>";
                        echo "<td>" . $record['pfkTeamName'] . "</td>";
                        echo "<td>" . $record['fldWins'] . "</td>";
                        echo "<td>" . $record['fldLoses'] . "</td>";
                        echo "<td>" . $record['fldRunsScored'] . "</td>";
                        echo "<td>" . $record['fldRunsAgainst'] . "</td>";
                        echo "<td>" . $record['fldDifference'] . "</td>";
                        echo "</tr>";
                    }
                    ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<?php include 'footer.php'; ?>
