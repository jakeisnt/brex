#lang br/quicklang

;; it feels wrong to make the line number callable =
;; wouldn't it be a better solution to return a pair, then map over such pairs
;; to generate a hash table?
(define-macro (b-line NUM STATEMENT ...)
  ;; need source locations too! so add them again!
  (with-pattern ([LINE-NUM (prefix-id "line-" #'NUM #:source #'NUM)])
    ;; syntax/loc: #', or 'syntax', that preserves the source location for the syntax obj
    ;; 'caller-stx' - made available in define-macro as the input to the macro,
    ;;     before it's matched to the syntax pattern! available for free in the body!
    ;; don't like *at all* that this is just magic, but that's what a lot of this is to make it brief -
    ;; unclear whether it's better to explicitly deal with it every time instead. i think i would prefer
    ;; some sort of optional parameter syntax in the function signature that's able to bind it to a new name
    ;; that can be used in the body.
    (syntax/loc caller-stx (define (LINE-NUM) (void) STATEMENT ...))))

(define-macro (b-module-begin (b-program LINE ...))
  (with-pattern
      ;; further expands the macros - as they evaluate from the outside in.
      ;; this ensures they're also wrapped in LINE to insert them into the hash table?
      ([((b-line NUM STATEMENT ...) ...) #'(LINE ...)]
       [(LINE-FUNC ...) (prefix-id "line-" #'(NUM ...))])
    #'(#%module-begin
       LINE ...
       ;; hasheqv: immutable hash table (no mutation necc!) with eqv? comparator - works with numbers.
       (define line-table
         (apply hasheqv (append (list NUM LINE-FUNC) ...)))
       (void (run line-table)))))

;; mt
(struct end-program-signal ())
;; contains value of line to change to!
(struct change-line-signal (val))

;; use exceptions to implement goto and end!
;; end program signal terminates;
;; goto changes the line, then we catch it and use the result to go to the other line
;; these are pretty easy targets for playing with continuations : )
(define (b-end) (raise (end-program-signal)))
(define (b-goto expr) (raise (change-line-signal expr)))

(define (run line-table)
  (define line-vec
    ;; sort list in increasing order by hash keys of line table, then convert to vector
    (list->vector (sort (hash-keys line-table) <)))
  ;; if we get the  end program signal at any point, just die
  (with-handlers ([end-program-signal? (lambda (exn-val) void)])
    (for/fold ([line-idx 0]) ([i (in-naturals)])
      ;; break the loop when the line index is greater than the number of lines
      #:break (>= line-idx (vector-length line-vec))
      (define line-num (vector-ref line-vec line-idx))
      (define line-func (hash-ref line-table line-num))
      (with-handlers
          ([change-line-signal? (lambda (cls)
                                  (define clsv (change-line-signal-val cls))
                                  ;; if both and claises are true, the value of clsv in line-vec is produced
                                  ;; otherwise, the error is thrown!
                                  (or (and (exact-positive-integer? clsv)
                                           (vector-member clsv line-vec))
                                      (error (format "error in line ~a: line ~a not found"
                                                     line-num clsv))))])
        (line-func)
        (add1 line-idx)))))

(define (b-rem val) (void))
(define (b-print . vals)
  (displayln (string-append* (map ~a vals))))

(define (b-sum . nums) (apply + nums))
(define (b-expr expr)
  (if (integer? expr) (inexact->exact expr) expr))

;; love how powerful this is!
;; - gets all defined out as a parameter
;; - selects only the identifiers matching the given regex
(provide (matching-identifiers-out #rx"^b-" (all-defined-out)))

(provide (rename-out [b-module-begin #%module-begin]))
