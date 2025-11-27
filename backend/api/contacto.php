<?php
require '../config/database.php';
require '../includes/cors.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['error' => 'Método no permitido']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

$nombre = trim($data['nombre'] ?? '');
$email  = trim($data['email'] ?? '');
$asunto = trim($data['asunto'] ?? '');
$mensaje = trim($data['mensaje'] ?? '');

if (empty($nombre) || empty($email) || empty($asunto) || empty($mensaje)) {
    echo json_encode(['error' => 'Todos los campos son obligatorios']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['error' => 'Email inválido']);
    exit;
}

try {
    $sql = "INSERT INTO contactos (nombre, email, asunto, mensaje) VALUES (?, ?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$nombre, $email, $asunto, $mensaje]);

    echo json_encode(['success' => 'Mensaje enviado con éxito']);
} catch (Exception $e) {
    echo json_encode(['error' => 'Error en base de datos: ' . $e->getMessage()]);
}
?>
