:- module(puente, [
    c_mover/4,
    c_destinos/3,
    c_estado/2,
    c_clavadas/2
]).

:- use_module(tablero).
:- use_module(legalidad).
:- use_module(estados).
:- use_module(api).

c_mover(Tablero, Color, Origen, Destino) :-
    dictamen(Tablero, Color, Origen, Destino, Dictamen),
    (   Dictamen = legal
    ->  aplicar(Tablero, Origen, Destino, Nuevo),
        contrario(Color, Rival),
        estado_texto(Nuevo, Rival, Estado, TextoEstado),
        format("LEGAL|"),
        writeq(Nuevo),
        format("|~w|~w~n", [Estado, TextoEstado])
    ;   Dictamen = ilegal(Texto),
        format("ILEGAL|~w~n", [Texto])
    ).

c_destinos(Tablero, Color, Origen) :-
    destinos(Tablero, Color, Origen, Lista),
    format("DESTINOS|"),
    writeq(Lista),
    nl.

c_estado(Tablero, Color) :-
    estado_texto(Tablero, Color, Estado, Texto),
    format("ESTADO|~w|~w~n", [Estado, Texto]).

c_clavadas(Tablero, Color) :-
    casillas_clavadas(Tablero, Color, Lista),
    format("CLAVADAS|"),
    writeq(Lista),
    nl.