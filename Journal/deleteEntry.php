<?php
if($_POST["sessionToken"] && $_POST["username"] && $_POST["entryTime"]) {
    $JSONData = "[";
    $conn = new mysqli("127.0.0.1", "root", "KohkiT0325/", "JOURNAL");
    $_POST["username"] = str_replace("\"", "\\\\\"", str_replace("'", "''", $_POST["username"]));
    $_POST["entryTime"] = str_replace("\"", "\\\\\"", str_replace("'", "''", $_POST["entryTime"]));
    $sql = "CALL DELETE_ENTRY('" . $_POST["sessionToken"] . "', '" . $_POST["username"] . "', '" . $_POST["entryTime"] . "');";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $JSONData .= "{" .
            "\"VALID\":" . $row["VALID"] .
            "},";
        }
    }
    else {
        echo "{\"error\":true}";
        $conn->close();
        return;
    }
    $conn->close();
    $JSONData = substr($JSONData, 0, strlen($JSONData) - 1);
    $JSONData .= "]";
    echo $JSONData;
}
else {
    echo "{\"error\":true}";
}
?>         