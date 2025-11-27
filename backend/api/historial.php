<?php
require '../config/database.php';
require '../includes/cors.php';

header('Content-Type: application/json');

$usuario_id = $_GET['usuario_id'] ?? null;

if (!$usuario_id) {
    echo json_encode(['success' => false, 'error' => 'Falta usuario_id']);
    exit;
}

$stmt = $pdo->prepare("
    SELECT v.*, GROUP_CONCAT(CONCAT('{', 
        '\"id\":', d.libro_id, 
        ',\"titulo\":\"', COALESCE(l.titulo, 'Libro'), '\",',
        '\"precio\":', d.precio, 
        ',\"cantidad\":', d.cantidad, 
    '}') SEPARATOR ',') AS items
    FROM ventas v
    LEFT JOIN venta_detalles d ON v.id = d.venta_id
    LEFT JOIN libros l ON d.libro_id = l.id
    WHERE v.usuario_id = ?
    GROUP BY v.id
    ORDER BY v.creado_en DESC
");
$stmt->execute([$usuario_id]);
$ventas = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($ventas as &$venta) {
    $items = $venta['items'] ? json_decode('[' . $venta['items'] . ']', true) : [];
    $venta['items'] = json_encode($items);
}

echo json_encode(['success' => true, 'ventas' => $ventas]);
?>