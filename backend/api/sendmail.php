<?php
// backend/api/sendmail.php → VERSIÓN PHPMailer QUE SÍ FUNCIONA EN INFINITYFREE 2025
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require '../../vendor/autoload.php';  // Asegúrate de tener la carpeta vendor subida (con PHPMailer instalado via composer)

function enviarCorreo($destinatario, $nombre, $asunto, $html)
{
    $mail = new PHPMailer(true);

    try {
        // Configuración SMTP de Gmail (2025 - con contraseña de app)
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'sistecreadservices@gmail.com';  // Tu email
        $mail->Password = 'jqai eipu cdlq ecah';  // Contraseña de app (verifica que sea válida)
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;

        // Remitente y destinatario
        $mail->setFrom('sistecreadservices@gmail.com', 'SISTEC READ');
        $mail->addAddress($destinatario, $nombre);

        // Contenido
        $mail->isHTML(true);
        $mail->CharSet = 'UTF-8';
        $mail->Subject = $asunto;
        $mail->Body = $html;
        $mail->AltBody = strip_tags($html);

        // Enviar
        $mail->send();
        error_log("✅ Correo enviado a: $destinatario");
        return true;

    } catch (Exception $e) {
        error_log("❌ ERROR al enviar: " . $mail->ErrorInfo . " - " . $e->getMessage());
        return false;
    }
}
?>