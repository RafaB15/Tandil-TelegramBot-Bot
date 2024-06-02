# language: es
Característica: Consultar listas de contenidos
    
Background:
    Dado un usuario existente "pepito@gmail.com"

    @wip
    Escenario: US14 - 01 Como cinefilo quiero consultar lista de contenidos mas vistos
        Cuando el usuario consulta por la lista de contenidos mas vistos
        Entonces se ve una lista de los 3 contenidos mas vistos 
    
    Escenario: US14 - 02 Mas de 3 contenidos tuvieron la misma cantidad de visualizaciones maxima
        Dado que hay 4 contenidos con el maximo numero de vistas: "Atlas", "Beta", "Gamma", "Delta"
        Cuando el usuario consulta por la lista de contenidos mas vistos
        Entonces se ve una lista de los 3 contenidos más vistos, seleccionados alfabéticamente: "Atlas", "Beta", "Gamma"
    
    @wip
    Escenario: US14 - 03 Hay menos de 3 contenidos visualizados
        Dado que solo hay 2 contenidos que obtuvieron visualizaciones: "America", "China"
        Cuando el usuario consulta por la lista de contenidos mas vistos
        Entonces se ve una lista de 2 contenidos: "America", "China"

    @wip
    Escenario: US14 - 04 No hubo ninguna visualizacion
        Cuando el usuario consulta por la lista de contenidos mas vistos
        Entonces se ve un mensaje : "Ningun contenido fue visto aun"
        