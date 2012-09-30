;;; language intro

(load "mk.scm")

; run, ==, conde, fresh

(run 1 (q) (== 5 q))

(run* (q)
  (conde
    [(== 5 q)]
    [(== 6 q)]))

(run* (q)
  (fresh (a d)
    (conde
      [(== 5 a)]
      [(== 6 d)])
    (== `(,a . ,d) q)))

;;; language extensions

; =/=, symbolo, numbero, not-in

(run* (q) (=/= 5 q))

(run* (q) (=/= 5 q) (== 5 q))

(run* (q) (=/= 5 q) (=/= 6 q))

(run* (q) (=/= 5 q) (=/= 6 q) (== q 5))

(run* (q)
  (fresh (a d)
    (== `(,a . ,d) q)
    (=/= q `(5 . 6))))

(run* (q)
  (fresh (a d)
    (== `(,a . ,d) q)
    (=/= q `(5 . 6))
    (== a 5)))

(run* (q)
  (fresh (a d)
    (== `(,a . ,d) q)
    (=/= q `(5 . 6))
    (== a 5)
    (== d 6)))

(run* (q)
  (fresh (a d)
    (== `(,a . ,d) q)
    (=/= q `(5 . 6))
    (== a 3)))


(run* (q) (symbolo q))

(run* (q) (symbolo q) (== 'foo q))

(run* (q) (symbolo q) (== 5 q))


(run* (q) (numbero q))

(run* (q) (numbero q) (== 'foo q))

(run* (q) (numbero q) (== 5 q))


(run* (q) (symbolo q) (numbero q))


(load "mk.scm")

(run 1 (q)
  (== `(3 (closure x (x x) ((y . 7))) #t) q)
  (noo 'closure q))


;;; append

(define append
  (lambda (l s)
    (cond
      [(null? l) s]
      [else (cons (car l) (append (cdr l) s))])))

(load "dmatch.scm")

(define append
  (lambda (l s)
    (dmatch l
      [() s]
      [(,a . ,d) (cons a (append d s))])))

(append '(a b c) '(d e))


(load "mk.scm")

(define appendo
  (lambda (l s out)
    (conde
      [(== '() l) (== s out)]
      [(fresh (a d res)
         (== `(,a . ,d) l)
         (== `(,a . ,res) out)
         (appendo d s res))])))

(run* (q) (appendo '(a b c) '(d e) q))

(run* (q) (appendo q '(d e) '(a b c d e)))

(run* (q) (appendo '(a b c) q '(a b c d e)))

(run 5 (q)
  (fresh (l s out)    
    (appendo l s out)
    (== `(,l ,s ,out) q)))

;;; numbers

(load "numbers.scm")

(build-num 5)

(build-num 6)

(build-num 0)

(run* (q) (*o (build-num 2) (build-num 3) q))

(run* (q)
  (fresh (n m)    
    (*o n m (build-num 6))
    (== `(,n ,m) q)))

;;;

(load "dmatch.scm")

(define eval-exp
  (lambda (exp env)
    (dmatch exp
      (,x (guard (symbol? x)) (lookup x env))
      ((lambda (,x) ,body)
       (guard (symbol? x) (not-in-env 'lambda env))
       `(closure ,x ,body ,env))
      ((,rator ,rand)
       (let ((proc (eval-exp rator env))
             (arg (eval-exp rand env)))
         (dmatch proc
           ((closure ,x ,body ,env^)
            (eval-exp body `((,x . ,arg) . ,env^)))))))))

(define lookup
  (lambda (x env)
    (dmatch env
      (() #f)
      (((,y . ,v) . ,rest) (guard (eq? y x))
       v)
      (((,y . ,v) . ,rest) (guard (not (eq? y x)))
       (lookup x rest)))))

(define not-in-env
  (lambda (x env)
    (dmatch env
      (() #t)
      (((,y . ,v) . ,rest) (guard (eq? y x))
       #f)      
      (((,y . ,v) . ,rest) (guard (not (eq? y x)))
       (not-in-env x rest)))))

(eval-exp
 '(((lambda (x) (lambda (y) x))
    (lambda (z) z))
   (lambda (a) a))
 '())

'(eval-exp
 '((lambda (lambda) (lambda lambda))
   (lambda (lambda) (lambda lambda)))
 '())

; reorder clauses
(define eval-exp
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

(eval-exp
 '(((lambda (x) (lambda (y) x))
    (lambda (z) z))
   (lambda (a) a))
 '())

(load "mk.scm")

(define eval-expo
  (lambda (exp env val)
    (conde
      ((fresh (rator rand x body env^ a)
         (== `(,rator ,rand) exp)
         (eval-expo rator env `(closure ,x ,body ,env^))
         (eval-expo rand env a)
         (eval-expo body `((,x . ,a) . ,env^) val)))
      ((fresh (x body)
         (== `(lambda (,x) ,body) exp)
         (symbolo x)
         (== `(closure ,x ,body ,env) val)
         (not-in-envo 'lambda env)))
      ((symbolo exp) (lookupo exp env val)))))

(define not-in-envo
  (lambda (x env)
    (conde
      ((== '() env))
      ((fresh (y v rest)
         (== `((,y . ,v) . ,rest) env)
         (=/= y x)
         (not-in-envo x rest))))))

(define lookupo
  (lambda (x env t)
    (fresh (rest y v)
      (== `((,y . ,v) . ,rest) env)
      (conde
        ((== y x) (== v t))
        ((=/= y x) (lookupo x rest t))))))

(run* (q)
  (eval-expo
   '(((lambda (x) (lambda (y) x))
      (lambda (z) z)) (lambda (a) a))
   '()
   q))

(run 5 (q)
  (eval-expo q '() '(closure y x ((x . (closure z z ()))))))

(run 5 (q)
  (fresh (e v)
    (eval-expo e '() v)
    (== `(,e ==> ,v) q)))

;;; adding numbers

(load "withnumbers.scm")


;;; quine time!

(load "mk.scm")

(define eval-expo
  (lambda (exp env val)
    (conde
      ((fresh (v)
         (== `(quote ,v) exp)
         (not-in-envo 'quote env)
         (noo 'closure v)
         (== v val)))
      ((fresh (a*)
         (== `(list . ,a*) exp)
         (not-in-envo 'list env)
         (noo 'closure a*)
         (proper-listo a* env val)))
      ((symbolo exp) (lookupo exp env val))
      ((fresh (rator rand x body env^ a)
         (== `(,rator ,rand) exp)
         (eval-expo rator env `(closure ,x ,body ,env^))
         (eval-expo rand env a)
         (eval-expo body `((,x . ,a) . ,env^) val)))
      ((fresh (x body)
         (== `(lambda (,x) ,body) exp)
         (symbolo x)
         (not-in-envo 'lambda env)
         (== `(closure ,x ,body ,env) val))))))

(define not-in-envo
  (lambda (x env)
    (conde
      ((fresh (y v rest)
         (== `((,y . ,v) . ,rest) env)
         (=/= y x)
         (not-in-envo x rest)))
      ((== '() env)))))

(define proper-listo
  (lambda (exp env val)
    (conde
      ((== '() exp)
       (== '() val))
      ((fresh (a d t-a t-d)
         (== `(,a . ,d) exp)
         (== `(,t-a . ,t-d) val)
         (eval-expo a env t-a)
         (proper-listo d env t-d))))))

(define lookupo
  (lambda (x env t)
    (fresh (rest y v)
      (== `((,y . ,v) . ,rest) env)
      (conde
        ((== y x) (== v t))
        ((=/= y x) (lookupo x rest t))))))

(run 1 (q) (eval-expo q '() q))

;;; twine
(run 1 (q)
  (fresh (x y)
    (=/= x y)
    (eval-expo x '() y)
    (eval-expo y '() x)
    (== `(,x ,y) q)))
