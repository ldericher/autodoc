# Really simple document

First, have some items:

- item 1
- item 2
- Another

Behold, for there is jumbled mess ahead!

1. This is
3. weirdly numbered
9. but pandoc doesn't care
2. it just works™

With the default HTML template, this does not translate: \textsl{Have some \LaTeX, too!}  
Some math is fine with HTML: $x=5$, some other is not: $\sqrt{x}=2$.  
However, both of these work with the `--webtex` switch for pandoc!

Code blocks? Sure!

    while (energy <= 0.42) {
      drinkCoffee();
    }

Need syntax? Here you go!

```c
#include <stdio.h>

int main() {
  printf("Hello World!\n");
}
```

For more awesome stuff, visit the pandoc manual: <https://pandoc.org/MANUAL.html#pandocs-markdown>
