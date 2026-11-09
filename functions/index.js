const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const nodemailer = require("nodemailer");

initializeApp();
const db = getFirestore();

// ─── Configuración del transportador de correo ────────────────────────────────
// Las credenciales se leen desde Firebase Secret Manager / environment config.
// Antes de desplegar, ejecuta:
//   firebase functions:secrets:set MAIL_USER
//   firebase functions:secrets:set MAIL_PASS
// O usa variables de entorno en el emulador poniendo en functions/.env:
//   MAIL_USER=tucorreo@gmail.com
//   MAIL_PASS=tu_app_password
function createTransport() {
  const user = (process.env.MAIL_USER || "").trim();
  const pass = (process.env.MAIL_PASS || "").trim().replace(/\s+/g, "");
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user,
      pass,
    },
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Genera un código numérico aleatorio de 4 dígitos como string. */
function generateCode() {
  return String(Math.floor(1000 + Math.random() * 9000));
}

/** Devuelve la fecha de expiración: ahora + 10 minutos. */
function expiresAt() {
  const d = new Date();
  d.setMinutes(d.getMinutes() + 10);
  return d;
}

// ─── Cloud Function: sendVerificationCode ────────────────────────────────────
/**
 * Genera un código de 4 dígitos, lo guarda en Firestore bajo
 * `verification_codes/{email}` y lo envía al correo del estudiante.
 *
 * Llamada desde Flutter:
 * ```dart
 * FirebaseFunctions.instance
 *   .httpsCallable('sendVerificationCode')
 *   .call({'email': 'nombre@udla.edu.co'});
 * ```
 */
exports.sendVerificationCode = onCall(async (request) => {
  const email = request.data?.email?.trim()?.toLowerCase();

  if (!email || !email.endsWith("@udla.edu.co")) {
    throw new HttpsError(
      "invalid-argument",
      "El correo debe ser un correo institucional (@udla.edu.co)."
    );
  }

  const code = generateCode();
  const expires = expiresAt();

  // Guarda / sobreescribe el código en Firestore.
  await db.collection("verification_codes").doc(email).set({
    code,
    expiresAt: expires,
    used: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  // Envía el correo si las credenciales están configuradas.
  const mailUser = (process.env.MAIL_USER || "").trim();
  const mailPass = (process.env.MAIL_PASS || "").trim().replace(/\s+/g, "");
  const isMailConfigured =
    mailUser.length > 0 &&
    mailUser !== "tucorreo@gmail.com" &&
    mailPass.length > 0 &&
    !mailPass.startsWith("xxxx");

  if (isMailConfigured) {
    try {
      const transporter = createTransport();
      await transporter.sendMail({
        from: `"ConfirmaU" <${mailUser}>`,
        to: email,
        subject: "Tu código de verificación – ConfirmaU",
        html: `
          <div style="font-family:sans-serif;max-width:480px;margin:auto">
            <h2 style="color:#0F7B4F">ConfirmaU</h2>
            <p>Hola, usa el siguiente código para completar tu registro:</p>
            <div style="font-size:40px;font-weight:bold;letter-spacing:12px;
                        color:#0F7B4F;text-align:center;padding:24px 0">
              ${code}
            </div>
            <p style="color:#6B7280;font-size:13px">
              Este código expira en <strong>10 minutos</strong>.<br>
              Si no solicitaste este código, ignora este mensaje.
            </p>
            <hr style="border:none;border-top:1px solid #E3E5E8">
            <p style="color:#9CA3AF;font-size:11px">
              Universidad de la Amazonia · ConfirmaU
            </p>
          </div>
        `,
      });
    } catch (mailError) {
      console.error("Error al enviar el correo con nodemailer:", mailError);
      throw new HttpsError(
        "internal",
        "Error al enviar el correo. Revisa las credenciales de Gmail en el servidor."
      );
    }
  } else {
    console.warn(
      `⚠️ [MODO DE PRUEBA] Credenciales de correo no configuradas en functions/.env.\n` +
      `Código de verificación para ${email}: >>> ${code} <<<\n` +
      `Para enviar correos reales, configura MAIL_USER y MAIL_PASS en functions/.env.`
    );
  }

  return { success: true };
});

// ─── Cloud Function: verifyCode ───────────────────────────────────────────────
/**
 * Verifica que el código de 4 dígitos enviado al correo sea correcto
 * y que no haya expirado ni sido utilizado.
 *
 * Llamada desde Flutter:
 * ```dart
 * FirebaseFunctions.instance
 *   .httpsCallable('verifyCode')
 *   .call({'email': 'nombre@udla.edu.co', 'code': '1234'});
 * ```
 */
exports.verifyCode = onCall(async (request) => {
  const email = request.data?.email?.trim()?.toLowerCase();
  const code = String(request.data?.code ?? "").trim();

  if (!email || !code) {
    throw new HttpsError("invalid-argument", "Email y código son requeridos.");
  }

  const docRef = db.collection("verification_codes").doc(email);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError(
      "not-found",
      "No se encontró un código para este correo. Solicita uno nuevo."
    );
  }

  const data = doc.data();

  if (data.used) {
    throw new HttpsError(
      "already-exists",
      "Este código ya fue utilizado. Solicita uno nuevo."
    );
  }

  if (new Date() > data.expiresAt.toDate()) {
    throw new HttpsError(
      "deadline-exceeded",
      "El código ha expirado. Solicita uno nuevo."
    );
  }

  if (data.code !== code) {
    throw new HttpsError("unauthenticated", "Código incorrecto.");
  }

  // Marca el código como usado.
  await docRef.update({ used: true });

  return { success: true };
});

// ─── Cloud Function: resetPasswordWithCode ───────────────────────────────────
/**
 * Valida el código de 4 dígitos enviado al correo y actualiza la contraseña
 * del usuario en Firebase Auth sin requerir sesión iniciada.
 */
exports.resetPasswordWithCode = onCall(async (request) => {
  const email = request.data?.email?.trim()?.toLowerCase();
  const code = String(request.data?.code ?? "").trim();
  const newPassword = String(request.data?.newPassword ?? "");

  if (!email || !code || !newPassword) {
    throw new HttpsError("invalid-argument", "Todos los campos son requeridos.");
  }

  if (newPassword.length < 8) {
    throw new HttpsError(
      "invalid-argument",
      "La contraseña debe tener al menos 8 caracteres."
    );
  }

  const docRef = db.collection("verification_codes").doc(email);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError(
      "not-found",
      "No se encontró un código para este correo. Solicita uno nuevo."
    );
  }

  const data = doc.data();

  if (data.used) {
    throw new HttpsError(
      "already-exists",
      "Este código ya fue utilizado. Solicita uno nuevo."
    );
  }

  if (new Date() > data.expiresAt.toDate()) {
    throw new HttpsError(
      "deadline-exceeded",
      "El código ha expirado. Solicita uno nuevo."
    );
  }

  if (data.code !== code) {
    throw new HttpsError("unauthenticated", "Código incorrecto.");
  }

  let userRecord;
  try {
    userRecord = await getAuth().getUserByEmail(email);
  } catch (err) {
    if (err.code === "auth/user-not-found") {
      throw new HttpsError(
        "not-found",
        "No existe una cuenta registrada con este correo institucional."
      );
    }
    throw new HttpsError("internal", "Error al verificar el usuario.");
  }

  try {
    await getAuth().updateUser(userRecord.uid, { password: newPassword });
  } catch (err) {
    console.error("Error al actualizar la contraseña:", err);
    throw new HttpsError(
      "internal",
      "No se pudo actualizar la contraseña. Intenta más tarde."
    );
  }

  await docRef.update({ used: true });

  return { success: true };
});

