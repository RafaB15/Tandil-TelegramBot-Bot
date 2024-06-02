# language: es
Característica: Calificar contenido
    
Background:
    Dado un usuario existente "pepito@gmail.com"

    @wip
    Escenario: US15 - 01 Como cinefilo quiero poder calificar contenido ya visto
        Dado que el usuario ya vio la pelicula "Nahir"
        Cuando califica la pelicula con un "4"
        Entonces ve un mensaje "Calificacion registrada exitosamente"

    @wip
    Escenario: US15 - 02 Como cinefilo quiero poder re-calificar contenido ya visto
        Dado que el usuario ya vio la pelicula "Nahir" y la habia calificado con un "5"
        Cuando califica la pelicula con un "3" se actualiza
        Y ve un mensaje "Calificacion registrada exitosamente"

    @wip
    Escenario: US15 - 03 No ingreso el valor de la calificacion
        Dado que el usuario ya vio la pelicula "Nahir"
        Cuando califica la pelicula con un ""
        Entonces ve un mensaje "Error al calificar: Calificacion faltante"


    @wip
    Escenario: US15 - 04 El contenido a calificar no existe
        Dado que el contenido "Ayer" no existe en la base de datos
        Cuando el usuario quiere calificar el contenido "Ayer"
        Entonces ve un mensaje "Error al calificar: El contenido a calificar no existe"

    @wip
    Escenario: US15 - 05 La calificacion esta fuera de rango
        Dado que el usuario ya vio la pelicula "Nahir"
        Cuando califica la pelicula con un "6"
        Entonces ve un mensaje "Error al calificar: Calificacion fuera de rango"

    @wip
    Escenario: US15 - 06 La pelicula no fue vista aun
        Dado que el usuario no vio la pelicula "Nahir"
        Cuando califica la pelicula con un "1"
        Entonces ve un mensaje "Error al calificar: Solo puedes calificar peliculas ya vistas"
