<?php
if($_POST["sessionToken"]) {
    $JSONData = "[";
    $conn = new mysqli("127.0.0.1", "root", "KohkiT0325/", "JOURNAL");
    $sql = "CALL GET_ENTRIES('" . $_POST["sessionToken"] . "');";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $JSONData .= "{" .
            "\"VALID\":" . $row["VALID"] . "," .
            "\"USERNAME\":\"" . $row["USERNAME"] . "\"," . 
            "\"ENTRY_TIME\":\"" . $row["ENTRY_TIME"] . "\"," . 
            "\"ENTRY_TEXT\":\"" . $row["ENTRY_TEXT"] . "\"" . 
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