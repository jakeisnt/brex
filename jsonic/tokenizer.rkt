#lang br/quicklang
(require brag/support racket/contract)

;; requires these dependencies only when this is run as part of the test module
(module+ test (require rackunit))

(define (make-tokenizer port)
  ;; side effect - turns on line and column counting!
  (port-count-lines! port)
  ;; must process every token, including eof, where we (prob) terminate
  (define (next-token)
    ;; contains series of branches, each representing lexing rule
    (define jsonic-lexer
      (lexer
       ;; ignore comments: with from/to targeting everything from first to next argument (comment to newline)
       [ (from/to "//" "\n") (next-token)]
       ;; everything between these two is valid Racket and should be interpreted as such
       [ (from/to "@$" "$@") (token 'SEXP-TOK (trim-ends "@$" lexeme "$@")
                                    ;; compensate for the trim by adding two to the position of the source location (asssume no newlines)
                                    #:position (+ (pos lexeme-start) 2)
                                    #:line (line lexeme-start)
                                    #:column (+ (col lexeme-start) 2)
                                    #:span (- (pos lexeme-end)
                                              (pos lexeme-start) 4))]
       ;; any other token is JSON; we throw it away?
       ;; no real need to handle eof, as lexer emits eof token for parser eof
       [any-char (token 'CHAR-TOK lexeme
                        ;; special object syntax to
                        ;; tag start position of the lexeme
                        #:position (pos lexeme-start)
                        ;; notate line pos
                        #:line (line lexeme-start)
                        ;; col
                        #:column (col lexeme-start)
                        ;; calc end of the character
                        #:span (- (pos lexeme-end) (pos lexeme-start)))]))
    (jsonic-lexer port))
  next-token)

;; run only when testing - not part of a final build!
(module+ test
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "// comment\n")
   empty)
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "@$ (+ 6 7) $@")
   ;; now we get source locations so we need to annotate them here!
   (list (token 'SEXP-TOK " (+ 6 7) "
                #:position 3
                #:line 1
                #:column 2
                #:span 9)))
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "hi")
   ;; #f s are unused for now
   (list (token 'CHAR-TOK "h"
                #:position 1
                #:line 1
                #:column 0
                #:span 1)
         (token 'CHAR-TOK "i"
                #:position 2
                #:line 1
                #:column 1
                #:span 1))))

;; we'd already written these things in the repl!
;; just had to formalize them as code : )

;; (input-port? . -> . procedure?)
;; define a custom contract recognizer here
(define (jsonic-token? x)
  (or (eof-object? x) (token-struct? x)))

;; no inputs needed so no infix
;; (input-port? . -> . (-> jsonic-token?))

(module+ test
  (check-true (jsonic-token? eof))
  (check-true (jsonic-token? (token 'A-TOKEN-STRUCT "hi")))
  (check-false (jsonic-token? 42)))

;; contracts run at runtime; a necessary performance cost
(provide
 (contract-out
  ;; make-tokenizer accepts an input port, producing a function, 'next-token',
  ;; that reads some information from the port (as captured by the closure) and produces a token
  [make-tokenizer (input-port? . -> . (-> jsonic-token?))]))

;; the contract operates at runtime, so we should ensure he incremental safety is worth the cost
;; eg read-syntax might not be worth it, as the arguments are passed by racket itself
