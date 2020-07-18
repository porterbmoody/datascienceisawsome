# Markdown

## Introduction

Markdown provides a simple to use plain text syntax to make writing easier. It is especially useful for data scientists. Markdown documents support dozens of output formats, like PDFs, Word files, slideshows, and more. 

## Markdown basics

This is a Markdown file, a plain text file that has the extension `.md` or `.MD`:


````
# Diamond Sizes

```python
# setup
import altair as alt
import pandas as pd
import numpy as np
alt.data_transformers.enable('json')
```

```python
# load and format data
diamonds = pd.read_csv("https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/diamonds/diamonds.csv")
smaller = diamonds.query('carat <= 2.5')
```

We have data about diamonds. Only those larger than 2.5 carats. The distribution of the remainder is shown below:

```python
# plot data
chart = (alt.Chart(smaller).
    encode(alt.X('carat'), alt.Y('count()')).
    mark_line())

chart.save('markdown/diamonds_25.png')
```

![](diamonds_25.png)
````

It contains two important types of content:

1.  __Chunks__ of code surrounded by ```` ``` ````.
1.  Text mixed with simple text formatting like `# heading` and `_italics_`.

When you open a `.md` in VS code, you see a text file where code and output can be interleaved. To produce a complete pdf report containing the text, formatted code chunks, and charts you can install the [Markdown PDF extension](https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf) for VS Code (note their instructions about installation if you run into any errors). Once installed, you can create a pdf, html or png report by using the VS code command pallete hotkey `Ctrl + Shift + P` (`Cmd + Shift + P` for Mac) and then search using the keyword `export`. This will create a report in the same folder of the `.md` file with the same file name and the chosen export extension.


\begin{center}\includegraphics[width=0.75\linewidth]{markdown/diamond-sizes-report} \end{center}

When you __export__ the document, the Markdown PDF extension sends the .md file to __chromium__, which then builds the report. To get started with your own `.md` file, simply create a new file and use the extension `.md`. The following sections dive into the two components of a Markdown document in more details: the markdown text, the code chunks.

## Text formatting with Markdown

Prose in `.md` files is written in Markdown, a lightweight set of conventions for formatting plain text files. Markdown is designed to be easy to read and easy to write. It is also very easy to learn. The guide below shows how to use Markdown.


```
Text formatting 
------------------------------------------------------------

*italic*  or _italic_
**bold**   __bold__
`code`
superscript^2^ and subscript~2~

Headings
------------------------------------------------------------

# 1st Level Header

## 2nd Level Header

### 3rd Level Header

Lists
------------------------------------------------------------

*   Bulleted list item 1

*   Item 2

    * Item 2a

    * Item 2b

1.  Numbered list item 1

1.  Item 2. The numbers are incremented automatically in the output.

Links and images
------------------------------------------------------------

<http://example.com>

[linked phrase](http://example.com)

![optional caption text](path/to/img.png)

Tables 
------------------------------------------------------------

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell
```

The best way to learn these is simply to try them out. It will take a few days, but soon they will become second nature, and you won't need to think about them. If you forget, you can use the Markdown snippets that are built into VS code. Use `^Space` (`ctrl+Space` on a mac) to get a context specific list of suggestions.

### Exercises

1.  Practice what you've learned by creating a brief CV. The title should be
    your name, and you should include headings for (at least) education or
    employment. Each of the sections should include a bulleted list of
    jobs/degrees. Highlight the year in bold.
    
1.  Using the VS code snippet suggestions, figure out how to:

    1.  Add a footnote.
    1.  Add a horizontal rule.
    1.  Add a block quote.
    

## Code chunks

To display code inside a Markdown document, you need to insert a chunk. There are two ways to do so:

1. The keyboard shortcut `^Space` (`ctrl+Space` on a mac) then typing `code ` and selecting __fenced code block__

1. By manually typing the chunk delimiters ` ```python ` and ` ``` `.

Obviously, I'd recommend you learn the keyboard shortcut. It will save you time in the long run!

### Tables

Markdown has functionality for displaying tables using their table format.  Notice the readability and how the colons are used to set the text alignment in the column.

- To left-align the column, replace the leftmost dash with a colon, `:---`.
- To right-align the column, replace the rightmost dash with a colon, `---:`.
- To center-align the column, both the leftmost and rightmost dashes with a colon, `:---:`

```
|    |   carat | cut     | color   | clarity   |
|---:|--------:|:--------|:--------|:----------|
|  0 |    0.23 | Ideal   | E       | SI2       |
|  1 |    0.21 | Premium | E       | SI1       |
|  2 |    0.23 | Good    | E       | VS1       |
|  3 |    0.29 | Premium | I       | VS2       |
|  4 |    0.31 | Good    | J       | SI2       |
```

When displaying tables from your pandas dataFrames, you can use `.to_markdown()`. The above Markdown table was generated using the following:


```python
print(smaller.
    filter(['carat', 'cut', 'color', 'clarity']).
    rename_axis(None).
    head().
    to_markdown())
```

There is one other way to display Python code in a Markdown document: directly into the text, with:  `x = 5`. 

## Learning more

There are two important topics that we haven't covered here: collaboration, and the details of accurately communicating your ideas to other humans. Collaboration is a vital part of modern data science, and you can make your life much easier by using version control tools, like Git and GitHub. We recommend two free resources that will teach you about Git:

1.  Microsoft provides a webpage titled "Working with GitHub in VS Code" to help you with GitHub integrations:     <https://code.visualstudio.com/docs/editor/github>
    
1.  Microsoft's learning documents provides further training on Git: <https://docs.microsoft.com/en-us/learn/modules/use-git-from-vs-code/>.

I have also not touched on what you should actually write in order to clearly communicate the results of your analysis. To improve your writing, I highly recommend reading either [_Style: Lessons in Clarity and Grace_](https://amzn.com/0134080416) by Joseph M. Williams & Joseph Bizup, or [_The Sense of Structure: Writing from the Reader's Perspective_](https://amzn.com/0205296327) by George Gopen. Both books will help you understand the structure of sentences and paragraphs, and give you the tools to make your writing more clear. (These books are rather expensive if purchased new, but they're used by many English classes so there are plenty of cheap second-hand copies). George Gopen also has a number of short articles on writing at <https://www.georgegopen.com/the-litigation-articles.html>. They are aimed at lawyers, but almost everything applies to data scientists too. 
  
