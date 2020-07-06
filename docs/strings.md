# Strings

## Introduction

This chapter introduces you to string manipulation in R. You'll learn the basics of how strings work and how to create them by hand, but the focus of this chapter will be on regular expressions, or regexps for short. Regular expressions are useful because strings usually contain unstructured or semi-structured data, and regexps are a concise language for describing patterns in strings. When you first look at a regexp, you'll think a cat walked across your keyboard, but as your understanding improves they will soon start to make sense.

### Prerequisites

This chapter will focus on the __stringr__ package for string manipulation, which is part of the core tidyverse.


```python
import pandas as pd
import altair as alt
import numpy as np
```

## String basics

You can create strings with either single quotes or double quotes. You can read the pandas user guide on [working with text data](https://pandas.pydata.org/docs/user_guide/text.html) for more details.


```python
string1 = "This is a string"
string2 = 'If I want to include a "quote" inside a string, I use single quotes'
```

To include a literal single or double quote in a string you can use `\` to "escape" it:


```python
double_quote = "\"" # or '"'
single_quote = '\'' # or "'"
```

That means if you want to include a literal backslash, you'll need to double it up: `"\\"`.

Beware that the printed representation of a string is not the same as string itself, because the printed representation shows the escapes:


```python
x = "\" \\"
x
#> '" \\'
print(x)
#> " \
```

There are a handful of other special characters. The most common are `"\n"`, newline, and `"\t"`, tab, but you can see the complete list in the [Python reference manual](https://docs.python.org/2.0/ref/strings.html). You'll also sometimes see strings like `"\u00b5"`, this is a way of writing non-English characters that works on all platforms:


```python
x = "\u00b5"
x
#> 'µ'
```

Multiple strings are often stored in a object series, which you can create with `[]`:


```python
pd.Series(["one", "two", "three"])
#> 0      one
#> 1      two
#> 2    three
#> dtype: object
```

### String length

Python contains many functions to work with strings. We'll use the functions from pandas for use on series. These all start with `str`. For example, `str.length()` tells you the number of characters in a string:


```python
pd.Series(["a", "R for data science", np.nan]).str.len()
#> 0     1.0
#> 1    18.0
#> 2     NaN
#> dtype: float64
```

### Combining strings

To combine two or more strings, use `str_c()`:


```python
pd.Series(["x", "y"]).str.cat()
#> 'xy'
pd.Series(["x", "y", "z"]).str.cat()
#> 'xyz'
```

Use the `sep` argument to control how they're separated:


```python
pd.Series(["x", "y"]).str.cat(sep = '_')
#> 'x_y'
```

Like most other functions in Python, missing values are contagious. If you want them to print as `"NA"`, use `fillna()` or `na_rep = 'NA'`:


```python
x = pd.Series(["abc", np.nan])
x.str.cat()
#> 'abc'
x.str.cat(na_rep = "NA")
#> 'abcNA'
x.fillna('NA').str.cat()
#> 'abcNA'
```

### Subsetting strings

You can extract parts of a string using `str[]`. As well as the string, `str[]` takes `start:end` arguments which give the (inclusive) position of the substring:


```python
x = pd.Series(["Apple", "Banana", "Pear"])
x.str[0:3]
# negative numbers count backwards from end
#> 0    App
#> 1    Ban
#> 2    Pea
#> dtype: object
x.str[-3:]
#> 0    ple
#> 1    ana
#> 2    ear
#> dtype: object
```

Note that `str[]` won't fail if the string is too short: it will just return as much as possible:


```python
pd.Series(["a"]).str[0:5]
#> 0    a
#> dtype: object
```

You can also use the assign strings using `str.slice_replace()` to modify strings:


```python
x.str.slice_replace(0,0, repl = "5")
#> 0    5abc
#> 1     NaN
#> dtype: object
```

## Matching patterns with regular expressions

Regexps are a very terse language that allow you to describe patterns in strings. They take a little while to get your head around, but once you understand them, you'll find them extremely useful.

### Basic matches

The simplest patterns match exact strings:


```python
x = pd.Series(["apple", "banana", "pear"])
x.str.replace("an", "-M-")
#> 0       apple
#> 1    b-M--M-a
#> 2        pear
#> dtype: object
```

The next step up in complexity is `.`, which matches any character (except a newline):


```python
x.str.replace(".a.", "-M-")
#> 0     Apple
#> 1    -M-ana
#> 2      P-M-
#> dtype: object
```

But if "`.`" matches any character, how do you match the character "`.`"? You need to use an "escape" to tell the regular expression you want to match it exactly, not use its special behaviour. Like strings, regexps use the backslash, `\`, to escape special behaviour. So to match an `.`, you need the regexp `\.`. Unfortunately this creates a problem. We use strings to represent regular expressions, and `\` is also used as an escape symbol in strings. So to create the regular expression `\.` we need the string `"\\."`.


```python
# To create the regular expression, we need \\
dot = '\\.'

# But the expression itself only contains one:
print(dot)

# And this tells pandas to look for an explicit .
#> \.
pd.Series(["abc", "a.c", "bef"]).replace('a\\.c', '-M-', regex=True)
#> 0    abc
#> 1    -M-
#> 2    bef
#> dtype: object
```

If `\` is used as an escape character in regular expressions, how do you match a literal `\`? Well you need to escape it, creating the regular expression `\\`. To create that regular expression, you need to use a string, which also needs to escape `\`. That means to match a literal `\` you need to write `"\\\\"` --- you need four backslashes to match one!


```python
x = pd.Series(["a\\b"])
print(x)
#> 0    a\b
#> dtype: object
x.replace('\\\\', '-M-', regex = True)
#> 0    a-M-b
#> dtype: object
```

In this book, I'll write regular expression as `\.` and strings that represent the regular expression as `"\\."`.

#### Exercises

1.  Explain why each of these strings don't match a `\`: `"\"`, `"\\"`, `"\\\"`.

1.  How would you match the sequence `"'\`?

### Anchors

By default, regular expressions will match any part of a string. It's often useful to _anchor_ the regular expression so that it matches from the start or end of the string. You can use:

* `^` to match the start of the string.
* `$` to match the end of the string.

You can also use pandas `startwith()` and `endswith()` that work similiar but return booleans.


```python
x = pd.Series(["apple", "banana", "pear"])
x.str.replace("^a", "-M-")
#> 0    -M-pple
#> 1     banana
#> 2       pear
#> dtype: object
x.str.replace("a$", "-M-")
#> 0       apple
#> 1    banan-M-
#> 2        pear
#> dtype: object
```

To remember which is which, try this mnemonic which I learned from [Evan Misshula](https://twitter.com/emisshula/status/323863393167613953): if you begin with power (`^`), you end up with money (`$`).

To force a regular expression to only match a complete string, anchor it with both `^` and `$`:


```python
x = pd.Series(["apple pie", "apple", "apple cake"])
x.str.replace("apple", "-M-")
#> 0     -M- pie
#> 1         -M-
#> 2    -M- cake
#> dtype: object
x.str.replace("^apple$", "-M-")
#> 0     apple pie
#> 1           -M-
#> 2    apple cake
#> dtype: object
```

You can also match the boundary between words with `\b`. I don't often use this in Python, but I will sometimes use it when I'm doing a search to find the name of a function that's a component of other functions. For example, I'll search for `\bsum\b` to avoid matching `summarise`, `summary`, `rowsum` and so on.

#### Exercises

1.  How would you match the literal string `"$^$"`?

### Character classes and alternatives

There are a number of special patterns that match more than one character. You've already seen `.`, which matches any character apart from a newline. There are four other useful tools:

* `\d`: matches any digit.
* `\s`: matches any whitespace (e.g. space, tab, newline).
* `[abc]`: matches a, b, or c.
* `[^abc]`: matches anything except a, b, or c.

Remember, to create a regular expression containing `\d` or `\s`, you'll need to escape the `\` for the string, so you'll type `"\\d"` or `"\\s"`.

A character class containing a single character is a nice alternative to backslash escapes when you want to include a single metacharacter in a regex. Many people find this more readable.


```python
# Look for a literal character that normally has special meaning in a regex
x = pd.Series(["abc", "a.c", "a*c", "a c"])
x.str.replace("a[.]c", "-M-")
#> 0    abc
#> 1    -M-
#> 2    a*c
#> 3    a c
#> dtype: object
x.str.replace(".[*]c", "-M-")
#> 0    abc
#> 1    a.c
#> 2    -M-
#> 3    a c
#> dtype: object
x.str.replace("a[ ]", "-M-")
#> 0     abc
#> 1     a.c
#> 2     a*c
#> 3    -M-c
#> dtype: object
```

This works for most (but not all) regex metacharacters: `$` `.` `|` `?` `*` `+` `(` `)` `[` `{`. Unfortunately, a few characters have special meaning even inside a character class and must be handled with backslash escapes: `]` `\` `^` and `-`.

You can use _alternation_ to pick between one or more alternative patterns. For example, `abc|d..f` will match either '"abc"', or `"deaf"`. Note that the precedence for `|` is low, so that `abc|xyz` matches `abc` or `xyz` not `abcyz` or `abxyz`. Like with mathematical expressions, if precedence ever gets confusing, use parentheses to make it clear what you want:


```python
pd.Series(["grey", "gray"]).str.replace("r(e|a)", "-M-")
#> 0    g-M-y
#> 1    g-M-y
#> dtype: object
```

#### Exercises

1.  Create regular expressions to find all words that:

    1. Start with a vowel.

    1. That only contain consonants. (Hint: thinking about matching
       "not"-vowels.)

    1. End with `ed`, but not with `eed`.

    1. End with `ing` or `ise`.

1.  Is "q" always followed by a "u"?

1.  Write a regular expression that matches a word if it's probably written
    in British English, not American English.

1.  Create a regular expression that will match telephone numbers as commonly
    written in your country.

### Repetition

The next step up in power involves controlling how many times a pattern matches:

* `?`: 0 or 1
* `+`: 1 or more
* `*`: 0 or more

Notice the use of `n = 1` which functions like the R package `stringr::str_<TYPE>` the default argument for `str.replace()` of `n = -1` functions like `stringr::str_<TYPE>_all`.


```python
x = pd.Series(["1888 in Roman numerals: MDCCCLXXXVIII"])
x.str.replace("CC?", "-M-", n = 1)
#> 0    1888 in Roman numerals: MD-M-CLXXXVIII
#> dtype: object
x.str.replace("CC+", "-M-", n = 1)
#> 0    1888 in Roman numerals: MD-M-LXXXVIII
#> dtype: object
x.str.replace('C[LX]+', "-M-", n = 1)
#> 0    1888 in Roman numerals: MDCC-M-VIII
#> dtype: object
```

Note that the precedence of these operators is high, so you can write: `colou?r` to match either American or British spellings. That means most uses will need parentheses, like `bana(na)+`.

You can also specify the number of matches precisely:

* `{n}`: exactly n
* `{n,}`: n or more
* `{,m}`: at most m
* `{n,m}`: between n and m


```python
x.str.replace("C{2}", "-M-", n = 1)
#> 0    1888 in Roman numerals: MD-M-CLXXXVIII
#> dtype: object
x.str.replace("C{2,}", "-M-", n = 1)
#> 0    1888 in Roman numerals: MD-M-LXXXVIII
#> dtype: object
x.str.replace("C{2,3}", "-M-", n = 1)
#> 0    1888 in Roman numerals: MD-M-LXXXVIII
#> dtype: object
```

By default these matches are "greedy": they will match the longest string possible. You can make them "lazy", matching the shortest string possible by putting a `?` after them. This is an advanced feature of regular expressions, but it's useful to know that it exists:


```python
x.str.replace("C{2,3}?", "-M-", n = 1)
#> 0    1888 in Roman numerals: MD-M-CLXXXVIII
#> dtype: object
x.str.replace('C[LX]+?', "-M-", n = 1)
#> 0    1888 in Roman numerals: MDCC-M-XXXVIII
#> dtype: object
```

#### Exercises

1.  Describe the equivalents of `?`, `+`, `*` in `{m,n}` form.

1.  Describe in words what these regular expressions match:
    (read carefully to see if I'm using a regular expression or a string
    that defines a regular expression.)

    1. `^.*$`
    1. `"\\{.+\\}"`
    1. `\d{4}-\d{2}-\d{2}`
    1. `"\\\\{4}"`

1.  Create regular expressions to find all words that:

    1. Start with three consonants.
    1. Have three or more vowels in a row.
    1. Have two or more vowel-consonant pairs in a row.

1.  Solve the beginner regexp crosswords at
    <https://regexcrossword.com/challenges/beginner>.

### Grouping and backreferences

We will use a few csv files that contain one column labeld `name`. The `fruit` names and `words` as taken from the `stringr::fruit` character vectors.


```python
fruit = pd.read_csv("https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/fruit/fruit.csv")
words = pd.read_csv("https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/words/words.csv")
fruit
#>            name
#> 0         apple
#> 1       apricot
#> 2       avocado
#> 3        banana
#> 4   bell pepper
#> ..          ...
#> 75   strawberry
#> 76    tamarillo
#> 77    tangerine
#> 78   ugli fruit
#> 79   watermelon
#> 
#> [80 rows x 1 columns]
words
#>           name
#> 0            a
#> 1         able
#> 2        about
#> 3     absolute
#> 4       accept
#> ..         ...
#> 975        yes
#> 976  yesterday
#> 977        yet
#> 978        you
#> 979      young
#> 
#> [980 rows x 1 columns]
```


Earlier, you learned about parentheses as a way to disambiguate complex expressions. Parentheses also create a _numbered_ capturing group (number 1, 2 etc.). A capturing group stores _the part of the string_ matched by the part of the regular expression inside the parentheses. You can refer to the same text as previously matched by a capturing group with _backreferences_, like `\1`, `\2` etc. For example, the following regular expression finds all fruits that have a repeated pair of letters.



```python
fruit[fruit['name'].str.contains('(..)\\1')]
#>            name
#> 3        banana
#> 19      coconut
#> 21     cucumber
#> 40       jujube
#> 55       papaya
#> 72  salal berry
#> 
#> /usr/local/lib/python3.7/site-packages/pandas/core/strings.py:1954: UserWarning: This pattern has match groups. To actually get the groups, use str.extract.
#>   return func(self, *args, **kwargs)
```

#### Exercises

1.  Describe, in words, what these expressions will match:

    1. `(.)\1\1`
    1. `"(.)(.)\\2\\1"`
    1. `(..)\1`
    1. `"(.).\\1.\\1"`
    1. `"(.)(.)(.).*\\3\\2\\1"`

1.  Construct regular expressions to match words that:

    1. Start and end with the same character.

    1. Contain a repeated pair of letters
       (e.g. "church" contains "ch" repeated twice.)

    1. Contain one letter repeated in at least three places
       (e.g. "eleven" contains three "e"s.)

## Tools

Now that you've learned the basics of regular expressions, it's time to learn how to apply them to real problems. In this section you'll learn a wide array of string functions that let you:

* Determine which strings match a pattern.
* Find the positions of matches.
* Extract the content of matches.
* Replace matches with new values.
* Split a string based on a match.

A word of caution before we continue: because regular expressions are so powerful, it's easy to try and solve every problem with a single regular expression. In the words of Jamie Zawinski:

> Some people, when confronted with a problem, think “I know, I’ll use regular
> expressions.” Now they have two problems.

As a cautionary tale, check out this regular expression that checks if a email address is valid:

```
(?:(?:\r\n)?[ \t])*(?:(?:(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t]
)+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:
\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(
?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[
\t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\0
31]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\
](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+
(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:
(?:\r\n)?[ \t])*))*|(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z
|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)
?[ \t])*)*\<(?:(?:\r\n)?[ \t])*(?:@(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\
r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[
 \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)
?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t]
)*))*(?:,@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[
 \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*
)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t]
)+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*)
*:(?:(?:\r\n)?[ \t])*)?(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+
|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r
\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:
\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t
]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031
]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](
?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?
:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?
:\r\n)?[ \t])*))*\>(?:(?:\r\n)?[ \t])*)|(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?
:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?
[ \t]))*"(?:(?:\r\n)?[ \t])*)*:(?:(?:\r\n)?[ \t])*(?:(?:(?:[^()<>@,;:\\".\[\]
\000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|
\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>
@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"
(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t]
)*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\
".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?
:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[
\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*|(?:[^()<>@,;:\\".\[\] \000-
\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(
?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)*\<(?:(?:\r\n)?[ \t])*(?:@(?:[^()<>@,;
:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([
^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\"
.\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\
]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*(?:,@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\
[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\
r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\]
\000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]
|\\.)*\](?:(?:\r\n)?[ \t])*))*)*:(?:(?:\r\n)?[ \t])*)?(?:[^()<>@,;:\\".\[\] \0
00-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\
.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,
;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?
:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*
(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".
\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[
^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]
]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*\>(?:(?:\r\n)?[ \t])*)(?:,\s*(
?:(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\
".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(
?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[
\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t
])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t
])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?
:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|
\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*|(?:
[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\
]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)*\<(?:(?:\r\n)
?[ \t])*(?:@(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["
()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)
?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>
@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*(?:,@(?:(?:\r\n)?[
 \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,
;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t]
)*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\
".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*)*:(?:(?:\r\n)?[ \t])*)?
(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".
\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:
\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\[
"()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])
*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])
+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\
.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z
|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*\>(?:(
?:\r\n)?[ \t])*))*)?;\s*)
```

This is a somewhat pathological example (because email addresses are actually surprisingly complex), but is used in real code. See the stackoverflow discussion at <http://stackoverflow.com/a/201378> for more details.

Don't forget that you're in a programming language and you have other tools at your disposal. Instead of creating one complex regular expression, it's often easier to write a series of simpler regexps. If you get stuck trying to create a single regexp that solves your problem, take a step back and think if you could break the problem down into smaller pieces, solving each challenge before moving onto the next one.

### Detect matches

To determine if a character vector matches a pattern, use `str.contains()`. It returns a logical vector the same length as the input:


```python
x = pd.Series(["apple", "banana", "pear"])
x.str.contains("e")
#> 0     True
#> 1    False
#> 2     True
#> dtype: bool
```

Remember that when you use a logical vector in a numeric context, `FALSE` becomes 0 and `TRUE` becomes 1. That makes `sum()` and `mean()` useful if you want to answer questions about matches across a larger vector:


```python
# How many common words start with t?
words.name.str.contains("^t").sum()
# What proportion of common words end with a vowel?
#> 65
words.name.str.contains("[aeiou]$").mean()
#> 0.27653061224489794
```

When you have complex logical conditions (e.g. match a or b but not c unless d) it's often easier to combine multiple `str.contains()` calls with logical operators, rather than trying to create a single regular expression. For example, here are two ways to find all words that don't contain any vowels:


```python
# Find all words containing at least one vowel, and negate
no_vowels_1 = ~words.name.str.contains("[aeiou]")
# Find all words consisting only of consonants (non-vowels)
no_vowels_2 = words.name.str.contains("^[^aeiou]+$")
no_vowels_1.tolist() == no_vowels_2.tolist()
#> True
```

The results are identical, but I think the first approach is significantly easier to understand. If your regular expression gets overly complicated, try breaking it up into smaller pieces, giving each piece a name, and then combining the pieces with logical operations.

As you saw above, a common use of `str.containst()` is to select the elements that match a pattern:


```python
words[words['name'].str.contains("x$")]
#>     name
#> 107  box
#> 746  sex
#> 771  six
#> 840  tax
```

Typically, however, your strings will be one column of a data frame, and you'll want to use filter instead:


```python
df = pd.DataFrame({
    'words': words.name,
    'i': words.index})
df.query('words.str.contains("x$")')
#>     words    i
#> 107   box  107
#> 746   sex  746
#> 771   six  771
#> 840   tax  840
```


A variation on `str.contains()` is `str_count()`: rather than a simple yes or no, it tells you how many matches there are in a string:


```python
x = pd.Series(["apple", "banana", "pear"])
x.str.count("a")

# On average, how many vowels per word?
#> 0    1
#> 1    3
#> 2    1
#> dtype: int64
words.name.str.count("[aeiou]").mean()
#> 1.9918367346938775
```

You can use `str.count()` with `assign()`:


```python
df.assign(
    vowels = words.name.str.count("[aeiou]"),
    consonants = words.name.str.count("[^aeiou]")
)
#>          words    i  vowels  consonants
#> 0            a    0       1           0
#> 1         able    1       2           2
#> 2        about    2       3           2
#> 3     absolute    3       4           4
#> 4       accept    4       2           4
#> ..         ...  ...     ...         ...
#> 975        yes  975       1           2
#> 976  yesterday  976       3           6
#> 977        yet  977       1           2
#> 978        you  978       2           1
#> 979      young  979       2           3
#> 
#> [980 rows x 4 columns]
```

Note that matches never overlap. For example, in `"abababa"`, how many times will the pattern `"aba"` match? Regular expressions say two, not three:


```ppython
pd.Series(["abababa"]).str.count("aba")

```

#### Exercises

1.  For each of the following challenges, try solving it by using both a single
    regular expression, and a combination of multiple `str.contains()` calls.

    1.  Find all words that start or end with `x`.

    1.  Find all words that start with a vowel and end with a consonant.

    1.  Are there any words that contain at least one of each different
        vowel?

1.  What word has the highest number of vowels? What word has the highest
    proportion of vowels? (Hint: what is the denominator?)

### Extract matches

To extract the actual text of a match, use `str.extract()`. To show that off, we're going to need a more complicated example. I'm going to use the [Harvard sentences](https://en.wikipedia.org/wiki/Harvard_sentences), which were designed to test VOIP systems, but are also useful for practicing regexps. These are provided in `stringr::sentences`:


```python
sentences = pd.read_csv("https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/sentences/sentences.csv")
sentences.count
#> <bound method DataFrame.count of                                             name
#> 0     The birch canoe slid on the smooth planks.
#> 1    Glue the sheet to the dark blue background.
#> 2         It's easy to tell the depth of a well.
#> 3       These days a chicken leg is a rare dish.
#> 4           Rice is often served in round bowls.
#> ..                                           ...
#> 715      The grass and bushes were wet with dew.
#> 716         The blind man counted his old coins.
#> 717           A severe storm tore down the barn.
#> 718              She called his name many times.
#> 719        When you hear the bell, come quickly.
#> 
#> [720 rows x 1 columns]>
```

Imagine we want to find all sentences that contain a colour. We first create a vector of colour names, and then turn it into a single regular expression:


```python
colours = pd.Series(["red", "orange", "yellow", "green", "blue", "purple"])
colour_match = colours.str.cat(sep = "|")
colour_match
#> 'red|orange|yellow|green|blue|purple'
```

<!-- Now we can select the sentences that contain a colour, and then extract the colour to figure out which one it is: -->

<!-- ```{r} -->
<!-- has_colour <- str_subset(sentences, colour_match) -->
<!-- matches <- str_extract(has_colour, colour_match) -->
<!-- head(matches) -->
<!-- ``` -->

<!-- Note that `str_extract()` only extracts the first match. We can see that most easily by first selecting all the sentences that have more than 1 match: -->

<!-- ```{r} -->
<!-- more <- sentences[str_count(sentences, colour_match) > 1] -->
<!-- str_view_all(more, colour_match) -->

<!-- str_extract(more, colour_match) -->
<!-- ``` -->

<!-- This is a common pattern for stringr functions, because working with a single match allows you to use much simpler data structures. To get all matches, use `str_extract_all()`. It returns a list: -->

<!-- ```{r} -->
<!-- str_extract_all(more, colour_match) -->
<!-- ``` -->

<!-- You'll learn more about lists in [lists](#lists) and [iteration]. -->

<!-- If you use `simplify = TRUE`, `str_extract_all()` will return a matrix with short matches expanded to the same length as the longest: -->

<!-- ```{r} -->
<!-- str_extract_all(more, colour_match, simplify = TRUE) -->

<!-- x <- c("a", "a b", "a b c") -->
<!-- str_extract_all(x, "[a-z]", simplify = TRUE) -->
<!-- ``` -->

<!-- #### Exercises -->

<!-- 1.  In the previous example, you might have noticed that the regular -->
<!--     expression matched "flickered", which is not a colour. Modify the -->
<!--     regex to fix the problem. -->

<!-- 1.  From the Harvard sentences data, extract: -->

<!--     1. The first word from each sentence. -->
<!--     1. All words ending in `ing`. -->
<!--     1. All plurals. -->

<!-- ### Grouped matches -->

<!-- Earlier in this chapter we talked about the use of parentheses for clarifying precedence and for backreferences when matching. You can also use parentheses to extract parts of a complex match. For example, imagine we want to extract nouns from the sentences. As a heuristic, we'll look for any word that comes after "a" or "the". Defining a "word" in a regular expression is a little tricky, so here I use a simple approximation: a sequence of at least one character that isn't a space. -->

<!-- ```{r} -->
<!-- noun <- "(a|the) ([^ ]+)" -->

<!-- has_noun <- sentences %>% -->
<!--   str_subset(noun) %>% -->
<!--   head(10) -->
<!-- has_noun %>%  -->
<!--   str_extract(noun) -->
<!-- ``` -->

<!-- `str_extract()` gives us the complete match; `str_match()` gives each individual component. Instead of a character vector, it returns a matrix, with one column for the complete match followed by one column for each group: -->

<!-- ```{r} -->
<!-- has_noun %>%  -->
<!--   str_match(noun) -->
<!-- ``` -->

<!-- (Unsurprisingly, our heuristic for detecting nouns is poor, and also picks up adjectives like smooth and parked.) -->

<!-- If your data is in a tibble, it's often easier to use `tidyr::extract()`. It works like `str_match()` but requires you to name the matches, which are then placed in new columns: -->

<!-- ```{r} -->
<!-- tibble(sentence = sentences) %>%  -->
<!--   tidyr::extract( -->
<!--     sentence, c("article", "noun"), "(a|the) ([^ ]+)",  -->
<!--     remove = FALSE -->
<!--   ) -->
<!-- ``` -->

<!-- Like `str_extract()`, if you want all matches for each string, you'll need `str_match_all()`. -->

<!-- #### Exercises -->

<!-- 1. Find all words that come after a "number" like "one", "two", "three" etc. -->
<!--    Pull out both the number and the word. -->

<!-- 1. Find all contractions. Separate out the pieces before and after the  -->
<!--    apostrophe. -->

<!-- ### Replacing matches -->

<!-- `str_replace()` and `str_replace_all()` allow you to replace matches with new strings. The simplest use is to replace a pattern with a fixed string: -->

<!-- ```{r} -->
<!-- x <- c("apple", "pear", "banana") -->
<!-- str_replace(x, "[aeiou]", "-") -->
<!-- str_replace_all(x, "[aeiou]", "-") -->
<!-- ``` -->

<!-- With `str_replace_all()` you can perform multiple replacements by supplying a named vector: -->

<!-- ```{r} -->
<!-- x <- c("1 house", "2 cars", "3 people") -->
<!-- str_replace_all(x, c("1" = "one", "2" = "two", "3" = "three")) -->
<!-- ``` -->

<!-- Instead of replacing with a fixed string you can use backreferences to insert components of the match. In the following code, I flip the order of the second and third words. -->

<!-- ```{r} -->
<!-- sentences %>%  -->
<!--   str_replace("([^ ]+) ([^ ]+) ([^ ]+)", "\\1 \\3 \\2") %>%  -->
<!--   head(5) -->
<!-- ``` -->

<!-- #### Exercises -->

<!-- 1.   Replace all forward slashes in a string with backslashes. -->

<!-- 1.   Implement a simple version of `str_to_lower()` using `replace_all()`. -->

<!-- 1.   Switch the first and last letters in `words`. Which of those strings -->
<!--      are still words? -->

<!-- ### Splitting -->

<!-- Use `str_split()` to split a string up into pieces. For example, we could split sentences into words: -->

<!-- ```{r} -->
<!-- sentences %>% -->
<!--   head(5) %>%  -->
<!--   str_split(" ") -->
<!-- ``` -->

<!-- Because each component might contain a different number of pieces, this returns a list. If you're working with a length-1 vector, the easiest thing is to just extract the first element of the list: -->

<!-- ```{r} -->
<!-- "a|b|c|d" %>%  -->
<!--   str_split("\\|") %>%  -->
<!--   .[[1]] -->
<!-- ``` -->

<!-- Otherwise, like the other stringr functions that return a list, you can use `simplify = TRUE` to return a matrix: -->

<!-- ```{r} -->
<!-- sentences %>% -->
<!--   head(5) %>%  -->
<!--   str_split(" ", simplify = TRUE) -->
<!-- ``` -->

<!-- You can also request a maximum number of pieces: -->

<!-- ```{r} -->
<!-- fields <- c("Name: Hadley", "Country: NZ", "Age: 35") -->
<!-- fields %>% str_split(": ", n = 2, simplify = TRUE) -->
<!-- ``` -->

<!-- Instead of splitting up strings by patterns, you can also split up by character, line, sentence and word `boundary()`s: -->

<!-- ```{r} -->
<!-- x <- "This is a sentence.  This is another sentence." -->
<!-- str_view_all(x, boundary("word")) -->

<!-- str_split(x, " ")[[1]] -->
<!-- str_split(x, boundary("word"))[[1]] -->
<!-- ``` -->

<!-- #### Exercises -->

<!-- 1.  Split up a string like `"apples, pears, and bananas"` into individual -->
<!--     components. -->

<!-- 1.  Why is it better to split up by `boundary("word")` than `" "`? -->

<!-- 1.  What does splitting with an empty string (`""`) do? Experiment, and -->
<!--     then read the documentation. -->

<!-- ### Find matches -->

<!-- `str_locate()` and `str_locate_all()` give you the starting and ending positions of each match. These are particularly useful when none of the other functions does exactly what you want. You can use `str_locate()` to find the matching pattern, `str_sub()` to extract and/or modify them. -->

<!-- ## Other types of pattern -->

<!-- When you use a pattern that's a string, it's automatically wrapped into a call to `regex()`: -->

<!-- ```{r, eval = FALSE} -->
<!-- # The regular call: -->
<!-- str_view(fruit, "nana") -->
<!-- # Is shorthand for -->
<!-- str_view(fruit, regex("nana")) -->
<!-- ``` -->

<!-- You can use the other arguments of `regex()` to control details of the match: -->

<!-- *   `ignore_case = TRUE` allows characters to match either their uppercase or  -->
<!--     lowercase forms. This always uses the current locale. -->

<!--     ```{r} -->
<!--     bananas <- c("banana", "Banana", "BANANA") -->
<!--     str_view(bananas, "banana") -->
<!--     str_view(bananas, regex("banana", ignore_case = TRUE)) -->
<!--     ``` -->

<!-- *   `multiline = TRUE` allows `^` and `$` to match the start and end of each -->
<!--     line rather than the start and end of the complete string. -->

<!--     ```{r} -->
<!--     x <- "Line 1\nLine 2\nLine 3" -->
<!--     str_extract_all(x, "^Line")[[1]] -->
<!--     str_extract_all(x, regex("^Line", multiline = TRUE))[[1]] -->
<!--     ``` -->

<!-- *   `comments = TRUE` allows you to use comments and white space to make  -->
<!--     complex regular expressions more understandable. Spaces are ignored, as is  -->
<!--     everything after `#`. To match a literal space, you'll need to escape it:  -->
<!--     `"\\ "`. -->

<!--     ```{r} -->
<!--     phone <- regex(" -->
<!--       \\(?     # optional opening parens -->
<!--       (\\d{3}) # area code -->
<!--       [) -]?   # optional closing parens, space, or dash -->
<!--       (\\d{3}) # another three numbers -->
<!--       [ -]?    # optional space or dash -->
<!--       (\\d{3}) # three more numbers -->
<!--       ", comments = TRUE) -->

<!--     str_match("514-791-8141", phone) -->
<!--     ``` -->

<!-- *   `dotall = TRUE` allows `.` to match everything, including `\n`. -->

<!-- There are three other functions you can use instead of `regex()`: -->

<!-- *   `fixed()`: matches exactly the specified sequence of bytes. It ignores -->
<!--     all special regular expressions and operates at a very low level.  -->
<!--     This allows you to avoid complex escaping and can be much faster than  -->
<!--     regular expressions. The following microbenchmark shows that it's about -->
<!--     3x faster for a simple example. -->

<!--     ```{r} -->
<!--     microbenchmark::microbenchmark( -->
<!--       fixed = str_detect(sentences, fixed("the")), -->
<!--       regex = str_detect(sentences, "the"), -->
<!--       times = 20 -->
<!--     ) -->
<!--     ``` -->

<!--     Beware using `fixed()` with non-English data. It is problematic because  -->
<!--     there are often multiple ways of representing the same character. For  -->
<!--     example, there are two ways to define "á": either as a single character or  -->
<!--     as an "a" plus an accent: -->

<!--     ```{r} -->
<!--     a1 <- "\u00e1" -->
<!--     a2 <- "a\u0301" -->
<!--     c(a1, a2) -->
<!--     a1 == a2 -->
<!--     ``` -->

<!--     They render identically, but because they're defined differently,  -->
<!--     `fixed()` doesn't find a match. Instead, you can use `coll()`, defined -->
<!--     next, to respect human character comparison rules: -->

<!--     ```{r} -->
<!--     str_detect(a1, fixed(a2)) -->
<!--     str_detect(a1, coll(a2)) -->
<!--     ``` -->

<!-- *   `coll()`: compare strings using standard **coll**ation rules. This is  -->
<!--     useful for doing case insensitive matching. Note that `coll()` takes a -->
<!--     `locale` parameter that controls which rules are used for comparing -->
<!--     characters. Unfortunately different parts of the world use different rules! -->

<!--     ```{r} -->
<!--     # That means you also need to be aware of the difference -->
<!--     # when doing case insensitive matches: -->
<!--     i <- c("I", "İ", "i", "ı") -->
<!--     i -->

<!--     str_subset(i, coll("i", ignore_case = TRUE)) -->
<!--     str_subset(i, coll("i", ignore_case = TRUE, locale = "tr")) -->
<!--     ``` -->

<!--     Both `fixed()` and `regex()` have `ignore_case` arguments, but they -->
<!--     do not allow you to pick the locale: they always use the default locale. -->
<!--     You can see what that is with the following code; more on stringi -->
<!--     later. -->

<!--     ```{r} -->
<!--     stringi::stri_locale_info() -->
<!--     ``` -->

<!--     The downside of `coll()` is speed; because the rules for recognising which -->
<!--     characters are the same are complicated, `coll()` is relatively slow -->
<!--     compared to `regex()` and `fixed()`. -->

<!-- *   As you saw with `str_split()` you can use `boundary()` to match boundaries. -->
<!--     You can also use it with the other functions:  -->

<!--     ```{r} -->
<!--     x <- "This is a sentence." -->
<!--     str_view_all(x, boundary("word")) -->
<!--     str_extract_all(x, boundary("word")) -->
<!--     ``` -->

<!-- ### Exercises -->

<!-- 1.  How would you find all strings containing `\` with `regex()` vs. -->
<!--     with `fixed()`? -->

<!-- 1.  What are the five most common words in `sentences`? -->

<!-- ## Other uses of regular expressions -->

<!-- There are two useful function in base R that also use regular expressions: -->

<!-- *   `apropos()` searches all objects available from the global environment. This -->
<!--     is useful if you can't quite remember the name of the function. -->

<!--     ```{r} -->
<!--     apropos("replace") -->
<!--     ``` -->

<!-- *   `dir()` lists all the files in a directory. The `pattern` argument takes -->
<!--     a regular expression and only returns file names that match the pattern. -->
<!--     For example, you can find all the R Markdown files in the current -->
<!--     directory with: -->

<!--     ```{r} -->
<!--     head(dir(pattern = "\\.Rmd$")) -->
<!--     ``` -->

<!--     (If you're more comfortable with "globs" like `*.Rmd`, you can convert -->
<!--     them to regular expressions with `glob2rx()`): -->

<!-- ## stringi -->

<!-- stringr is built on top of the __stringi__ package. stringr is useful when you're learning because it exposes a minimal set of functions, which have been carefully picked to handle the most common string manipulation functions. stringi, on the other hand, is designed to be comprehensive. It contains almost every function you might ever need: stringi has 244 functions to stringr's 49. -->

<!-- If you find yourself struggling to do something in stringr, it's worth taking a look at stringi. The packages work very similarly, so you should be able to translate your stringr knowledge in a natural way. The main difference is the prefix: `str_` vs. `stri_`. -->

<!-- ### Exercises -->

<!-- 1.  Find the stringi functions that: -->

<!--     1. Count the number of words. -->
<!--     1. Find duplicated strings. -->
<!--     1. Generate random text. -->

<!-- 1.  How do you control the language that `stri_sort()` uses for  -->
<!--     sorting? -->
