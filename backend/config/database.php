<?php

$host = "hopper.proxy.rlwy.net";
$port = 43445;
$dbname = "railway";
$username = "root";
$password = "ZKIgUggnEPvJlodDsQjjLjUWZkvxdwBs"; // la de Railway

try {
    $conn = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error de conexión: " . $e->getMessage());
}
?>
