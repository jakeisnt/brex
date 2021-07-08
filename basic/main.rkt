#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(define (read-syntax path port)
  ;; make the parse tree with the parser!
  (define parse-tree (parse path (make-tokenizer port path)))
  ;; strip bindings from the tokenizer after expanding it!
  (strip-bindings
   ;; insert parse tree into module expression, but the expander itself does not need the bindings
   #`(module basic-mod basic/expander #,parse-tree)))

(define (get-info port src-mod src-line src-col src-pos)
  (define (handle-query key default)
    ;; if we're getting info for the colorere, use and call the colorer!
    ;; otherwise use whatever the default colorer is for the expression (though unlikely that this will ever be used)
    (case key
      [(color-lexer)
       (dynamic-require 'basic/colorer 'basic-colorer)]
      [else default]))
  handle-query)

(module+ reader
  (provide read-syntax get-info))
