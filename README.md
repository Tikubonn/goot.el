
# goot.el

this provide some macros for looping that are supported the break/continue/return operators without exception oprators.
this is more faster than using the exception operators.
because on compiled, those performance are not better than condition operators.
so there macros transalte formula to the formula with just condition operators.

# provide macros

there are faster than using `catch/throw` exception.
but, there are has some limitation.

1. `goot-break` `goot-continue` and `goot-return` should put on the last of list.
2. `goot-break` `goot-continue` and `goot-return` dont put in the some functions argument.
you can put in the progn, prog1, prog2, if, and, or, when, unless and anymore.

* `(goot-break)`
    * this transform to symbol of `goot-break`. `goot-break` is used to hint to the transforming in internal macro of `goot-base`.
* `(goot-continue)`
    * this transform to symbol of `goot-continue`. `goot-continue` is used to hint to the transforming in internal macro of `goot-base`.
* `(goot-return &optional value)`
    * this transform to a formula that contain goot-break and goot-return. `goot-return` is used to hint to the transforming in internal macro of `goot-base`.
* `(goot-forever &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-while condition &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was failed. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-until condition &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was successed. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-for condition increment &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was failed. you can repeat this section from the beginning with using `goot-continue` oprator. *increment* is evaluate always at end of loop.
* `(goot-block &rest body)`
    * this evaluate *body* section one times. you can repeat or abort this section with `goot-break` or `goot-continue` oprators.

# provide optimized macros

there are little faster than other macros in goot.el.
but, there has more limitation.

1. there macros cannot use the some operators.
some operators should return a nil if condition was failed.
for example, the condition operator of `or` is cannot use to there macros.
because `or` operator cannot promise that return a nil if condition was failed.

* `(goot-forevermad &rest body)`
    * same as `goot-forever`
* `(goot-whilemad condition &rest body)`
    * same as `goot-while`
* `(goot-untilmad condition &rest body)`
    * same as `goot-until`
* `(goot-formad condition increment &rest body)`
    * same as `goot-for`
* `(goot-blockmad &rest body)`
    * same as `goot-block`

# performance

I included a [goot-bench.el](goot-bench.el) in this repositry.

## not compiled

in this result, while only is most faster.
goot-forever and goot-forevermad is fast a little,
because that are expand `(incf sum num)` and `(decf num)` to place of condition in while oprator,
that should expand to place of body in while oprator if want get more faster.

| using | spend time | how many faster |
| --- | --- | --- |
| while only | 0.251511 sec | 45% faster |
| goot-forevermad | 0.277954 sec | 25% faster |
| goot-forever | 0.332029 sec | 10% faster |
| catch/throw | 0.372102 sec | 0% faster |

## compiled

in this result, goot-forever and goot-forevermad preformance benefited from compiled.
surprisingly goot-forevermad is fast as while only.
but a function of catch/throw is not faster than other functions.

| using | spend time | how many faster |
| --- | --- | --- |
| while only | 0.045474 sec | 72% faster |
| goot-forevermad | 0.045242 sec | 72% faster |
| goot-forever | 0.053141 sec | 68% faster |
| catch/throw | 0.167039 sec | 0% faster |

# licence

this was released under the MIT License.
