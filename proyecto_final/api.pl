:- module(api, [
    dictamen/5,
    motivo_texto/5,
    destinos/4,
    estado_texto/4,
    casillas_clavadas/3,
    aplicar_movimiento/5
]).

:- use_module(tablero).
:- use_module(legalidad).
:- use_module(estados).
:- use_module(explicacion).

dictamen(Tablero, Color, Origen, Destino, legal) :-
    legal(Tablero, Color, Origen, Destino),
    !.
dictamen(Tablero, Color, Origen, Destino, ilegal(Texto)) :-
    motivo_texto(Tablero, Color, Origen, Destino, Texto).

motivo_texto(Tablero, Color, Origen, Destino, Texto) :-
    ilegal_porque(Tablero, Color, Origen, Destino, Razon),
    !,
    texto_razon(Razon, Texto).
motivo_texto(_, _, _, _, 'Movimiento no permitido.').

destinos(Tablero, Color, Origen, Lista) :-
    findall(Destino, legal(Tablero, Color, Origen, Destino), Lista).

estado_texto(Tablero, Color, Estado, Texto) :-
    estado(Tablero, Color, Estado),
    texto_estado(Estado, Color, Texto).

casillas_clavadas(Tablero, Color, Lista) :-
    findall(Casilla, clavada(Tablero, Color, Casilla), Lista).

aplicar_movimiento(Tablero, Color, Origen, Destino, Nuevo) :-
    legal(Tablero, Color, Origen, Destino),
    aplicar(Tablero, Origen, Destino, Nuevo).