# language: es
Característica: Aniadir contenido a favoritos
    
Background:
    Dado un usuario existente "pepito@gmail.com"

    @wip
    Escenario: US08 - 01 Como cinefilo quiero aniadir un contenido a favoritos
        Cuando el usuario aniade un contenido "Siempre" a favoritos
        Entonces ve un mensaje "Contenido aniadido a favoritos"

    @wip
    Escenario: US08 - 02 Contenido inexistente
        Dado que el contenido "Amor" no existe en la base de datos
        Cuando el usuario aniade un contenido "Amor" a favoritos
        Entonces ve un mensaje "Error: Contenido inexistente"

    @wip
    Escenario: US08 - 03 Dato faltante
        Cuando el usuario aniade un contenido "" a favoritos
        Entonces ve un mensaje "Error: Contenido faltante"
    
    