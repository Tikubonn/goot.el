# goot.el

this provide some loop macros that support break/continue operators without exception oprators.

# provide macros

there are faster than using `catch/throw` exception.
but, there are has some limitation.

1. `goot-break` and `goot-continue` should place on the last of list.
1. `goot-break` and `goot-continue` dont place in the some functions argument (like not progn if etc...).

* `(goot-break)`
    * this transform to symbol of `goot-break`
* `(goot-continue)`
    * this transform to symbol of `goot-continue`
* `(goot-forever &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-while condition &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was failed. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-until condition &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was successed. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-for condition increment &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was failed. you can repeat this section from the beginning with using `goot-continue` oprator. *increment* is evaluate always at end of loop.
* `(goot-block &rest body)`
    * this evaluate *body* section one times. you can repeat or abort this section with `goot-break' or `goot-continue' oprators.

# provide optimized macros

there are little faster than other macros in goot.el.
but, there has more limitation.

* `(goot-forevermad &rest body)` same as `goot-forever`
* `(goot-whilemad condition &rest body)` same as `goot-while`
* `(goot-untilmad condition &rest body)` same as `goot-until`
* `(goot-formad condition increment &rest body)` same as `goot-for`
* `(goot-blockmad &rest body)` same as `goot-block`
