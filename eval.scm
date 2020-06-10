(define (eval exp env)
    (cond ((self-evaluating? exp) exp)
        ((name? exp)
            (eval-name exp env))
        ((let? exp)
            (eval-let exp env))
        ((flet? exp)
            (eval-flet exp env))
        ((call? exp)
            (eval-call exp env))
        (else
            (error "Unknown expression type - EVAL" exp))))

(define (prompt-for-input)
    (display ">>>> "))

(define (print object)
    (write object)
    (newline))

(define (self-evaluating? exp)
    (or (number? exp) (string? exp) (boolean? exp)))

(define (name? exp)
    (symbol? exp))

(define (let? exp)
    (and (pair? exp)
        (eq? (car exp) 'let)))

(define (let-names exp)
    (map car (cadr exp)))

(define (let-inits exp)
    (map cadr (cadr exp)))

(define (let-body exp)
    (caddr exp))

(define (eval-name name env)
    (cond 
        ((null? env)
            (error "Unbound name -- EVAL-NAME" name))
        ((eq? name (caar env))
            (cdar env))
        (else
            (eval-name name (cdr env)))))

(define (eval-let exp env)
    (let ((values (eval-exprs (let-inits exp) env)))
        (let ((extended-environment (augment-environment (let-names exp) values env)))
            (eval (let-body exp) extended-environment))))

(define (eval-exprs exprs env)
    (if (null? exprs)
        (list)
        (cons (eval (car exprs) env) (eval-exprs (cdr exprs) env))))

(define (augment-environment names values env)
    (if (null? names)
        env
        (cons
            (cons (car names) (car values))
            (augment-environment (cdr names) (cdr values) env))))

(define empty-environment (list))

(define (call? exp)
    (pair? exp))

(define (call-operator exp)
    (car exp))

(define (call-operands exp)
    (cdr exp))

(define (flet? exp)
    (and (pair? exp)
        (eq? (car exp) 'flet)))

(define (flet-names exp)
    (map car (cadr exp)))

(define (flet-functions exp)
    (map 
        (lambda (f)
            (make-function (cadr f) (cddr f)))
        (cadr exp)))

(define (make-function parameters body)
    (cons 'function (cons parameters body)))

(define (flet-body exp)
    (caddr exp))

(define (eval-flet exp env)
    (let ((extended-environment 
        (augment-environment
           (flet-names exp)
           (flet-functions exp)
           env)))
        (eval (flet-body exp) extended-environment)))

(define (function? obj)
    (and (pair? obj)
        (eq? (car obj) 'function)))

(define (function-parameters func)
    (cadr func))

(define (function-body func)
    (caddr func))

(define (eval-call exp env)
    (let ((func (eval-name (call-operator exp) env))
        (args (eval-exprs (call-operands exp) env)))
        (if (primitive? func)
            (apply-primitive-operation func args)
        (let ((extended-environment
            (augment-environment
                (function-parameters func)
                args
                env)))
            (eval (function-body func) extended-environment)))))

(define (make-primitive f)
    (list 'primitive f))

(define (primitive? obj)
    (and (pair? obj)
        (eq? (car obj) 'primitive)))

(define (primitive-operation prim)
    (cadr prim))

(define (apply-primitive-operation prim args)
    (apply (primitive-operation prim) args))

(define initial-bindings
    (list 
        (cons 'pi 3.14159)
        (cons 'e 2.71828)
        (cons 'square (make-function '(x) '((* x x))))
        (cons '+ (make-primitive +))
        (cons '* (make-primitive *))
        (cons '- (make-primitive -))
        (cons '/ (make-primitive /))
        (cons '= (make-primitive =))
        ))

(define initial-environment
    (augment-environment 
        (map car initial-bindings)
        (map cdr initial-bindings) 
        empty-environment))

(define (repl)
    (prompt-for-input)
    (let ((input (read)))
        (let ((output (eval input initial-environment)))
            (print output)))
    (repl))