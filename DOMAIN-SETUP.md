# Puesta en producción con dominio propio

La web está preparada para migrar desde `https://juandzq.vercel.app` a un dominio propio sin dejar URLs antiguas en canonical, Open Graph, Twitter Cards, schema, robots o sitemap.

## Antes de comprar

- Compra el dominio a tu nombre y activa la renovación automática.
- Activa privacidad WHOIS si el registrador la incluye.
- Confirma que permita administrar registros DNS y exportar el código de transferencia.
- Conserva acceso al correo de la cuenta y activa autenticación en dos pasos.

## 1. Actualizar todas las señales SEO

Desde la raíz del proyecto, primero simula el cambio:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\set-domain.ps1 -Domain tudominio.com -WhatIf
```

Si el resultado es correcto, aplícalo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\set-domain.ps1 -Domain tudominio.com
```

El script solo toca los archivos que contienen URLs públicas del sitio. Después revisa los cambios con `git diff`.

## 2. Conectar el dominio en Vercel

1. Abre el proyecto **juan-diaz-interactive-portfolio** en Vercel.
2. En **Settings → Domains**, añade `tudominio.com` y `www.tudominio.com`.
3. Copia exactamente los registros DNS que Vercel muestre en el registrador. El dominio raíz suele usar un registro A y `www` un CNAME, pero los valores deben ser los que muestre Vercel en ese momento.
4. Define una sola versión como dominio principal. La recomendación para este portafolio es `tudominio.com` y una redirección permanente de `www.tudominio.com` hacia ella.
5. Espera a que Vercel muestre el dominio como válido y el certificado HTTPS como activo.

No elimines registros DNS de correo existentes (MX, SPF, DKIM o DMARC) si más adelante configuras una dirección profesional.

## 3. Publicar y verificar

Después del despliegue, comprueba que respondan con HTTPS:

- `https://tudominio.com/`
- `https://tudominio.com/desarrollador-web-colombia/`
- `https://tudominio.com/robots.txt`
- `https://tudominio.com/sitemap.xml`
- `https://tudominio.com/assets/desarrollador-web-colombia-juan-jose-diaz.jpg`

Comprueba también que `www` redirija al dominio principal y que el HTML publicado ya anuncie el dominio nuevo en canonical y metadatos sociales.

## 4. Google y Bing

1. Crea una propiedad de dominio en Google Search Console usando solo `tudominio.com`, sin `https://` ni rutas.
2. Añade el TXT de verificación que Google entregue en el DNS.
3. Envía `https://tudominio.com/sitemap.xml` y solicita indexación de la portada y la landing SEO.
4. Añade el sitio a Bing Webmaster Tools y vuelve a notificar las URLs mediante IndexNow con el dominio nuevo.

## 5. Revisión de lanzamiento

- Verificar que no queden referencias a `juandzq.vercel.app` en los archivos públicos.
- Probar la vista previa al compartir por WhatsApp, Instagram, LinkedIn y X.
- Confirmar el formulario y los enlaces de teléfono, Instagram y proyectos.
- Ejecutar Lighthouse en móvil y escritorio.
- Hacer commit y desplegar solo después de superar estas comprobaciones.
- Mantener la URL `vercel.app` funcionando como respaldo, pero con canonical apuntando al dominio propio.

## Correo profesional opcional

Una dirección como `hola@tudominio.com` aumenta la confianza. Puede configurarse después sin bloquear el lanzamiento del portafolio; antes de cambiar nameservers, guarda cualquier registro de correo existente.
