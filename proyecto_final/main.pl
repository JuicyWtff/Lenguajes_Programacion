:- use_module(tablero).
:- use_module(movimientos).
:- use_module(caminos).
:- use_module(legalidad).
:- use_module(estados).
:- use_module(explicacion).

simbolo(blanca, rey, 'R').
simbolo(blanca, dama, 'D').
simbolo(blanca, torre, 'T').
simbolo(blanca, alfil, 'A').
simbolo(blanca, caballo, 'C').
simbolo(blanca, peon, 'P').
simbolo(negra, rey, 'r').
simbolo(negra, dama, 'd').
simbolo(negra, torre, 't').
simbolo(negra, alfil, 'a').
simbolo(negra, caballo, 'c').
simbolo(negra, peon, 'p').

mostrar(Tablero) :-
    format("~n   a b c d e f g h~n"),
    forall(between(1, 8, I),
           ( F is 9 - I,
             format("~w  ", [F]),
             forall(between(1, 8, C), mostrar_casilla(Tablero, C, F)),
             format(" ~w~n", [F])
           )),
    format("   a b c d e f g h~n~n").

mostrar_casilla(Tablero, C, F) :-
    ( pieza_en(Tablero, C, F, pieza(Color, Tipo, _, _))
    -> simbolo(Color, Tipo, S),
       format("~w ", [S])
    ;  format(". ")
    ).

consultar(Tablero, Color, Origen, Destino) :-
    mostrar(Tablero),
    explicar(Tablero, Color, Origen, Destino),
    nl.

demo :-
    format("~n=== LogiChess ===~n"),

    format("~n--- Ejemplo 1: movimiento legal de torre ---~n"),
    posicion_inicial(T1),
    consultar(T1, negra, 5-8, 5-5),

    format("~n--- Ejemplo 2: movimiento que deja al rey en jaque ---~n"),
    posicion_clavada(T2),
    consultar(T2, blanca, 5-2, 7-3),

    format("~n--- Ejemplo 3: deteccion de clavada ---~n"),
    posicion_clavada(T3),
    clavadas(T3, Clavadas),
    format("Piezas clavadas: ~w~n", [Clavadas]),

    format("~n--- Ejemplo 4: jaque mate ---~n"),
    posicion_mate(T4),
    mostrar(T4),
    explicar_estado(T4, blanca),
    jugadas_legales(T4, blanca, J4),
    length(J4, N4),
    format("Jugadas legales de las blancas: ~w~n", [N4]),

    format("~n--- Ejemplo 5: ahogado ---~n"),
    posicion_ahogado(T5),
    mostrar(T5),
    explicar_estado(T5, negra),

    format("~n--- Ejemplo 6: jugadas legales de una pieza ---~n"),
    posicion_clavada(T6),
    mostrar(T6),
    findall(D, legal(T6, blanca, 5-1, D), Destinos),
    findall(N, (member(D2, Destinos), nombre_casilla(D2, N)), Nombres),
    format("El rey blanco de e1 puede ir a: ~w~n", [Nombres]),
    nl.