<?php
require '../config/database.php';
require '../includes/cors.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['error' => 'Método no permitido']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!$data || !isset($data['items']) || !is_array($data['items'])) {
    echo json_encode(['error' => 'Datos inválidos']);
    exit;
}

$items = $data['items'];
$usuario_id = $data['usuario_id'] ?? null;

// Datos de envío y pago (desde frontend)
$nombre = $data['nombre'] ?? '';
$email = $data['email'] ?? '';
$telefono = $data['telefono'] ?? '';
$cp = $data['cp'] ?? '';
$tipoEntrega = $data['tipoEntrega'] ?? '';
$direccion = $data['direccion'] ?? null;
$descripcionCasa = $data['descripcionCasa'] ?? null;
$ciudad = $data['ciudad'] ?? null;
$estado = $data['estado'] ?? null;
$metodoPago = $data['metodoPago'] ?? '';

// Validación básica
if (empty($nombre) || empty($email) || empty($telefono) || empty($cp) || empty($tipoEntrega) || empty($metodoPago)) {
    echo json_encode(['error' => 'Faltan datos obligatorios']);
    exit;
}

if ($tipoEntrega === 'domicilio' && (empty($direccion) || empty($ciudad) || empty($estado))) {
    echo json_encode(['error' => 'Faltan datos de dirección para domicilio']);
    exit;
}

$pdo->beginTransaction();

try {
    // Calcular total
    $total = array_reduce($items, function($sum, $item) {
        return $sum + ($item['precio'] * $item['cantidad']);
    }, 0);

    // Insertar venta principal
    $stmt = $pdo->prepare("
        INSERT INTO ventas 
        (usuario_id, total, nombre, email, telefono, cp, tipo_entrega, direccion, descripcion_casa, ciudad, estado, metodo_pago)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $usuario_id,
        $total,
        $nombre,
        $email,
        $telefono,
        $cp,
        $tipoEntrega,
        $direccion,
        $descripcionCasa,
        $ciudad,
        $estado,
        $metodoPago
    ]);
    $venta_id = $pdo->lastInsertId();

    // Insertar detalles y reducir stock
    foreach ($items as $item) {
        $libro_id = $item['id'];
        $cantidad = $item['cantidad'];
        $precio = $item['precio'];

        // Verificar stock
        $stmtStockCheck = $pdo->prepare("SELECT stock FROM libros WHERE id = ?");
        $stmtStockCheck->execute([$libro_id]);
        $stockActual = $stmtStockCheck->fetchColumn();

        if ($stockActual === false || $stockActual < $cantidad) {
            throw new Exception("Stock insuficiente para el libro ID: $libro_id");
        }

        // Insertar detalle
        $stmtDetalle = $pdo->prepare("
            INSERT INTO venta_detalles (venta_id, libro_id, cantidad, precio)
            VALUES (?, ?, ?, ?)
        ");
        $stmtDetalle->execute([$venta_id, $libro_id, $cantidad, $precio]);

        // Reducir stock
        $pdo->prepare("UPDATE libros SET stock = stock - ? WHERE id = ?")
            ->execute([$cantidad, $libro_id]);
    }

    $pdo->commit();

    // Respuesta
    $respuesta = ['success' => true, 'venta_id' => $venta_id];

    // Código Oxxo simulado
    if ($metodoPago === 'oxxo') {
        $codigoOxxo = 'OXXO-' . strtoupper(bin2hex(random_bytes(6)));  // Ej: OXXO-ABC123DEF456
        $respuesta['codigo_oxxo'] = $codigoOxxo;
        $respuesta['mensaje_oxxo'] = "Paga en Oxxo con código: $codigoOxxo (válido 48 hrs)";
    }

    echo json_encode($respuesta);

} catch (Exception $e) {
    $pdo->rollBack();
    echo json_encode(['error' => $e->getMessage()]);
}
?>