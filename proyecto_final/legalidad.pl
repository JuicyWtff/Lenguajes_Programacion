:- module(legalidad, [
    ataca/3,
    movimiento_valido/5,
    pseudo_legal/4,
    aplicar/4,
    en_jaque/2,
    legal/4,
    jugadas_legales/3,
    sin_pieza_en/3,
    mover_pieza/4
]).

:- use_module(tablero).
:- use_module(movimientos).
:- use_module(caminos).

ataca(Tablero, C1-F1, Destino) :-
    pieza_en(Tablero, C1, F1, pieza(Color, peon, _, _)),
    patron_peon(Color, C1-F1, Destino, captura).
ataca(Tablero, C1-F1, Destino) :-
    pieza_en(Tablero, C1, F1, pieza(_, Tipo, _, _)),
    Tipo \== peon,
    patron(Tipo, C1-F1, Destino),
    camino_despejado(Tablero, Tipo, C1-F1, Destino).

movimiento_valido(Tablero, Color, peon, Origen, Destino) :-
    ( patron_peon(Color, Origen, Destino, avance)
    ; patron_peon(Color, Origen, Destino, avance_doble)
    ),
    \+ ocupada(Tablero, Destino),
    camino_libre(Tablero, Origen, Destino).
movimiento_valido(Tablero, Color, peon, Origen, Destino) :-
    patron_peon(Color, Origen, Destino, captura),
    color_en(Tablero, Destino, Otro),
    Otro \== Color.
movimiento_valido(Tablero, _, Tipo, Origen, Destino) :-
    Tipo \== peon,
    patron(Tipo, Origen, Destino),
    camino_despejado(Tablero, Tipo, Origen, Destino).

pseudo_legal(Tablero, Color, C1-F1, Destino) :-
    pieza_en(Tablero, C1, F1, pieza(Color, Tipo, _, _)),
    casilla(Destino),
    \+ color_en(Tablero, Destino, Color),
    movimiento_valido(Tablero, Color, Tipo, C1-F1, Destino).

sin_pieza_en([], _, []).
sin_pieza_en([pieza(_, _, C, F) | Resto], C-F, Limpio) :-
    sin_pieza_en(Resto, C-F, Limpio).
sin_pieza_en([pieza(Co, Ti, C1, F1) | Resto], C-F, [pieza(Co, Ti, C1, F1) | Limpio]) :-
    C1-F1 \== C-F,
    sin_pieza_en(Resto, C-F, Limpio).

mover_pieza([pieza(Co, Ti, C1, F1) | Resto], C1-F1, C2-F2, [pieza(Co, Ti, C2, F2) | Resto]).
mover_pieza([pieza(Co, Ti, C1, F1) | Resto], Origen, Destino, [pieza(Co, Ti, C1, F1) | Nuevo]) :-
    C1-F1 \== Origen,
    mover_pieza(Resto, Origen, Destino, Nuevo).

aplicar(Tablero, Origen, Destino, Nuevo) :-
    sin_pieza_en(Tablero, Destino, SinCaptura),
    mover_pieza(SinCaptura, Origen, Destino, Nuevo).

en_jaque(Tablero, Color) :-
    casilla_rey(Tablero, Color, CasillaRey),
    contrario(Color, Rival),
    pieza_en(Tablero, C1, F1, pieza(Rival, _, _, _)),
    ataca(Tablero, C1-F1, CasillaRey).

legal(Tablero, Color, Origen, Destino) :-
    pseudo_legal(Tablero, Color, Origen, Destino),
    aplicar(Tablero, Origen, Destino, Nuevo),
    \+ en_jaque(Nuevo, Color).

jugadas_legales(Tablero, Color, Jugadas) :-
    findall(mov(Origen, Destino), legal(Tablero, Color, Origen, Destino), Jugadas).