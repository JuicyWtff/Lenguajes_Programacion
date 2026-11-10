:- module(estados, [
    existe_jugada_legal/2,
    jaque_mate/2,
    ahogado/2,
    clavada/3,
    clavadas/2,
    estado/3
]).

:- use_module(tablero).
:- use_module(legalidad).

existe_jugada_legal(Tablero, Color) :-
    once(legal(Tablero, Color, _, _)).

jaque_mate(Tablero, Color) :-
    casilla_rey(Tablero, Color, _),
    en_jaque(Tablero, Color),
    \+ existe_jugada_legal(Tablero, Color).

ahogado(Tablero, Color) :-
    casilla_rey(Tablero, Color, _),
    \+ en_jaque(Tablero, Color),
    \+ existe_jugada_legal(Tablero, Color).

clavada(Tablero, Color, C-F) :-
    pieza_en(Tablero, C, F, pieza(Color, Tipo, _, _)),
    Tipo \== rey,
    once(pseudo_legal(Tablero, Color, C-F, _)),
    \+ legal(Tablero, Color, C-F, _).

clavadas(Tablero, Lista) :-
    findall(Color-Casilla,
            clavada(Tablero, Color, Casilla),
            Lista).

estado(Tablero, Color, jaque_mate) :-
    jaque_mate(Tablero, Color), !.
estado(Tablero, Color, ahogado) :-
    ahogado(Tablero, Color), !.
estado(Tablero, Color, jaque) :-
    en_jaque(Tablero, Color), !.
estado(_, _, normal).