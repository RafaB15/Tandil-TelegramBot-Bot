Telegram Bot Example
====================

1. Registrar un nuevo bot con el BotFather de Telegram

* En Telegram https://web.telegram.org/#/im?p=@BotFather
* Enviarle el comando `/newbot`
* Seguir los pasos y al final el BotFather responde con un token

2. Copiar el archivo `.env.example' a `.env` y reemplazar `<YOUR_TELEGRAM_TOKEN>` con el token del paso anterior

3. Correr los tests con `rake`

4. Levantar la app con `ruby `