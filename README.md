Telegram Bot Example
====================

1. Registrar un nuevo bot con el BotFather de Telegram

* En Telegram https://web.telegram.org/#/im?p=@BotFather
* Enviarle el comando `/newbot`
* Seguir los pasos y al final el BotFather responde con un token

2. Copiar el archivo `.env.example' a `.env` y reemplazar `<YOUR_TELEGRAM_TOKEN>` con el token del paso anterior

3. Correr los tests con `rake`

4. Levantar la app localmente con `ruby app.rb`

# Deploy a Heroku

1. Crear la app en heroku
2. Agregar el remote `heroku git:remote -a <app_name>`
3. Hacer deploy con `git push heroku master`
4. Ir a los settings y agregar una nueva variable de entorno `TELEGRAM_TOKEN` con el valor del token
5. Ir a los Dynos, editar los dynos y confirmar la activación (ver [imagen](https://www.dropbox.com/s/h2hqimu7pbsqrhj/Screenshot%202019-05-15%2021.38.07.png?dl=0))

# Testing

Los tests utilzan WebMock. Para testear el cliente, siempre usar `app.run_once` de lo contrario el bot se queda esperando mensajes y el test no finaliza nunca.

# Más información

Para utilizar otras funcionalidades de Telegram como los Keyboards especiales ver la doc en: https://github.com/atipugin/telegram-bot-ruby

 