Examples from "Monads for functional programming"
=================================================

In this meetup we went through the initial examples in the paper "Monads for
functional programming", by Philip Wadler, implemented in OCaml.

We start with a simple evaluator and then add effects to it: exceptions, state
and logging. For each example, we start with a version that is impure and then
write it as pure function. Then, its plumbing is generalized by the use of
monads, leading to a version that is pure AND expressed similarly as the impure
one.

Running the examples
--------------------

The examples are organized as follows:

- `a_simple_evaluator.ml`: the initial version with just the evaluator

- `b_evaluator_exception.ml`: the original evaluator with an exception

- `c_evaluator_state.ml`: counting the number of divisions

- `d_evaluator_logging.ml`: logging the evaluation steps

- `e_evaluator_monad.ml`: the initial evaluator written with the identity monad

In order to open a REPL with the examples you need to have the
[Dune](https://github.com/ocaml/dune), one of OCaml's build system. Then, in this
folder run `dune utop` and open the modules from each example:

```
$ dune utop
(...Welcomes you to utop..)

utop # open A_simple_evaluator;;
utop # eval (Div (Cons 2, Cons 2));;
- : int = 1
```

