This assumes all text is on one line.

https://adventofcode.com/2024/day/3

This little explainer glosses over regex pretty heavily because I don't feel like explaining regex. Use `:h :s` and `:h pattern`. Also go learn sed(1).

# Part 1
For this part, I will be using the example text from the original problem
```
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
```
The general algorithm for this is to find all of the mul(x,y) expressions, pull out the numbers and put each pair on a line, multiply the numbers on each line, add all of the lines.

## 1. Change mul(x,y) to x*y
```
:s/mul(\(\d\{1,3\}\),\(\d\{1,3\}\))/\t\1*\2\r/g
```
### Explaination
`/mul(\(\d\{1,3\}\),\(\d\{1,3\}\))/` matches `mul(x,y)` where x and y are both 1-3 digit numbers. x gets placed in capture group 1, and y in capture group 2
`/\t\1*\2\r/` replaces the expression with a tab followed by `x*y` followed by a new line
This seperates all of the expressions to be at least on new lines, but will leave the preceding junk text before it. The logic behind this is that it at least gets the expressions seperated out and has a character that doesnt appear anywhere else in the text. (yes I am 100% sure this could be done in a vastly simpler way)
Oh also this will leave some junk on the last line. Just do `Gdd` to get rid of it
### Result
```
x	2*4
%&mul[3,7]!@^do_not_	5*5
+mul(32,64]then(	11*8
	8*5
```

## 2. Delete all text up to and including the tabs on each line
```
:%s/^.*\t/
```
### Explaination
Pretty simple, just match all characters up to and including the tab, then replace them with nothing.
### Result
```
2*4
5*5
11*8
8*5
```

## 3. Execute multiplication
```
YA=<C-r>=<C-r>"<CR><esc>0j
```
### Explaination
This is a macro that uses the expression register, `=` in vim to execute the multiplications.
This macro starts at the begining of a line and will move the cursor to the begining of the next line
Do `qq` to start recording the macro, do those keystrokes, then `q` to stop recording.
Repeat the macro for each line. (just do `<count>Q` with a count for the number of lines in the file. theres prob a better way to do this, idc)

`Y`: Yank the expression into the `"` register
`A=`: Enter insert mode at the end of the line and add a `=`
`<C-r>=`: `<C-r>` puts the contents of a register, in this case, the expression register, `=`. This is a special register that puts you in the command line, accepts and expression, then inserts the result at the cursor. (See `:h "=`)
`<C-r>"<CR>`: Put the contents of the `"` register, which is our multiplication expression, into the expression register. Pressing enter will evaluate the expression and place the result of the multiplication.
`<esc>0j`: Exit insert mode, go to the begining of the line, and go to the next line. This sets the cursor up for the next repetition of the macro
### Result
```
2*4=8
5*5=25
11*8=88
8*5=40
```

## 4. Delete the original expression, so its just the multiplication result
```
:%s/.*=/
```
### Explaination
I hope this ones pretty straighforward
### Result
```
8
25
88
40
```

## 5. Add numbers together in a stack
```
"add"bddO<C-r>=<C-r>a+<C-r>b<CR><esc>
```
### Explaination
This is another macro for each line. Do the same steps as the last step to set it up.

This macro will delete the current line and the next line, storing the first line in register `a` and the second in register `b`. Then it adds the contents of those registers together, and places it on a new line ABOVE the cursor. This gets repeated to accumulate the sum at the top line.

`"add` and `"bdd`: Delete the first line and store it in `a` and the second line in `b`
`O`: Open new line above
`<C-r>=`: Ditto
`<C-r>a+<C-r>b`: insert contents of a register, add a `+`, and insert the contents of the b register. This results in the following expression: `<first line>+<second line>`.
`<CR><esc>`: Evauate and insert the resulting sum, the return to normal mode, ready to repeat
### Result
```
161
```

# Part 2
This part uses a very similar algorithm, except it first leaves the lines as `mul(x,y)`, `do()` or `don't()`. Then it removes all of the lines after a `don't()` up until, and including a `do()`.
The initial example input doesn't really work too well for this and the actual problem text is too big to paste here. Just use your own or the one in this repo. The steps will show snippets generated from my input.

## 1. Put mul(x,y), do(), and don't() on individual lines with tabs seperating them from junk text
```
:s/\(mul(\d\{1,3\},\d\{1,3\})\)\|\(do()\)\|\(don't()\)/\t\1\2\3\r/g
```
### Explaination
This regex is very similar to the first one, except we don't capture the individual numbers and leave the full expressions. It also captures the `do()`s and `don't()`s. Then it replaces each of those expressions with itself preceded by a tab and followed by a newline. (Once again, delete the last line)
### Result
```
	mul(498,303)
;when()}!(%	mul(846,233)
...
:who()^%from()	mul(381,633)
why()@ when()where()?<;@#	do()
'< 	mul(643,715)
...
select()why()*{{:	mul(810,214)
	don't()
{what()/)who()*%	mul(273,606)
&]from()@:why()@	mul(788,896)
 }& 	don't()
select()	mul(568,713)
...
?')who()$?[>@	mul(420,163)
	mul(666,491)
$:+	do()
	mul(823,835)
{who()?,	mul(728,808)
...
```

## 2. Delete all text up to and including the tabs on each line
```
:%s/^.*\t/
```
### Explaination
Ditto
### Result
```
mul(498,303)
mul(846,233)
...
mul(381,633)
do()
mul(643,715)
...
mul(810,214)
don't()
mul(273,606)
mul(788,896)
don't()
mul(568,713)
...
mul(420,163)
mul(666,491)
do()
mul(823,835)
mul(728,808)
...
```

## 3. Delete all lines between a don't() and do()
```
/don't()<CR>V/do()<CR>d
```
### Explaination
Once again, this is a macro that starts at the begining of the file. This one ends a little weird because if it ends with an unmatched `don't()`, it won't find another `do()`, so it won't delete the lines below it. After you exhaust this macro, undo the last one and check that it worked correctly and delete the lines accordingly if it didn't. There's probably a much better way to do this.

`/don't()<CR>`: Search for next `don't()`
`V/do()<CR>`: Select until and including the next `do()` with visual line mode
`d`: Delete the selection
### Result
```
mul(498,303)
mul(846,233)
...
mul(381,633)
do()
mul(643,715)
...
mul(810,214)
mul(823,835)
mul(728,808)
...
```

## 4. Remove the left over `do()`s
```
:%s/do()\n/
```
### Explaination
Pretty self explainatory
### Result
```
mul(498,303)
mul(846,233)
...
mul(381,633)
mul(643,715)
...
mul(810,214)
mul(823,835)
mul(728,808)
...
```

## 5. Replace all mul expressions with x*y
```
:%s/mul(\(\d\{1,3\}\),\(\d\{1,3\}\))/\1*\2
```
### Explaination
Similar to the first step in part 1, match just the `mul(x,y)` and replace them with `x*y`
### Result
```
498*303
846*233
...
381*633
643*715
...
810*214
823*835
728*808
...
```

## 6. Execute multiplication
```
YA=<C-r>=<C-r>"<CR><esc>0j
```
### Explaination
Same as part 1
### Result
```
498*303=150894
846*233=197118
...
381*633=241173
643*715=459745
...
810*214=173340
823*835=687205
728*808=588224
...
```

## 7. Delete the original expression, so its just the multiplication result
```
:%s/.*=/
```
### Explaination
Ditto again
### Result
```
150894
197118
...
241173
459745
...
173340
687205
588224
...
```

## 8. Add numbers together in a stack
```
"add"bddO<C-r>=<C-r>a+<C-r>b<CR><esc>
```
### Explaination
you'll never guess what this one does
### Result
```
107069718
```

*I spent longer writting this than actually solving the problem*
