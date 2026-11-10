:- module(caminos, [
    camino_libre/3,
    camino_despejado/4,
    paso_unitario/3
]).

:- use_module(tablero).

paso_unitario(C1-F1, C2-F2, DC-DF) :-
    DC is sign(C2 - C1),
    DF is sign(F2 - F1).

camino_libre(Tablero, Origen, Destino) :-
    paso_unitario(Origen, Destino, DC-DF),
    Origen = C1-F1,
    C is C1 + DC,
    F is F1 + DF,
    recorrer(Tablero, C-F, Destino, DC-DF).

recorrer(_, Casilla, Casilla, _).
recorrer(Tablero, C-F, Destino, DC-DF) :-
    dentro(C, F),
    C-F \== Destino,
    \+ ocupada(Tablero, C-F),
    C2 is C + DC,
    F2 is F + DF,
    recorrer(Tablero, C2-F2, Destino, DC-DF).

camino_despejado(_, caballo, _, _).
camino_despejado(_, rey, _, _).
camino_despejado(Tablero, torre, Origen, Destino) :-
    camino_libre(Tablero, Origen, Destino).
camino_despejado(Tablero, alfil, Origen, Destino) :-
    camino_libre(Tablero, Origen, Destino).
camino_despejado(Tablero, dama, Origen, Destino) :-
    camino_libre(Tablero, Origen, Destino).
camino_despejado(Tablero, peon, Origen, Destino) :-
    camino_libre(Tablero, Origen, Destino).