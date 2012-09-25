Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> (load "mk.scm")
> (5)
> (5)
> (5 6)
> (5 6)
> ((5 . _.0)
   (_.0 . 6))
> (run* (q) (=/= 5 q))
((_.0
  (=/= ((_.0 . 5)))))
> (run* (q) (=/= 5 q) (=/= 6 q))
((_.0
  (=/= ((_.0 . 5))
       ((_.0 . 6)))))
> (run* (q) (=/= 5 q) (== 5 q))
()
> (run* (q) (== 5 q) (=/= 5 q))
()
> (run* (q)
  (fresh (a d)
    (== `(,a . ,d) q)
    (=/= q `(5 . 6))))
(((_.0 . _.1)
  (=/= ((_.0 . 5)
        (_.1 . 6)))))
> (run* (q)
    (fresh (a d)
      (== `(,a . ,d) q)
      (=/= q `(5 . 6))
      (== a 5)))
(((5 . _.0) (=/= ((_.0 . 6)))))
> (run* (q)
    (fresh (a d)
      (== `(,a . ,d) q)
      (=/= q `(5 . 6))
      (== a 5)
      (== d 6)))
()
> (run* (q)
    (fresh (a d)
      (== `(,a . ,d) q)
      (=/= q `(5 . 6))
      (== a 3)))
((3 . _.0))
> (run* (q) (symbolo q))
((_.0 (sym _.0)))
> (run* (q) (numbero q))
((_.0 (num _.0)))
> (run* (q) (symbolo q) (== 'strange-loop q))
(strange-loop)
> (run* (q) (symbolo q) (== 5 q))
()
> (run* (q) (numbero q) (== 5 q))
(5)
> (run* (q) (numbero q) (symbolo q))
()
> (define no-closureo (not-in 'closure))
> no-closureo
#<procedure>
> (run 1 (q)
    (== `(3 (closure x (x x) ((y . 7))) #t) q)
    (no-closureo q))
()
> (run 1 (q)
    (== `(3 (clojure x (x x) ((y . 7))) #t) q)
    (no-closureo q))
((3 (clojure x (x x) ((y . 7))) #t))
> > Testing "h"
> > (define appendo
  (lambda (l s out)
    (conde
      [(== '() l) (== s out)]
      [(fresh (a d res)
         (== `(,a . ,d) l)
         (== `(,a . ,res) out)
         (appendo d s res))])))
> > ((a b c d e))
> ((a b c))
> ((d e))
> (define appendo
  (lambda (l s out)
    (conde
      [(== '() l) (== s out)]
      [(fresh (a d res)
         (== `(,a . ,d) l)
         (appendo d s res)
         (== `(,a . ,res) out))])))
>   C-c C-c
break>   C-c C-c
break> r
> > (1 0 1)
> (0 1 1)
> ()
> `(1 . ,x)

Exception: variable x is not bound
Type (debug) to enter the debugger.
> (run* (q) (*o (build-num 2) (build-num 3) q))
((0 1 1))
> (run* (q) (*o q (build-num 3) (build-num 6)))
((0 1))
> (run* (q) (fresh (n m) (*o n m (build-num 6)) (== `(,n ,m) q)))
(((1) (0 1 1)) ((0 1 1) (1)) ((0 1) (1 1)) ((1 1) (0 1)))
> ((1) (0 1 1))

Exception: attempt to apply non-procedure 1
Type (debug) to enter the debugger.
> 

Process scheme finished
Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> Testing "h"
> > > > (lookup 'x '((x . 5) (y . 6)))
5
> (not-in-env 'sub1 '((sub1 . (closure blah)) (y . 6)))
#f
> (not-in-env 'foo '((sub1 . (closure blah)) (y . 6)))
#t
> (eval-exp
   '(((lambda (x) (lambda (y) x))
      (lambda (z) z))
     (lambda (a) a))
   '())
(closure z z ())
> (eval-exp
   '((lambda (lambda) (lambda lambda))
     (lambda (lambda) (lambda lambda)))
   '())
  C-c C-c
break> r
> (define eval-exp
  (lambda (exp env)
    (dmatch exp
      ((,rator ,rand)
       (let ((proc (eval-exp rator env))
             (arg (eval-exp rand env)))
         (dmatch proc
           ((closure ,x ,body ,env^)
            (eval-exp body `((,x . ,arg) . ,env^))))))      
      ((lambda (,x) ,body)
       (guard (symbol? x) (not-in-env 'lambda env))
       `(closure ,x ,body ,env))
      (,x (guard (symbol? x)) (lookup x env)))))
> (eval-exp
 '((lambda (lambda) (lambda lambda))
   (lambda (lambda) (lambda lambda)))
 '())
(eval-exp
 '((lambda (lambda) (lambda lambda))
   (lambda (lambda) (lambda lambda)))
 '())
  C-c C-c
break> r
> (eval-exp
 '((lambda (lambda) (lambda lambda))
   (lambda (lambda) (lambda lambda)))
 '())
  C-c C-c
break> r
> 
r

Exception: variable r is not bound
Type (debug) to enter the debugger.
> 

Process scheme finished
Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> > > > > (run* (q)
  (eval-expo
   '(((lambda (x) (lambda (y) x))
      (lambda (z) z)) (lambda (a) a))
   '()
   q))
((closure z z ()))
> (run 5 (q)
  (eval-expo q '() '(closure y x ((x . (closure z z ()))))))
(((lambda (x) (lambda (y) x)) (lambda (z) z))
  ((lambda (x) (x (lambda (y) x))) (lambda (z) z))
  (((lambda (x) (lambda (y) x))
     ((lambda (_.0) _.0) (lambda (z) z)))
    (sym _.0))
  ((((lambda (_.0) _.0) (lambda (x) (lambda (y) x)))
     (lambda (z) z))
    (sym _.0))
  (((lambda (_.0) _.0)
     ((lambda (x) (lambda (y) x)) (lambda (z) z)))
    (sym _.0)))
> ((lambda (x) (lambda (y) x)) (lambda (z) z))
#<procedure>
> (run 5 (q)
    (fresh (e v)
      (eval-expo e '() v)
      (== `(,e ==> ,v) q)))
((((lambda (_.0) _.1) ==> (closure _.0 _.1 ())) (sym _.0))
  ((((lambda (_.0) _.0) (lambda (_.1) _.2))
     ==>
     (closure _.1 _.2 ()))
    (sym _.0 _.1))
  ((((lambda (_.0) (lambda (_.1) _.2)) (lambda (_.3) _.4))
     ==>
     (closure _.1 _.2 ((_.0 closure _.3 _.4 ()))))
    (=/= ((_.0 . lambda)))
    (sym _.0 _.1 _.3))
  ((((lambda (_.0) (_.0 _.0)) (lambda (_.1) _.1))
     ==>
     (closure _.1 _.1 ()))
    (sym _.0 _.1))
  ((((lambda (_.0) (_.0 _.0))
      (lambda (_.1) (lambda (_.2) _.3)))
     ==>
     (closure _.2 _.3 ((_.1 closure _.1 (lambda (_.2) _.3) ()))))
    (=/= ((_.1 . lambda)))
    (sym _.0 _.1 _.2)))
> Testing "push-down problens 2"
Testing "push-down problems 3"
Testing "push-down problems 4"
Testing "push-down problems 6"
Testing "push-down problems 1"
Testing "push-down problems 5"
Testing "zero?"
Testing "*"
Testing "sub1"
Testing "sub1 bigger WAIT a minute"
Testing "sub1 biggest WAIT a minute"
Testing "lots of programs to make a 6"
Testing "rel-fact5"
Testing "rel-fact5-backwards"
>   C-c C-c
> 

Process scheme finished
Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> Testing "push-down problens 2"
Testing "push-down problems 3"
Testing "push-down problems 4"
Testing "push-down problems 6"
Testing "push-down problems 1"
Testing "push-down problems 5"
Testing "zero?"
Testing "*"
Testing "sub1"
Testing "sub1 bigger WAIT a minute"
Testing "sub1 biggest WAIT a minute"
Testing "lots of programs to make a 6"
Testing "rel-fact5"
Testing "rel-fact5-backwards"
> (run 1 (q) (eval-expo q '() '(into (0 1 1))))
((numo (0 1 1)))
> (run 10 (q) (eval-expo q '() '(into (0 1 1))))
((numo (0 1 1)) (sub1 (numo (1 1 1))) (* (numo (1)) (numo (0 1 1)))
  (* (numo (0 1 1)) (numo (1))) (if #t (numo (0 1 1)) _.0)
  (* (numo (0 1)) (numo (1 1))) (if #f _.0 (numo (0 1 1)))
  (sub1 (* (numo (1)) (numo (1 1 1))))
  (((lambda (_.0) (numo (0 1 1))) #t)
    (=/= ((_.0 . numo)))
    (sym _.0))
  (sub1 (* (numo (1 1 1)) (numo (1)))))
> (run 30 (q) (eval-expo q '() '(into (0 1 1))))
((numo (0 1 1)) (sub1 (numo (1 1 1)))
 (* (numo (1)) (numo (0 1 1))) (* (numo (0 1 1)) (numo (1)))
 (if #t (numo (0 1 1)) _.0) (* (numo (0 1)) (numo (1 1)))
 (if #f _.0 (numo (0 1 1)))
 (sub1 (* (numo (1)) (numo (1 1 1))))
 (((lambda (_.0) (numo (0 1 1))) #t)
   (=/= ((_.0 . numo)))
   (sym _.0))
 (sub1 (* (numo (1 1 1)) (numo (1))))
 (sub1 (sub1 (numo (0 0 0 1))))
 (sub1 (if #t (numo (1 1 1)) _.0))
 (* (numo (1 1)) (numo (0 1)))
 (((lambda (_.0) (numo (0 1 1))) #f)
   (=/= ((_.0 . numo)))
   (sym _.0))
 (sub1 (if #f _.0 (numo (1 1 1))))
 (* (numo (0 1 1)) (sub1 (numo (0 1))))
 (if #t (sub1 (numo (1 1 1))) _.0)
 ((sub1 ((lambda (_.0) (numo (1 1 1))) #t))
   (=/= ((_.0 . numo)))
   (sym _.0))
 (((lambda (_.0) (numo (0 1 1))) (numo _.1))
   (=/= ((_.0 . numo)))
   (sym _.0))
 (((lambda (_.0) (sub1 (numo (1 1 1)))) #t)
   (=/= ((_.0 . numo)) ((_.0 . sub1)))
   (sym _.0))
 (* (sub1 (numo (0 1))) (numo (0 1 1)))
 (* (numo (1)) (sub1 (numo (1 1 1))))
 (sub1 (sub1 (sub1 (numo (1 0 0 1)))))
 ((sub1 ((lambda (_.0) (numo (1 1 1))) #f))
   (=/= ((_.0 . numo)))
   (sym _.0))
 
 (if #f _.0 (sub1 (numo (1 1 1))))

 (if #t (* (numo (1)) (numo (0 1 1))) _.0)
 (* (numo (1 1)) (sub1 (numo (1 1))))
 (if #t (* (numo (0 1 1)) (numo (1))) _.0)
 (((lambda (_.0) (sub1 (numo (1 1 1)))) #f)
   (=/= ((_.0 . numo)) ((_.0 . sub1)))
   (sym _.0))
 (sub1 (* (numo (1 1 1)) (sub1 (numo (0 1))))))
> 

Process scheme finished
Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> > > > > > > (run 1 (q) (eval-expo q env q))

Exception: variable env is not bound
Type (debug) to enter the debugger.
> (run 1 (q) (eval-expo q '() q))
((((lambda (_.0) (list _.0 (list 'quote _.0)))
   '(lambda (_.0) (list _.0 (list 'quote _.0))))
  (=/= ((_.0 . list))
       ((_.0 . quote)))
  (sym _.0)))
> (define q '((lambda (_.0) (list _.0 (list 'quote _.0)))
              '(lambda (_.0) (list _.0 (list 'quote _.0)))))
> q
((lambda (_.0) (list _.0 (list 'quote _.0)))
  '(lambda (_.0) (list _.0 (list 'quote _.0))))
> (eval q)
((lambda (_.0) (list _.0 (list 'quote _.0)))
  '(lambda (_.0) (list _.0 (list 'quote _.0))))
> (equal? (eval q) q)
#t
> (run 2 (q) (eval-expo q '() q))
((((lambda (_.0) (list _.0 (list 'quote _.0)))
    '(lambda (_.0) (list _.0 (list 'quote _.0))))
   (=/= ((_.0 . list)) ((_.0 . quote)))
   (sym _.0))
  (((lambda (_.0)
      (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0)))
     '(lambda (_.0)
        (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . _.0)))
    (no-closure _.2)
    (sym _.0 _.1)))
> ((lambda (_.0)
      (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0)))
     '(lambda (_.0)
        (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0))))
((lambda (_.0)
   (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0)))
 '(lambda (_.0)
     (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0))))
> (run 6 (q) (eval-expo q '() q))
((((lambda (_.0) (list _.0 (list 'quote _.0)))
    '(lambda (_.0) (list _.0 (list 'quote _.0))))
   (=/= ((_.0 . list)) ((_.0 . quote)))
   (sym _.0))
  (((lambda (_.0)
      (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0)))
     '(lambda (_.0)
        (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . _.0)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 (list ((lambda (_.1) 'quote) '_.2) _.0)))
     '(lambda (_.0)
        (list _.0 (list ((lambda (_.1) 'quote) '_.2) _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list (list 'lambda '(_.0) _.0) (list 'quote _.0)))
     '(list (list 'lambda '(_.0) _.0) (list 'quote _.0)))
    (=/= ((_.0 . list)) ((_.0 . quote)))
    (sym _.0))
  (((lambda (_.0)
      (list _.0 (list ((lambda (_.1) _.1) 'quote) _.0)))
     '(lambda (_.0)
        (list _.0 (list ((lambda (_.1) _.1) 'quote) _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      ((lambda (_.1) (list _.0 (list 'quote _.0))) '_.2))
     '(lambda (_.0)
        ((lambda (_.1) (list _.0 (list 'quote _.0))) '_.2)))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)) ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1)))
> (run 10 (q) (eval-expo q '() q))
((((lambda (_.0) (list _.0 (list 'quote _.0)))
    '(lambda (_.0) (list _.0 (list 'quote _.0))))
   (=/= ((_.0 . list)) ((_.0 . quote)))
   (sym _.0))
  (((lambda (_.0)
      (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0)))
     '(lambda (_.0)
        (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . _.0)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 (list ((lambda (_.1) 'quote) '_.2) _.0)))
     '(lambda (_.0)
        (list _.0 (list ((lambda (_.1) 'quote) '_.2) _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list (list 'lambda '(_.0) _.0) (list 'quote _.0)))
     '(list (list 'lambda '(_.0) _.0) (list 'quote _.0)))
    (=/= ((_.0 . list)) ((_.0 . quote)))
    (sym _.0))
  (((lambda (_.0)
      (list _.0 (list ((lambda (_.1) _.1) 'quote) _.0)))
     '(lambda (_.0)
        (list _.0 (list ((lambda (_.1) _.1) 'quote) _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      ((lambda (_.1) (list _.0 (list 'quote _.0))) '_.2))
     '(lambda (_.0)
        ((lambda (_.1) (list _.0 (list 'quote _.0))) '_.2)))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)) ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 ((lambda (_.1) (list 'quote _.0)) '_.2)))
     '(lambda (_.0)
        (list _.0 ((lambda (_.1) (list 'quote _.0)) '_.2))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)) ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 (list 'quote ((lambda (_.1) _.0) '_.2))))
     '(lambda (_.0)
        (list _.0 (list 'quote ((lambda (_.1) _.0) '_.2)))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . _.0)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      ((lambda (_.1) (list _.1 (list 'quote _.1))) _.0))
     '(lambda (_.0)
        ((lambda (_.1) (list _.1 (list 'quote _.1))) _.0)))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . list)) ((_.1 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 ((lambda (_.1) (list 'quote _.1)) _.0)))
     '(lambda (_.0)
        (list _.0 ((lambda (_.1) (list 'quote _.1)) _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . list)) ((_.1 . quote)))
    (sym _.0 _.1)))
> (run 15 (q) (eval-expo q '() q))
((((lambda (_.0) (list _.0 (list 'quote _.0)))
    '(lambda (_.0) (list _.0 (list 'quote _.0))))
   (=/= ((_.0 . list)) ((_.0 . quote)))
   (sym _.0))
  (((lambda (_.0)
      (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0)))
     '(lambda (_.0)
        (list ((lambda (_.1) _.0) '_.2) (list 'quote _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . _.0)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 (list ((lambda (_.1) 'quote) '_.2) _.0)))
     '(lambda (_.0)
        (list _.0 (list ((lambda (_.1) 'quote) '_.2) _.0))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list (list 'lambda '(_.0) _.0) (list 'quote _.0)))
     '(list (list 'lambda '(_.0) _.0) (list 'quote _.0)))
    (=/= ((_.0 . list)) ((_.0 . quote)))
    (sym _.0))
  (((lambda (_.0)
      (list _.0 (list ((lambda (_.1) _.1) 'quote) _.0)))
     '(lambda (_.0)
        (list _.0 (list ((lambda (_.1) _.1) 'quote) _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      ((lambda (_.1) (list _.0 (list 'quote _.0))) '_.2))
     '(lambda (_.0)
        ((lambda (_.1) (list _.0 (list 'quote _.0))) '_.2)))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)) ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 ((lambda (_.1) (list 'quote _.0)) '_.2)))
     '(lambda (_.0)
        (list _.0 ((lambda (_.1) (list 'quote _.0)) '_.2))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)) ((_.1 . quote)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 (list 'quote ((lambda (_.1) _.0) '_.2))))
     '(lambda (_.0)
        (list _.0 (list 'quote ((lambda (_.1) _.0) '_.2)))))
    (=/= ((_.0 . lambda))
         ((_.0 . list))
         ((_.0 . quote))
         ((_.1 . _.0)))
    (no-closure _.2)
    (sym _.0 _.1))
  (((lambda (_.0)
      ((lambda (_.1) (list _.1 (list 'quote _.1))) _.0))
     '(lambda (_.0)
        ((lambda (_.1) (list _.1 (list 'quote _.1))) _.0)))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . list)) ((_.1 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 ((lambda (_.1) (list 'quote _.1)) _.0)))
     '(lambda (_.0)
        (list _.0 ((lambda (_.1) (list 'quote _.1)) _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . list)) ((_.1 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      ((lambda (_.1) (list _.0 (list _.1 _.0))) 'quote))
     '(lambda (_.0)
        ((lambda (_.1) (list _.0 (list _.1 _.0))) 'quote)))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)))
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 ((lambda (_.1) (list _.1 _.0)) 'quote)))
     '(lambda (_.0)
        (list _.0 ((lambda (_.1) (list _.1 _.0)) 'quote))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.1 . list)))
    (sym _.0 _.1))
  (((lambda (_.0)
      (list _.0 (list 'quote ((lambda (_.1) _.1) _.0))))
     '(lambda (_.0)
        (list _.0 (list 'quote ((lambda (_.1) _.1) _.0)))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote)))
    (sym _.0 _.1))
  (((lambda (_.0)
      (list
        ((lambda (_.1) _.0) '_.2)
        (list ((lambda (_.3) 'quote) '_.4) _.0)))
     '(lambda (_.0)
        (list
          ((lambda (_.1) _.0) '_.2)
          (list ((lambda (_.3) 'quote) '_.4) _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote))
         ((_.1 . _.0)) ((_.3 . quote)))
    (no-closure _.2 _.4)
    (sym _.0 _.1 _.3))
  (((lambda (_.0)
      (list ((lambda (_.1) _.1) _.0) (list 'quote _.0)))
     '(lambda (_.0)
        (list ((lambda (_.1) _.1) _.0) (list 'quote _.0))))
    (=/= ((_.0 . lambda)) ((_.0 . list)) ((_.0 . quote)))
    (sym _.0 _.1)))
> (run 1 (r)
    (fresh (p q)      
      (=/= p q)
      (eval-expo p '() q)
      (eval-expo q '() p)
      (== `(,p ,q) r)))
((('((lambda (_.0)
       (list 'quote (list _.0 (list 'quote _.0))))
      '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0)))))
    ((lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))
      '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))))
   (=/= ((_.0 . list)) ((_.0 . quote)))
   (sym _.0)))
> (define p ''((lambda (_.0)
       (list 'quote (list _.0 (list 'quote _.0))))
      '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))))
> (define q '((lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))
      '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))))
> (equal? (eval p) q)
#t
> (equal? (eval q) p)
#t
> (equal? p q)
#f
> 

Process scheme finished
Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> > > > > (run* (q) (!- '(lambda (x) x) '() q))

Exception: variable x is not bound
Type (debug) to enter the debugger.
> (load "infer.scm")
> (run* (q) (!- '(lambda (x) x) '() q))

Exception: variable x is not bound
Type (debug) to enter the debugger.
> (run* (q) (!- '(lambda (x) x) '() q))

Exception: variable x is not bound
Type (debug) to enter the debugger.
> 

Process scheme finished
Petite Chez Scheme Version 8.4
Copyright (c) 1985-2011 Cadence Research Systems

> (load "infer.scm")
> (run* (q) (!- '(lambda (x) x) '() q))
((-> _.0 _.0))
> (run* (q) (!- '(lambda (x) (lambda (y) y)) '() q))
((-> _.0 (-> _.1 _.1)))
> (run* (q) (!- '((lambda (x) (lambda (y) y)) (lambda (z) z)) '() q))
((-> _.0 _.0))
> (run* (q) (!- '((lambda (x) (lambda (y) x)) (lambda (z) z)) '() q))
((-> _.0 (-> _.1 _.1)))
> (run 10 (q) (!- q '() '(-> _.0 _.0)))
(((lambda (_.0) _.0) (sym _.0))
 ((lambda (_.0) ((lambda (_.1) _.1) _.0))
  (=/= ((_.0 . lambda)))
  (sym _.0 _.1))
 (((lambda (_.0) _.0) (lambda (_.1) _.1)) (sym _.0 _.1))
 ((lambda (_.0) ((lambda (_.1) _.0) _.0))
  (=/= ((_.0 . lambda)) ((_.1 . _.0)))
  (sym _.0 _.1))
  ((lambda (_.0)
     ((lambda (_.1) _.1) ((lambda (_.2) _.2) _.0)))
    (=/= ((_.0 . lambda)))
    (sym _.0 _.1 _.2))
  ((lambda (_.0) ((lambda (_.1) _.0) (lambda (_.2) _.2)))
    (=/= ((_.0 . lambda)) ((_.1 . _.0)))
    (sym _.0 _.1 _.2))
  (((lambda (_.0) (lambda (_.1) _.1)) (lambda (_.2) _.2))
    (=/= ((_.0 . lambda)))
    (sym _.0 _.1 _.2))
  ((lambda (_.0)
     ((lambda (_.1) _.1) ((lambda (_.2) _.0) _.0)))
    (=/= ((_.0 . lambda)) ((_.2 . _.0)))
    (sym _.0 _.1 _.2))
  ((lambda (_.0) ((lambda (_.1) _.0) (lambda (_.2) _.0)))
    (=/= ((_.0 . lambda)) ((_.1 . _.0)) ((_.2 . _.0)))
    (sym _.0 _.1 _.2))
  (((lambda (_.0) _.0)
     (lambda (_.1) ((lambda (_.2) _.2) _.1)))
    (=/= ((_.1 . lambda)))
    (sym _.0 _.1 _.2)))
> ((lambda (_.0) _.0)
     (lambda (_.1) ((lambda (_.2) _.2) _.1)))
#<procedure>
> (((lambda (_.0) _.0)
     (lambda (_.1) ((lambda (_.2) _.2) _.1))) 5)
5
> (run 10 (q) (fresh (exp env type) (!- exp env type) (== `(,exp ,env ,type) q)))
(((_.0 ((_.0 . _.1) . _.2) _.1) (sym _.0))
  ((_.0 ((_.1 . _.2) (_.0 . _.3) . _.4) _.3)
    (=/= ((_.1 . _.0)))
    (sym _.0))
  ((_.0 ((_.1 . _.2) (_.3 . _.4) (_.0 . _.5) . _.6) _.5)
    (=/= ((_.1 . _.0)) ((_.3 . _.0)))
    (sym _.0))
  ((_.0 ((_.1 . _.2) (_.3 . _.4) (_.5 . _.6) (_.0 . _.7) .
          _.8)
        _.7)
    (=/= ((_.1 . _.0)) ((_.3 . _.0)) ((_.5 . _.0)))
    (sym _.0))
  ((_.0 ((_.1 . _.2) (_.3 . _.4) (_.5 . _.6) (_.7 . _.8)
          (_.0 . _.9) . _.10)
        _.9)
    (=/= ((_.1 . _.0))
         ((_.3 . _.0))
         ((_.5 . _.0))
         ((_.7 . _.0)))
    (sym _.0))
  ((_.0 ((_.1 . _.2) (_.3 . _.4) (_.5 . _.6) (_.7 . _.8)
          (_.9 . _.10) (_.0 . _.11) . _.12)
        _.11)
    (=/= ((_.1 . _.0)) ((_.3 . _.0)) ((_.5 . _.0)) ((_.7 . _.0))
         ((_.9 . _.0)))
    (sym _.0))
  ((_.0 ((_.1 . _.2) (_.3 . _.4) (_.5 . _.6) (_.7 . _.8)
          (_.9 . _.10) (_.11 . _.12) (_.0 . _.13) . _.14)
        _.13)
    (=/= ((_.1 . _.0)) ((_.11 . _.0)) ((_.3 . _.0))
         ((_.5 . _.0)) ((_.7 . _.0)) ((_.9 . _.0)))
    (sym _.0))

  ((_.0

    ((_.1 . _.2) (_.3 . _.4) (_.5 . _.6) (_.7 . _.8) (_.9 . _.10)
     (_.11 . _.12) (_.13 . _.14) (_.0 . _.15) . _.16)
    
    _.15)
    
   (=/= ((_.1 . _.0)) ((_.11 . _.0)) ((_.13 . _.0))
         ((_.3 . _.0)) ((_.5 . _.0)) ((_.7 . _.0)) ((_.9 . _.0)))
    (sym _.0))

  (((lambda (_.0) _.0) () (-> _.1 _.1)) (sym _.0))
  ((_.0 ((_.1 . _.2) (_.3 . _.4) (_.5 . _.6) (_.7 . _.8) (_.9 . _.10)
          (_.11 . _.12) (_.13 . _.14) (_.15 . _.16) (_.0 . _.17) .
          _.18)
        _.17)
    (=/= ((_.1 . _.0)) ((_.11 . _.0)) ((_.13 . _.0))
         ((_.15 . _.0)) ((_.3 . _.0)) ((_.5 . _.0)) ((_.7 . _.0))
         ((_.9 . _.0)))
    (sym _.0)))
> 