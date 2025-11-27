<?php
// backend/api/auth.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require '../config/database.php';
require 'sendmail.php';

$data = json_decode(file_get_contents('php://input'), true);
$action = $data['action'] ?? '';

// Función auxiliar para cargar y renderizar templates
function renderTemplate($templateFile, $replacements)
{
    $templatePath = __DIR__ . '/templates/emails/' . $templateFile;
    if (!file_exists($templatePath)) {
        throw new Exception("Template no encontrado: " . $templatePath);
    }
    $html = file_get_contents($templatePath);
    foreach ($replacements as $key => $value) {
        $html = str_replace('{' . $key . '}', $value, $html);
    }
    return $html;
}

// ============== REGISTRO DE USUARIO ==============
if ($action === 'register') {
    $nombre = trim($data['nombre'] ?? '');
    $email = trim($data['email'] ?? '');
    $password = trim($data['password'] ?? '');

    // Validaciones (sin cambios)
    if (empty($nombre) || empty($email) || empty($password)) {
        echo json_encode(['error' => 'Todos los campos son requeridos']);
        exit;
    }

    if (strlen($nombre) < 2) {
        echo json_encode(['error' => 'El nombre debe tener al menos 2 caracteres']);
        exit;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['error' => 'Email inválido']);
        exit;
    }

    if (strlen($password) < 6) {
        echo json_encode(['error' => 'La contraseña debe tener al menos 6 caracteres']);
        exit;
    }

    try {
        // Verificar si el email ya existe (sin cambios)
        $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE email = ?");
        $stmt->execute([$email]);

        if ($stmt->fetch()) {
            echo json_encode(['error' => 'Este email ya está registrado']);
            exit;
        }

        // Hashear contraseña (sin cambios)
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

        // Insertar usuario (sin cambios)
        $stmt = $pdo->prepare("
            INSERT INTO usuarios (nombre, email, password, rol, creado_en) 
            VALUES (?, ?, ?, 'usuario', NOW())
        ");
        $stmt->execute([$nombre, $email, $hashedPassword]);

        // Obtener el ID del usuario recién creado (sin cambios)
        $userId = $pdo->lastInsertId();

        // ============== ENVIAR CORREO DE BIENVENIDA ==============
        $htmlBienvenida = renderTemplate('email_bienvenida.html', [
            'nombre' => $nombre,
            'email' => $email,
            'password' => $password
        ]);

        // Enviar correo de bienvenida (sin cambios)
        enviarCorreo($email, $nombre, '🎉 Bienvenido a SISTEC READ - Tus credenciales de acceso', $htmlBienvenida);

        // Iniciar sesión automáticamente (sin cambios)
        session_start();
        $_SESSION['user_id'] = $userId;
        $_SESSION['user_email'] = $email;
        $_SESSION['user_nombre'] = $nombre;
        $_SESSION['user_rol'] = 'usuario';

        echo json_encode([
            'success' => true,
            'message' => '✅ Cuenta creada exitosamente. Revisa tu correo para ver tus credenciales.',
            'user' => [
                'id' => $userId,
                'nombre' => $nombre,
                'email' => $email,
                'rol' => 'usuario'
            ]
        ]);

    } catch (Exception $e) {
        echo json_encode(['error' => 'Error al registrar usuario: ' . $e->getMessage()]);
    }
    exit;
}

// ============== FORGOT PASSWORD (Enviar token de recuperación) ==============
if ($action === 'forgot_password') {
    $email = trim($data['email'] ?? '');

    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['error' => 'Email inválido o requerido']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT id, nombre FROM usuarios WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user) {
            echo json_encode(['error' => 'No se encontró una cuenta con este email']);
            exit;
        }

        // Generar token de 6 dígitos
        $token = sprintf("%06d", mt_rand(0, 999999));
        $expires = date('Y-m-d H:i:s', strtotime('+1 hour'));

        // Guardar token en BD
        $upd = $pdo->prepare("UPDATE usuarios SET reset_token = ?, reset_expires = ? WHERE id = ?");
        $upd->execute([$token, $expires, $user['id']]);

        // Generar link de recuperación
        $link = "http://localhost:5173/recuperar-contraseña?token={$token}";

        // ============== ENVIAR CORREO DE RECUPERACIÓN ==============
        $htmlRecuperacion = renderTemplate('email_recuperacion.html', [
            'nombre' => $user['nombre'],
            'token' => $token,
            'link' => $link
        ]);

        // Enviar correo
        if (enviarCorreo($email, $user['nombre'], '🔒 Recuperar contraseña - SISTEC READ', $htmlRecuperacion)) {
            echo json_encode([
                'success' => true,
                'message' => '📧 Correo enviado exitosamente. Revisa tu bandeja de entrada.'
            ]);
        } else {
            echo json_encode([
                'error' => 'No se pudo enviar el correo. Verifica la configuración de SMTP.'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode(['error' => 'Error interno: ' . $e->getMessage()]);
    }
    exit;
}

// ============== RESTABLECER CONTRASEÑA (Cambiar password con token) ==============
if ($action === 'reset_password') {
    $token = trim($data['token'] ?? '');
    $password = trim($data['password'] ?? '');

    if (empty($token) || empty($password)) {
        echo json_encode(['error' => 'Faltan datos requeridos']);
        exit;
    }

    if (strlen($password) < 6) {
        echo json_encode(['error' => 'La contraseña debe tener al menos 6 caracteres']);
        exit;
    }

    try {
        // Buscar usuario con token válido y no expirado
        $stmt = $pdo->prepare("
            SELECT id, email, nombre 
            FROM usuarios 
            WHERE reset_token = ? 
            AND reset_expires > NOW()
        ");
        $stmt->execute([$token]);
        $user = $stmt->fetch();

        if (!$user) {
            echo json_encode(['error' => 'Token inválido o expirado. Solicita un nuevo enlace.']);
            exit;
        }

        // Hashear nueva contraseña
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

        // Actualizar contraseña y limpiar token
        $upd = $pdo->prepare("
            UPDATE usuarios 
            SET password = ?, reset_token = NULL, reset_expires = NULL 
            WHERE id = ?
        ");
        $upd->execute([$hashedPassword, $user['id']]);

        // ============== ENVIAR CONFIRMACIÓN DE CAMBIO ==============
        $htmlConfirmacion = renderTemplate('email_confirmacion.html', [
            'nombre' => $user['nombre']
        ]);

        // Enviar confirmación por correo
        enviarCorreo($user['email'], $user['nombre'], '✅ Contraseña actualizada - SISTEC READ', $htmlConfirmacion);

        echo json_encode([
            'success' => true,
            'message' => '✅ Contraseña actualizada correctamente. Redirigiendo al login...'
        ]);

    } catch (Exception $e) {
        echo json_encode(['error' => 'Error al cambiar contraseña: ' . $e->getMessage()]);
    }
    exit;
}

// ============== LOGIN ==============
if ($action === 'login') {
    $email = trim($data['email'] ?? '');
    $password = trim($data['password'] ?? '');

    if (empty($email) || empty($password)) {
        echo json_encode(['error' => 'Email y contraseña son requeridos']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password'])) {
            // Login exitoso
            session_start();
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['user_email'] = $user['email'];
            $_SESSION['user_nombre'] = $user['nombre'];
            $_SESSION['user_rol'] = $user['rol'];

            echo json_encode([
                'success' => true,
                'message' => 'Inicio de sesión exitoso',
                'user' => [
                    'id' => $user['id'],
                    'nombre' => $user['nombre'],
                    'email' => $user['email'],
                    'rol' => $user['rol']
                ]
            ]);
        } else {
            echo json_encode(['error' => 'Email o contraseña incorrectos']);
        }
    } catch (Exception $e) {
        echo json_encode(['error' => 'Error en login: ' . $e->getMessage()]);
    }
    exit;
}

// ============== RECUPERAR CONTRASEÑA (Enviar email con token) ==============
if ($action === 'forgot_password') {
    $email = trim($data['email'] ?? '');

    if (empty($email)) {
        echo json_encode(['error' => 'El email es requerido']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT id, nombre FROM usuarios WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user) {
            // Por seguridad siempre decimos que sí se envió
            echo json_encode([
                'success' => true,
                'message' => 'Si el correo existe, te enviamos un enlace de recuperación'
            ]);
            exit;
        }

        // Generar token único de 6 dígitos
        $token = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $expires = date("Y-m-d H:i:s", strtotime('+1 hour'));

        // Guardar token en la base de datos
        $upd = $pdo->prepare("UPDATE usuarios SET reset_token = ?, reset_expires = ? WHERE id = ?");
        $upd->execute([$token, $expires, $user['id']]);

        // Crear enlace de recuperación
        $link = "http://localhost:5173/recuperar-contraseña?token=$token";

        // ============== ENVIAR CORREO DE RECUPERACIÓN ==============
        $htmlRecuperacion = renderTemplate('email_recuperacion.html', [
            'nombre' => $user['nombre'],
            'token' => $token,
            'link' => $link
        ]);
        enviarCorreo($email, $user['nombre'], 'Recuperar contraseña - SISTEC READ', $htmlRecuperacion);

        // Enviar correo
        if (enviarCorreo($email, $user['nombre'], '🔒 Recuperar contraseña - SISTEC READ', $htmlRecuperacion)) {
            echo json_encode([
                'success' => true,
                'message' => '📧 Correo enviado exitosamente. Revisa tu bandeja de entrada.'
            ]);
        } else {
            echo json_encode([
                'error' => 'No se pudo enviar el correo. Verifica la configuración de SMTP.'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode(['error' => 'Error interno: ' . $e->getMessage()]);
    }
    exit;
}

// ============== RESTABLECER CONTRASEÑA (Cambiar password con token) ==============
if ($action === 'reset_password') {
    $token = trim($data['token'] ?? '');
    $password = trim($data['password'] ?? '');

    if (empty($token) || empty($password)) {
        echo json_encode(['error' => 'Faltan datos requeridos']);
        exit;
    }

    if (strlen($password) < 6) {
        echo json_encode(['error' => 'La contraseña debe tener al menos 6 caracteres']);
        exit;
    }

    try {
        // Buscar usuario con token válido y no expirado
        $stmt = $pdo->prepare("
            SELECT id, email, nombre 
            FROM usuarios 
            WHERE reset_token = ? 
            AND reset_expires > NOW()
        ");
        $stmt->execute([$token]);
        $user = $stmt->fetch();

        if (!$user) {
            echo json_encode(['error' => 'Token inválido o expirado. Solicita un nuevo enlace.']);
            exit;
        }

        // Hashear nueva contraseña
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

        // Actualizar contraseña y limpiar token
        $upd = $pdo->prepare("
            UPDATE usuarios 
            SET password = ?, reset_token = NULL, reset_expires = NULL 
            WHERE id = ?
        ");
        $upd->execute([$hashedPassword, $user['id']]);

// ============== ENVIAR CONFIRMACIÓN DE CAMBIO ==============
        $htmlConfirmacion = renderTemplate('email_confirmacion.html', [
            'nombre' => $user['nombre']
        ]);
        enviarCorreo($user['email'], $user['nombre'], 'Contraseña actualizada - SISTEC READ', $htmlConfirmacion);

        // Enviar confirmación por correo
        enviarCorreo($user['email'], $user['nombre'], '✅ Contraseña actualizada - SISTEC READ', $htmlConfirmacion);

        echo json_encode([
            'success' => true,
            'message' => '✅ Contraseña actualizada correctamente. Redirigiendo al login...'
        ]);

    } catch (Exception $e) {
        echo json_encode(['error' => 'Error al cambiar contraseña: ' . $e->getMessage()]);
    }
    exit;
}

// ============== LOGOUT ==============
if ($action === 'logout') {
    session_start();
    session_destroy();
    echo json_encode(['success' => true, 'message' => 'Sesión cerrada']);
    exit;
}

// ============== VERIFICAR SESIÓN ==============
if ($action === 'check_session') {
    session_start();
    if (isset($_SESSION['user_id'])) {
        echo json_encode([
            'success' => true,
            'user' => [
                'id' => $_SESSION['user_id'],
                'nombre' => $_SESSION['user_nombre'],
                'email' => $_SESSION['user_email'],
                'rol' => $_SESSION['user_rol']
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No hay sesión activa']);
    }
    exit;
}

// Si no hay acción válida
echo json_encode(['error' => 'Acción no válida']);
?>