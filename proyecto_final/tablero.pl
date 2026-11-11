:- module(tablero, [
    pieza_en/4,
    ocupada/2,
    color_en/3,
    dentro/2,
    casilla/1,
    contrario/2,
    casilla_rey/3,
    nombre_casilla/2,
    posicion_inicial/1,
    posicion_mate/1,
    posicion_ahogado/1,
    posicion_clavada/1,
    posicion_partida/1
]).

pieza_en([pieza(Color, Tipo, C, F) | _], C, F, pieza(Color, Tipo, C, F)). % que pieza hay en una casilla
pieza_en([_ | Resto], C, F, P) :-
    pieza_en(Resto, C, F, P).

ocupada(Tablero, C-F) :-       %Hay algo en esa casilla
    pieza_en(Tablero, C, F, _).

color_en(Tablero, C-F, Color) :- %Que color es la pieza
    pieza_en(Tablero, C, F, pieza(Color, _, _, _)).

dentro(C, F) :- %La casilla existe en el tablero?
    integer(C), integer(F),
    C >= 1, C =< 8,
    F >= 1, F =< 8.

casilla(C-F) :- %Genera las 64 casillas
    between(1, 8, C),
    between(1, 8, F).

contrario(blanca, negra). %Color opuesto
contrario(negra, blanca).

casilla_rey(Tablero, Color, C-F) :-  %Donde está el rey de cada color
    pieza_en(Tablero, C, F, pieza(Color, rey, _, _)).

nombre_casilla(C-F, Nombre) :- %Formato casilla
    nth1(C, [a,b,c,d,e,f,g,h], Letra),
    atom_number(NF, F),
    atom_concat(Letra, NF, Nombre).


%Posiciones precargadas
posicion_inicial([
    pieza(blanca, rey, 5, 1),
    pieza(negra, torre, 5, 8),
    pieza(negra, rey, 7, 8)
]).

posicion_mate([
    pieza(blanca, rey, 5, 1),
    pieza(negra, torre, 1, 1),
    pieza(negra, torre, 2, 2),
    pieza(negra, rey, 7, 8)
]).

posicion_ahogado([
    pieza(negra, rey, 8, 8),
    pieza(blanca, dama, 7, 6),
    pieza(blanca, rey, 5, 1)
]).

posicion_clavada([
    pieza(blanca, rey, 5, 1),
    pieza(blanca, caballo, 5, 2),
    pieza(negra, torre, 5, 8),
    pieza(negra, rey, 8, 8)
]).

posicion_partida([
    pieza(blanca, torre, 1, 1),
    pieza(blanca, caballo, 2, 1),
    pieza(blanca, alfil, 3, 1),
    pieza(blanca, dama, 4, 1),
    pieza(blanca, rey, 5, 1),
    pieza(blanca, alfil, 6, 1),
    pieza(blanca, caballo, 7, 1),
    pieza(blanca, torre, 8, 1),
    pieza(blanca, peon, 1, 2),
    pieza(blanca, peon, 2, 2),
    pieza(blanca, peon, 3, 2),
    pieza(blanca, peon, 4, 2),
    pieza(blanca, peon, 5, 2),
    pieza(blanca, peon, 6, 2),
    pieza(blanca, peon, 7, 2),
    pieza(blanca, peon, 8, 2),
    pieza(negra, peon, 1, 7),
    pieza(negra, peon, 2, 7),
    pieza(negra, peon, 3, 7),
    pieza(negra, peon, 4, 7),
    pieza(negra, peon, 5, 7),
    pieza(negra, peon, 6, 7),
    pieza(negra, peon, 7, 7),
    pieza(negra, peon, 8, 7),
    pieza(negra, torre, 1, 8),
    pieza(negra, caballo, 2, 8),
    pieza(negra, alfil, 3, 8),
    pieza(negra, dama, 4, 8),
    pieza(negra, rey, 5, 8),
    pieza(negra, alfil, 6, 8),
    pieza(negra, caballo, 7, 8),
    pieza(negra, torre, 8, 8)
]).