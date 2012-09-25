;; This is a new version of pmatch (August 8, 2012), called dmatch.
;; It is named for Dijkstra's Guarded Commands.  How dmatch differs
;; from pmatch is with more emphasis on error reporting and a simpler
;; specification of patterns.  This version of the matcher will show all
;; clauses where the pattern matches and the guards succeed if there are
;; two or more such clauses.  We allow for a name to be given to
;; dmatch if an error ensues.  Also, a line from the specification has
;; been removed. (see below).  Without that line removed, it was
;; impossible for a pattern to be (quote ,x), which might be worth
;; having especially when one writes an interpreter for Scheme, which
;; includes quote as a language form.

;;; Original Code written by Oleg Kiselyov (http://pobox.com/~oleg/ftp/)
;;; Taken from leanTAP.scm
;;; http://kanren.cvs.sourceforge.net/kanren/kanren/mini/leanTAP.scm?view=log

; A simple linear pattern matcher
; It is efficient (generates code at macro-expansion time) and simple:
; it should work on any R5RS (and R6RS) Scheme system.

; (pmatch exp <clause> ...) |
; (pmatch exp name <clause> ...))                       ADDED (summer, 2012) Will Byrd
; <clause> ::= (<pattern> <guard> exp ...)
; <guard> ::= boolean exp ... | ()
; <pattern> :: =
;        ,var  -- matches always and binds the var
;                 pattern must be linear! No check is done
;        ()
;        exp   -- comparison with exp (using equal?)
;        (<pattern1> <pattern2> ...) -- matches the list of patterns
;        (<pattern1> . <pattern2>)  -- ditto
; dmatch (August 14, 2012) Jason Hemann, Will Byrd, and Dan Friedman, improvements by Aaron Hsu 9/6/2012

(define-syntax test-check
  (syntax-rules ()
    ((_ title tested-expression expected-result)
     (begin
       (printf "Testing ~s\n" title)
       (let* ((expected expected-result)
              (produced tested-expression))
         (or (equal? expected produced)
             (errorf 'test-check
               "Failed: ~a~%Expected: ~a~%Computed: ~a~%"
               'tested-expression expected produced)))))))

(define pkg (lambda (cls thk) (cons cls thk)))
(define pkg-clause (lambda (pkg) (car pkg)))
(define pkg-thunk (lambda (pkg) (cdr pkg)))

(define-syntax dmatch
  (syntax-rules ()
    ((_ v (e ...) ...)
     (let ((pkg* (dmatch-remexp v (e ...) ...)))
       (run-a-thunk 'v v #f pkg*)))
    ((_ v name (e ...) ...)
     (let ((pkg* (dmatch-remexp v (e ...) ...)))
       (run-a-thunk 'v v 'name pkg*)))))

(define-syntax dmatch-remexp
  (syntax-rules ()
    ((_ (rator rand ...) cls ...)
     (let ((v (rator rand ...)))
       (dmatch-aux v cls ...)))
    ((_ v cls ...) (dmatch-aux v cls ...))))

(define-syntax dmatch-aux
  (syntax-rules (guard)
    ((_ v) '())
    ((_ v (pat (guard g ...) e0 e ...) cs ...)
     (let ((fk (lambda () (dmatch-aux v cs ...))))
       (ppat v pat
         (if (not (and g ...))
             (fk)
             (cons (pkg '(pat (guard g ...) e0 e ...) 
			(lambda () e0 e ...)) 
		   (fk)))
         (fk))))
    ((_ v (pat e0 e ...) cs ...)
     (let ((fk (lambda () (dmatch-aux v cs ...))))
       (ppat v pat
         (cons (pkg '(pat e0 e ...) (lambda () e0 e ...)) 
	       (fk))
         (fk))))))

(define-syntax ppat
  (syntax-rules (unquote)
    ((_ v (unquote var) kt kf) (let ((var v)) kt))
    ((_ v (x . y) kt kf)
     (if (pair? v)
	 (let ((vx (car v)) (vy (cdr v)))
	   (ppat vx x (ppat vy y kt kf) kf))
	 kf))
    ((_ v lit kt kf) (if (equal? v (quote lit)) kt kf))))

(define run-a-thunk 
  (lambda (v-expr v name pkg*)
    (cond
      ((null? pkg*) (no-matching-pattern name v-expr v))
      ((null? (cdr pkg*)) ((pkg-thunk (car pkg*))))
      (else 
        (overlapping-patterns/guards name v-expr v pkg*)))))

(define no-matching-pattern
  (lambda (name v-expr v)
    (if name
      (printf "dmatch ~d failed~n~d ~d~n" name v-expr v)
      (printf "dmatch failed~n~d ~d~n" v-expr v))
    (error 'dmatch "match failed")))

(define overlapping-patterns/guards
  (lambda (name v-expr v pkg*)
    (if name
      (printf "dmatch ~d overlapping matching clauses~n"
              name)
      (printf "dmatch overlapping matching clauses~n"))
    (printf "with ~d evaluating to ~d~n" v-expr v)
    (printf "____________________________________~n")
    (for-each pretty-print (map pkg-clause pkg*))))

(define h
  (lambda (x y)
    (dmatch `(,x . ,y) example
      ((,a . ,b)
       (guard (number? a) (number? b))
       (+ a b))
      ((,a ,b ,c)
       (guard (number? a) (number? b) (number? c))
       (+ a b c)))))

(test-check "h"
  (list (h 1 2) (apply h `(1 (3 4))))
  '(3 8))