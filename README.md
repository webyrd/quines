quines
======

Relational interpreter in miniKanren that can generate quines

> It's quine time!
> -- Daniel P. Friedman

Requirements
============

Chez Scheme or its free version [Petite Chez Scheme](http://www.scheme.com/download/#sec:petitechezscheme) are required to run the quines code and its supporting libraries.

### Petite Chez Scheme quick start

The [Petite Chez Scheme distributions](http://www.scheme.com/download/#sec:petitechezscheme) are located at the [Cadenca Research Systems website](http://www.scheme.com). The [installation instructions](http://www.scheme.com/download/#sec:install) are clear and concise.  A quit rundown of relevant commands are as follows:

 * To launch Petite Chez Scheme, simple run `petite` at your system command prompt

* If a computation enters an infinite loop, then you can hit CTRL-C to abort the computation and enter a debugging prompt.
  - Type `?` to view the available debugging commands

* To load a source file, type `(load "<filepath>")` where \<filepath\> is the path to a Scheme source file.

* Type `(exit)` to quit from Petite Chez Scheme

Visit the official [Petite Chez Scheme documentation](http://www.scheme.com/petitechezscheme.html) for more information.

Getting the source code
=======================

Clone the quines repository using Git with the following command:

```sh
git clone git://github.com/webyrd/quines.git
```

You can also download the source repository directly at <https://github.com/webyrd/quines/downloads> and extract its contents into your directory of choice.

Generating quines
=================

Navigate to the location where the quines source code was placed and launch your Chez Scheme or Petite Chez Scheme REPL.

From the REPL enter the following to load the quine system:

```scheme
(load "q.scm")
```

Finally, enter the following Scheme expression to exercise the quine system and verify that all seems in order:

```scheme
(run 1 (q) (eval-expo q '() q))
```

You should see the following (formatted for readability):

```scheme
((((lambda (_.0)
     (list _.0 (list 'quote _.0)))
   '(lambda (_.0)
      (list _.0 (list 'quote _.0))))
  (=/= ((_.0 . list))
       ((_.0 . quote)))
  (sym _.0)))
```

To prove that the system generated a quine, enter the following in the REPL:

```scheme
((lambda (_.0)
   (list _.0 (list 'quote _.0)))
  '(lambda (_.0)
     (list _.0 (list 'quote _.0))))
```

The resulting value should be the same as the executed form itself!

View the [talk.scm](https://github.com/webyrd/quines/blob/master/talk.scm) file for more usage examples.

Enjoy!
