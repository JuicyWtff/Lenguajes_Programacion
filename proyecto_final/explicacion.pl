:- module(explicacion, [
    ilegal_porque/5,
    explicar/4,
    explicar_estado/2
]).

:- use_module(tablero).
:- use_module(movimientos).
:- use_module(caminos).
:- use_module(legalidad).
:- use_module(estados).

ilegal_porque(Tablero, _, Origen, _, sin_pieza_en_origen(N)) :-
    \+ pieza_en_casilla(Tablero, Origen),
    nombre_casilla(Origen, N).

ilegal_porque(Tablero, Color, Origen, _, pieza_ajena(N, Otro)) :-
    color_en(Tablero, Origen, Otro),
    Otro \== Color,
    nombre_casilla(Origen, N).

ilegal_porque(_, _, _, C2-F2, fuera_del_tablero(C2-F2)) :-
    \+ dentro(C2, F2).

ilegal_porque(Tablero, Color, Origen, Destino, captura_propia(N)) :-
    color_en(Tablero, Origen, Color),
    color_en(Tablero, Destino, Color),
    nombre_casilla(Destino, N).

ilegal_porque(Tablero, Color, Origen, Destino, patron_invalido(Tipo)) :-
    pieza_en_color(Tablero, Origen, Color, Tipo),
    dentro_casilla(Destino),
    \+ color_en(Tablero, Destino, Color),
    \+ patron_cualquiera(Color, Tipo, Origen, Destino).

ilegal_porque(Tablero, Color, Origen, Destino, camino_bloqueado(N)) :-
    pieza_en_color(Tablero, Origen, Color, Tipo),
    patron_cualquiera(Color, Tipo, Origen, Destino),
    \+ color_en(Tablero, Destino, Color),
    casilla_intermedia_ocupada(Tablero, Origen, Destino, Casilla),
    nombre_casilla(Casilla, N).

ilegal_porque(Tablero, Color, Origen, Destino, deja_rey_en_jaque(NR, Atacante, NA)) :-
    pseudo_legal(Tablero, Color, Origen, Destino),
    aplicar(Tablero, Origen, Destino, Nuevo),
    casilla_rey(Nuevo, Color, CasillaRey),
    contrario(Color, Rival),
    pieza_en(Nuevo, C1, F1, pieza(Rival, Atacante, _, _)),
    ataca(Nuevo, C1-F1, CasillaRey),
    nombre_casilla(CasillaRey, NR),
    nombre_casilla(C1-F1, NA).

pieza_en_casilla(Tablero, C-F) :-
    pieza_en(Tablero, C, F, _).

pieza_en_color(Tablero, C-F, Color, Tipo) :-
    pieza_en(Tablero, C, F, pieza(Color, Tipo, _, _)).

dentro_casilla(C-F) :-
    dentro(C, F).

patron_cualquiera(Color, peon, Origen, Destino) :-
    ( patron_peon(Color, Origen, Destino, avance)
    ; patron_peon(Color, Origen, Destino, avance_doble)
    ; patron_peon(Color, Origen, Destino, captura)
    ).
patron_cualquiera(_, Tipo, Origen, Destino) :-
    Tipo \== peon,
    patron(Tipo, Origen, Destino).

casilla_intermedia_ocupada(Tablero, Origen, Destino, Casilla) :-
    alineadas(Origen, Destino),
    paso_unitario(Origen, Destino, DC-DF),
    Origen = C1-F1,
    C is C1 + DC,
    F is F1 + DF,
    buscar_bloqueo(Tablero, C-F, Destino, DC-DF, Casilla).

alineadas(C1-F1, C2-F2) :-
    ( C1 =:= C2
    ; F1 =:= F2
    ; abs(C2 - C1) =:= abs(F2 - F1)
    ).

buscar_bloqueo(Tablero, C-F, Destino, _, C-F) :-
    dentro(C, F),
    C-F \== Destino,
    ocupada(Tablero, C-F).
buscar_bloqueo(Tablero, C-F, Destino, DC-DF, Casilla) :-
    dentro(C, F),
    C-F \== Destino,
    \+ ocupada(Tablero, C-F),
    C2 is C + DC,
    F2 is F + DF,
    buscar_bloqueo(Tablero, C2-F2, Destino, DC-DF, Casilla).

explicar(Tablero, Color, Origen, Destino) :-
    legal(Tablero, Color, Origen, Destino),
    !,
    nombre_casilla(Origen, NO),
    nombre_casilla(Destino, ND),
    format("Movimiento ~w-~w: LEGAL~n", [NO, ND]).
explicar(Tablero, Color, Origen, Destino) :-
    nombre_casilla(Origen, NO),
    nombre_casilla(Destino, ND),
    format("Movimiento ~w-~w: ILEGAL~n", [NO, ND]),
    findall(R, ilegal_porque(Tablero, Color, Origen, Destino, R), Razones),
    imprimir_razones(Razones).

imprimir_razones([]) :-
    format("  Motivo no determinado.~n").
imprimir_razones([R | _]) :-
    texto_razon(R, Texto),
    format("  ~w~n", [Texto]).

texto_razon(sin_pieza_en_origen(N), Texto) :-
    format(atom(Texto), "No hay ninguna pieza en ~w.", [N]).
texto_razon(pieza_ajena(N, Otro), Texto) :-
    format(atom(Texto), "La pieza en ~w es ~w y no te corresponde moverla.", [N, Otro]).
texto_razon(fuera_del_tablero(C-F), Texto) :-
    format(atom(Texto), "La casilla destino (~w,~w) esta fuera del tablero.", [C, F]).
texto_razon(captura_propia(N), Texto) :-
    format(atom(Texto), "En ~w hay una pieza propia: no puedes capturarla.", [N]).
texto_razon(patron_invalido(Tipo), Texto) :-
    format(atom(Texto), "Un ~w no se mueve de esa forma.", [Tipo]).
texto_razon(camino_bloqueado(N), Texto) :-
    format(atom(Texto), "El camino esta bloqueado por la pieza en ~w.", [N]).
texto_razon(deja_rey_en_jaque(NR, Atacante, NA), Texto) :-
    format(atom(Texto),
           "Tu rey en ~w quedaria atacado por la ~w de ~w.",
           [NR, Atacante, NA]).

explicar_estado(Tablero, Color) :-
    estado(Tablero, Color, Estado),
    texto_estado(Estado, Color, Texto),
    format("~w~n", [Texto]).

texto_estado(jaque_mate, Color, Texto) :-
    format(atom(Texto), "JAQUE MATE: el bando ~w esta en jaque y no tiene jugadas legales.", [Color]).
texto_estado(ahogado, Color, Texto) :-
    format(atom(Texto), "AHOGADO: el bando ~w no tiene jugadas legales pero no esta en jaque.", [Color]).
texto_estado(jaque, Color, Texto) :-
    format(atom(Texto), "JAQUE: el rey ~w esta atacado pero tiene escapatoria.", [Color]).
texto_estado(normal, Color, Texto) :-
    format(atom(Texto), "Posicion normal para el bando ~w.", [Color]).