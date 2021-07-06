#lang br
(require "lexer.rkt" brag/support)

(define (make-tokenizer ip [path #f])
  ;; count all the lines on the port
  (port-count-lines! ip)
  ;; configure the file path to thefile we're lexing, if the path is provided by the reader
  ;; may not always want to use a path, so providedefault argument
  ;;
  ;; parameter: racket value that approximates global variable - but is a function that stores and retreives it instead
  ;; therefore, other functions can call lexer file path without an argument and retrieve the variable, and it can be set globally!
  (lexer-file-path path)
  ;; getting the next token is just applying our lexer to input port!
   (define (next-token) (basic-lexer ip))
   next-token)

(provide make-tokenizer)
