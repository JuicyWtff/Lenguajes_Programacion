#lang racket

(define red-inicial
  '(("ana" "beto" "carla")
    ("beto" "ana" "diego")
    ("carla" "ana" "diego" "elena")
    ("diego" "beto" "carla" "fer")
    ("elena" "carla")
    ("fer" "diego")
    ("gael")))

(define (nombre nodo) (car nodo))
(define (amigos-de nodo) (cdr nodo))

(define (buscar red persona)
  (cond [(null? red) #f]
        [(string=? (nombre (car red)) persona) (car red)]
        [else (buscar (cdr red) persona)]))

(define (existe? red persona)
  (if (buscar red persona) #t #f))

(define (amigos red persona)
  (let ([nodo (buscar red persona)])
    (if nodo (amigos-de nodo) '())))

(define (personas red) (map nombre red))

(define (son-amigos? red a b)
  (if (member b (amigos red a)) #t #f))

(define (agregar-a lista x)
  (if (member x lista) lista (append lista (list x))))

(define (quitar-de lista x)
  (filter (lambda (y) (not (string=? y x))) lista))

(define (actualizar red persona f)
  (map (lambda (nodo)
         (if (string=? (nombre nodo) persona)
             (cons (nombre nodo) (f (amigos-de nodo)))
             nodo))
       red))

(define (modificar-lazo operacion a b)
  (lambda (red) (actualizar red a (lambda (lista) (operacion lista b)))))

(define (conectar red a b)
  ((compose (modificar-lazo agregar-a b a) (modificar-lazo agregar-a a b)) red))

(define (desconectar red a b)
  ((compose (modificar-lazo quitar-de b a) (modificar-lazo quitar-de a b)) red))

(define (agregar-persona red persona)
  (append red (list (list persona))))

(define (sin-nodo persona)
  (lambda (red) (filter (lambda (nodo) (not (string=? (nombre nodo) persona))) red)))

(define (sin-referencias persona)
  (lambda (red) (map (lambda (nodo) (cons (nombre nodo) (quitar-de (amigos-de nodo) persona))) red)))

(define (eliminar-persona red persona)
  ((compose (sin-referencias persona) (sin-nodo persona)) red))

(define (amigos-de-amigos red persona)
  (append-map (lambda (amigo) (amigos red amigo)) (amigos red persona)))

(define (descartar-conocidos red persona)
  (lambda (lista)
    (filter (lambda (x) (and (not (string=? x persona))
                             (not (son-amigos? red persona x))))
            lista)))

(define (en-comun red a b)
  (length (filter (lambda (x) (member x (amigos red b))) (amigos red a))))

(define (ordenar-por-comun red persona)
  (lambda (lista) (sort lista > #:key (lambda (x) (en-comun red persona x)))))

(define (sugerencias-directas red persona)
  ((compose (ordenar-por-comun red persona)
            remove-duplicates
            (descartar-conocidos red persona))
   (amigos-de-amigos red persona)))

(define (sugerir red persona)
  (let ([directas (sugerencias-directas red persona)])
    (if (null? directas)
        ((descartar-conocidos red persona) (personas red))
        directas)))

(define normalizar (compose string-downcase string-trim))

(define (leer mensaje)
  (display mensaje)
  (flush-output)
  (let ([linea (read-line)])
    (if (eof-object? linea) "" (normalizar linea))))

(define (texto-amigos lista)
  (if (null? lista) "(sin amigos)" (string-join lista ", ")))

(define (mostrar-red red)
  (cond [(null? red) (void)]
        [else (printf "  ~a -> ~a\n" (nombre (car red)) (texto-amigos (amigos-de (car red))))
              (mostrar-red (cdr red))]))

(define (mostrar-sugerencias red persona lista i)
  (cond [(null? lista) (void)]
        [else (printf "  ~a. ~a (~a amigo(s) en común)\n" i (car lista) (en-comun red persona (car lista)))
              (mostrar-sugerencias red persona (cdr lista) (+ i 1))]))

(define (opcion-mostrar red)
  (displayln "\n--- Red de amigos ---")
  (mostrar-red red)
  red)

(define (pedir-conexiones red persona)
  (let ([amigo (leer "  ¿De quién es amigo? (Enter para terminar): ")])
    (cond [(string=? amigo "") red]
          [(string=? amigo persona)
           (displayln "  No puede ser amigo de sí mismo.")
           (pedir-conexiones red persona)]
          [(not (existe? red amigo))
           (displayln "  Esa persona no existe.")
           (pedir-conexiones red persona)]
          [(son-amigos? red persona amigo)
           (displayln "  Ya son amigos.")
           (pedir-conexiones red persona)]
          [else
           (printf "  ¡~a y ~a ahora son amigos!\n" persona amigo)
           (pedir-conexiones (conectar red persona amigo) persona)])))

(define (opcion-agregar red)
  (let ([persona (leer "Nombre de la nueva persona: ")])
    (cond [(string=? persona "")
           (displayln "El nombre no puede estar vacío.")
           red]
          [(existe? red persona)
           (displayln "Esa persona ya está en la red.")
           red]
          [else
           (printf "Personas en la red: ~a\n" (string-join (personas red) ", "))
           (pedir-conexiones (agregar-persona red persona) persona)])))

(define (elegir-sugerencia red persona lista)
  (let* ([entrada (leer "Número de la persona a agregar (Enter para no agregar): ")]
         [n (string->number entrada)])
    (cond [(string=? entrada "") red]
          [(and n (exact-positive-integer? n) (<= n (length lista)))
           (let ([nuevo (list-ref lista (- n 1))])
             (printf "¡~a y ~a ahora son amigos!\n" persona nuevo)
             (conectar red persona nuevo))]
          [else
           (displayln "Número no válido.")
           (elegir-sugerencia red persona lista)])))

(define (opcion-sugerir red)
  (let ([persona (leer "¿A quién le sugerimos amigos?: ")])
    (if (not (existe? red persona))
        (begin (displayln "Esa persona no existe.") red)
        (let ([lista (sugerir red persona)])
          (cond [(null? lista)
                 (displayln "No hay sugerencias: ya es amigo de todos.")
                 red]
                [else
                 (if (null? (sugerencias-directas red persona))
                     (displayln "No tiene amigos de amigos, estas son todas las personas de la red:")
                     (printf "Amigos de los amigos de ~a:\n" persona))
                 (mostrar-sugerencias red persona lista 1)
                 (elegir-sugerencia red persona lista)])))))

(define (opcion-romper red)
  (let ([a (leer "Primera persona: ")])
    (if (not (existe? red a))
        (begin (displayln "Esa persona no existe.") red)
        (begin
          (printf "Amigos de ~a: ~a\n" a (texto-amigos (amigos red a)))
          (let ([b (leer "¿Con quién rompe la amistad?: ")])
            (if (son-amigos? red a b)
                (begin (printf "~a y ~a ya no son amigos.\n" a b)
                       (desconectar red a b))
                (begin (displayln "Esas personas no son amigas.") red)))))))

(define (opcion-eliminar red)
  (let ([persona (leer "¿A quién se va a eliminar de la red?: ")])
    (if (existe? red persona)
        (begin (printf "~a fue eliminado(a) de la red.\n" persona)
               (eliminar-persona red persona))
        (begin (displayln "Esa persona no existe.") red))))

(define opciones
  (list (cons "1" opcion-mostrar)
        (cons "2" opcion-agregar)
        (cons "3" opcion-sugerir)
        (cons "4" opcion-romper)
        (cons "5" opcion-eliminar)))

(define (menu red)
  (displayln "\n========= RED DE AMIGOS =========")
  (displayln "1. Mostrar red")
  (displayln "2. Agregar persona")
  (displayln "3. Sugerir amigos")
  (displayln "4. Romper amistad")
  (displayln "5. Eliminar persona")
  (displayln "6. Salir")
  (let* ([opcion (leer "Elige una opción: ")]
         [accion (assoc opcion opciones)])
    (cond [(string=? opcion "6") (displayln "¡Hasta luego!")]
          [accion (menu ((cdr accion) red))]
          [else (displayln "Opción no válida.") (menu red)])))

(menu red-inicial)