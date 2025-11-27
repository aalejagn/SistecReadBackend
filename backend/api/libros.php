<?php
require '../config/database.php';
require '../includes/cors.php';


if ($_SERVER['REQUEST_METHOD'] === 'GET') {
  $categoria = $_GET['cat'] ?? null;
  $sql = "SELECT * FROM libros";
  if ($categoria) $sql .= " WHERE categoria = :cat";
  $stmt = $pdo->prepare($sql);
  if ($categoria) $stmt->bindParam(':cat', $categoria);
  $stmt->execute();
  echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}
?>