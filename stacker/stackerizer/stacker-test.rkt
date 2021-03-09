#lang s-exp "stacker.rkt"
;; this allows us to pass an s expression reader to racket -
;; we don't even have to define our own read-syntax function! we just need the expander.

;; the s-expression reader language is known as a 'module language'
;; - i assume becasue it could just as easily be declared as a racket module rather than an s expression language.
;; a 'custom module' for racket is just a language that has no custom reader - libraries are languages??
(+ 1 (* 2 3) 4)