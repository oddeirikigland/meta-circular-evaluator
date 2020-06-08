# meta-circular-evaluator

## Requirements

* MIT/GNU Scheme

## Run

Open scheme REPL

```bash
scheme
```

Load file and run evaluator

```scheme
1 ]=> (load "eval.scm")
1 ]=> (repl)
```

You're using the meta circular evaluator when you see `>>>>` in the REPL.

## Example of usage

```scheme
>>>> (+ 1 2)
3
>>>> (* 3 4)
12
>>>> pi
3.14159
>>>> e
2.71828
>>>> (let ((a 3) (b 4)) (* a b))
12
>>>> (let ((e 10)) (* pi e))
31.4159
```
