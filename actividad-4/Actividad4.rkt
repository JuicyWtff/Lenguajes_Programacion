#lang racket 

(define (suma x y) (+ x y))

;(define (resta a b) (- a b))

(define (sucesor a) (+ a 1))

(define (cero x) 0)

(define (infinito) (+ 1 (infinito)))

(define (maximo x y) (if (> x y) x y))