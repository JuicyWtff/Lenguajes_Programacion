:- module(movimientos, [
    patron/3,
    patron_peon/4,
    direccion/2,
    paso/3
]).

patron(torre, C1-F1, C2-F2) :-
    (C1 =:= C2 ; F1 =:= F2),
    \+ (C1 =:= C2, F1 =:= F2). %negacion por falla

patron(alfil, C1-F1, C2-F2) :-
    DC is abs(C2 - C1),
    DF is abs(F2 - F1),
    DC =:= DF,
    DC > 0.

patron(dama, Origen, Destino) :-
    patron(torre, Origen, Destino).
patron(dama, Origen, Destino) :-
    patron(alfil, Origen, Destino).

patron(caballo, C1-F1, C2-F2) :-
    DC is abs(C2 - C1),
    DF is abs(F2 - F1),
    ( DC =:= 1, DF =:= 2
    ; DC =:= 2, DF =:= 1
    ).

patron(rey, C1-F1, C2-F2) :-
    DC is abs(C2 - C1),
    DF is abs(F2 - F1),
    DC =< 1,
    DF =< 1,
    \+ (DC =:= 0, DF =:= 0).

patron_peon(blanca, C-F1, C-F2, avance) :-
    F2 is F1 + 1.
patron_peon(blanca, C-2, C-4, avance_doble).
patron_peon(blanca, C1-F1, C2-F2, captura) :-
    F2 is F1 + 1,
    DC is abs(C2 - C1),
    DC =:= 1.

patron_peon(negra, C-F1, C-F2, avance) :-
    F2 is F1 - 1.
patron_peon(negra, C-7, C-5, avance_doble).
patron_peon(negra, C1-F1, C2-F2, captura) :-
    F2 is F1 - 1,
    DC is abs(C2 - C1),
    DC =:= 1.

direccion(torre, 0-1).
direccion(torre, 0-(-1)).
direccion(torre, 1-0).
direccion(torre, (-1)-0).

direccion(alfil, 1-1).
direccion(alfil, 1-(-1)).
direccion(alfil, (-1)-1).
direccion(alfil, (-1)-(-1)).

direccion(dama, D) :- direccion(torre, D).
direccion(dama, D) :- direccion(alfil, D).

paso(C-F, DC-DF, C2-F2) :-
    C2 is C + DC,
    F2 is F + DF.