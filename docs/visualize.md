# Data visualisation




## Introduction

> "The simple graph has brought more information to the data analyst’s mind 
> than any other device." --- John Tukey

This chapter will teach you how to visualise your data using Altair. Python has several systems for making graphs, but altiar is one of the most elegant and versatile. Altair implements the __declarative visualization__ much like the __grammar of graphics__, a coherent system for describing and building graphs. With altair, you can do more faster by learning one system and applying it in many places.

If you'd like to learn more about Altair before you start, I'd recommend reading "Altair: Interactive Statistical Visualizations for Python", <https://joss.theoj.org/papers/10.21105/joss.01057.pdf>.

We should note that we are building this book using R with the package bookdown.  Rendering Altair graphics using a python chunk is not straight forward but is not important for our use in VS Code. In VS Code the example chunks will render in the interactive Python viewer automatically. The following R code chunks show how we are rendering the Altair graphics in this book. Thanks to ijlyttle for [his GitHub Gist](https://gist.github.com/ijlyttle/aa314d02b5f7f85702ea2a648393b21f).

```

# ```{R, echo=FALSE}
# vegawidget::as_vegaspec(py$chart$to_json())
# ```

# For Python examples that show chart.save()

#```{r, message = FALSE, echo=FALSE}
#knitr::include_graphics("screenshots/chartp_chartleft.png")
#```

```

### Prerequisites

This chapter focusses on Altair. Language has been shifted using the material from [Altair's materials](https://altair-viz.github.io/index.html). To access the datasets, help pages, and functions that we will use in this chapter, load the Python data science tools by running this code:


```python

import pandas as pd   
import altair as alt   
```

If you run this code and get the error message "No module named 'altair'" or "No module named 'pandas'", you'll need to first install them.


```bash
python -m pip install pandas altair
```

You only need to install a package once, but you need to reload it every time you start a new session.

## First steps

Let's use our first graph to answer a question: Do cars with big engines use more fuel than cars with small engines? You probably already have an answer, but try to make your answer precise. What does the relationship between engine size and fuel efficiency look like? Is it positive? Negative? Linear? Nonlinear?

### The `mpg` data frame

You can test your answer with the `mpg` __data frame__ found in ggplot2 (aka  `ggplot2::mpg`). A data frame is a rectangular collection of variables (in the columns) and observations (in the rows). The *'mpg'* data contains observations collected by the US Environmental Protection Agency on 38 models of car. We will identify the *'mpg'* data using `mpg` for the remainder of this introduction.


```python

mpg = pd.read_csv("https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/mpg/mpg.csv")
```

Among the variables in `mpg` are:

1. `displ`, a car's engine size, in litres.

1. `hwy`, a car's fuel efficiency on the highway, in miles per gallon (mpg). 
  A car with a low fuel efficiency consumes more fuel than a car with a high 
  fuel efficiency when they travel the same distance. 

To learn more about `mpg`, read informat at [data4python4ds](https://github.com/byuidatascience/data4python4ds/blob/master/data.md).

### Creating an Altair plot

To plot `mpg`, run this code to put `displ` on the x-axis and `hwy` on the y-axis:


```python

chart = (alt.Chart(mpg).
  mark_point().
  encode(
    x='displ', 
    y='hwy')
  )
```



\begin{center}\includegraphics[width=0.7\linewidth]{visualize_files/figure-latex/unnamed-chunk-6-1} 

The plot shows a negative relationship between engine size (`displ`) and fuel efficiency (`hwy`). In other words, cars with big engines use more fuel. Does this confirm or refute your hypothesis about fuel efficiency and engine size?

With Altair, you begin a plot with the function `Chart()`. `Chart()` creates a Chart object that you can add layers to. The only argument of `Chart()` is the dataset to use in the graph. So `Chart(mpg)` creates an Chart object upon which we can marks.

You complete your graph by adding one or more marks to `Chart()`. The attribute `mark_point()` adds a layer of points to your plot, which creates a scatterplot. Altair comes with many mark methods that each add a different type of layer to a plot. You'll learn a whole bunch of them throughout this chapter.

Each mark method in Altair has an `encode()` attribute. This defines how variables in your dataset are encoded to visual properties. The `encode()` method is always paired with `x` and `y` arguments to specify which variables to map to the x and y axes. Altair looks for the encoded variables in the `data` argument, in this case, `mpg`. For pandas dataframes, Altair automatically determines the appropriate data type for the mapped column.

### A graphing template

Let's turn this code into a reusable template for making graphs with ggplot2. To make a graph, replace the bracketed sections in the code below with a dataset, a geom function, or a collection of mappings.


```python
(alt.Chart(<DATA>).  
  <mark_*().>
  encode(<ENCODINGS>))
```

The rest of this chapter will show you how to complete and extend this template to make different types of graphs. We will begin with the `<ENCODINGS>` component.

### Exercises

1.  Run `Chart(mpg).mark_points()`. What do you see?

1.  How many rows are in `mpg`? How many columns?

1.  What does the `drv` variable describe?  

1.  Make a scatterplot of `hwy` vs `cyl`.

1.  What happens if you make a scatterplot of `class` vs `drv`? Why is
    the plot not useful?

## Aesthetic mappings

> "The greatest value of a picture is when it forces us to notice what we
> never expected to see." --- John Tukey

In the plot below, one group of points (highlighted in red) seems to fall outside of the linear trend. These cars have a higher mileage than you might expect. How can you explain these cars?




\begin{flushleft}\includegraphics[width=0.7\linewidth]{screenshots/altair_condition_chart} \end{flushleft}


Let's hypothesize that the cars are hybrids. One way to test this hypothesis is to look at the `class` value for each car. The `class` variable of the `mpg` dataset classifies cars into groups such as compact, midsize, and SUV. If the outlying points are hybrids, they should be classified as compact cars or, perhaps, subcompact cars (keep in mind that this data was collected before hybrid trucks and SUVs became popular).

You can add a third variable, like `class`, to a two dimensional scatterplot by mapping it to an __encoding__. An encoding is a visual property of the objects in your plot. Encodings include things like the size, the shape, or the color of your points. You can display a point (like the one below) in different ways by changing the values of its encoded properties. Since we already use the word "value" to describe data, let's use the word "level" to describe encoded properties. Here we change the levels of a point's size, shape, and color to make the point small, triangular, or blue:


\begin{center}\includegraphics[width=0.7\linewidth]{visualize_files/figure-latex/unnamed-chunk-10-1} \end{center}

You can convey information about your data by mapping the encodings in your plot to the variables in your dataset. For example, you can map the colors of your points to the `class` variable to reveal the class of each car.


```python

chart = (alt.Chart(mpg).
  mark_point().
  encode(
    x = "displ",
    y = "hwy",
    color = "class"
    )
  )
```


\begin{center}\includegraphics[width=0.7\linewidth]{visualize_files/figure-latex/unnamed-chunk-12-1} 

(We don't prefer British English, like Hadley, so don't use `colour` instead of `color`.)

To map an encoding to a variable, associate the name of the encoding to the name of the variable inside `encode()`. Altair will automatically assign a unique level of the encoding (here a unique color) to each unique value of the variable, a process known as __scaling__. Altair will also add a legend that explains which levels correspond to which values.

The colors reveal that many of the unusual points are two-seater cars. These cars don't seem like hybrids, and are, in fact, sports cars! Sports cars have large engines like SUVs and pickup trucks, but small bodies like midsize and compact cars, which improves their gas mileage. In hindsight, these cars were unlikely to be hybrids since they have large engines.

In the above example, we mapped `class` to the color encoding, but we could have mapped `class` to the size encoding in the same way. In this case, the exact size of each point would reveal its class affiliation. Mapping an unordered variable (`class`) to an ordered aesthetic (`size`) is not a good idea.


```python
chart = (alt.Chart(mpg).
  mark_point().
  encode(
    x = "displ",
    y = "hwy",
    size = "class"
    )
  )
```


\begin{center}\includegraphics[width=0.7\linewidth]{visualize_files/figure-latex/unnamed-chunk-14-1} 

Or we could have mapped `class` to the _opacity_ encoding, which controls the transparency of the points, or to the shape encoding, which controls the shape of the points.


```python
# First
chart1 = (alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy",
    opacity = "class"
    )
  )

# Second
chart2 = (alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy",
    shape = "class"
    )
  )
  
chart1.save("screenshots/altair_opacity.png")
#> WARN Channel opacity should not be used with an unsorted discrete field.
chart2.save("screenshots/altair_shape.png")
  
```



\includegraphics[width=0.5\linewidth]{screenshots/altair_opacity} \includegraphics[width=0.5\linewidth]{screenshots/altair_shape} 



Altair will only use 8 shapes for one chart. Charting more than 8 shapes is not recommended as the shapes simply recycle.

For each encoding, you use `encode()` to associate the name of the encoding with a variable to display. The `encode()` function gathers together each of the encoded mappings used by a layer and passes them to the layer's mapping argument. The syntax highlights a useful insight about `x` and `y`: the x and y locations of a point are themselves encodings, visual properties that you can map to variables to display information about the data.

Once you map an encoding, Altair takes care of the rest. It selects a reasonable scale to use with the encoding, and it constructs a legend that explains the mapping between levels and values. For x and y aesthetics, Altair does not create a legend, but it creates an axis line with tick marks and a label. The axis line acts as a legend; it explains the mapping between locations and values.

You can also _configure_ the encoding properties of your mark manually. For example, we can make all of the points in our plot blue:


```python

chart = (alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy",
    color = alt.value("blue")
    )
  )
```


\begin{center}\includegraphics[width=0.7\linewidth]{visualize_files/figure-latex/unnamed-chunk-18-1} 

Here, the color doesn't convey information about a variable, but only changes the appearance of the plot. To set an encoding manually, use `alt.value()` by name as an argument of your `encode()` function; i.e. the value goes _inside_ of `alt.value()`. You'll need to pick a level that makes sense for that encoding:

* The name of a color as a character string.

* The size of a point in pixels.

* The shape of a point as a character string.

Note that only a limited set of mark properties can be bound to encodings, so for some (e.g. fillOpacity, strokeOpacity, etc.) the encoding approach using `alt.value()` is not available. Encoding settings will always override local or global configuration settings. There are other methods for manually encoding properties as explained in the [Altair documentation](https://altair-viz.github.io/user_guide/customization.html)

### Exercises

1.  Which variables in `mpg` are categorical? Which variables are continuous?
    How can you see this information when you run `mpg`? (Hint `mpg.dtypes`)

1.  Map a continuous variable to `color`, `size`, and `shape`. How do
    these aesthetics behave differently for categorical vs. continuous
    variables?

1.  What happens if you map the same variable to multiple encodings?

1.  What does the `stroke` encoding do? What shapes does it work with?
    (Hint: use `mark_point()`)

## Common problems

As you start to run Python code, you're likely to run into problems. Don't worry --- it happens to everyone. I have been writing Python code for months, and every day I still write code that doesn't work!

Start by carefully comparing the code that you're running to the code in the book. Python is extremely picky, and a misplaced character can make all the difference. Make sure that every `(` is matched with a `)` and every `"` is paired with another `"`. 

One common problem when creating Altair graphics as shown in this book, is to put the `()` in the wrong place: the `(` comes before the `alt.chart()` command and the `)` has to come at the end of the command. 

For example the code below works in Python. 

```python
alt.Chart(mpg).mark_point(filled = True).encode(x = "displ", y = "hwy")
```

However, the complexity of the more details graphics necessicates placing the code on multiple lines. When using multiple lines we need the enclosing `()`. Make sure you haven't accidentally excluded a `(` or `)` like this

```Python
(alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy")
```

or placed the `()` incorrectly like this

```Python
(chart = alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy")
)    
```

If you're still stuck, try the help. You can get help about any Altair function from their website - <https://altair-viz.github.io/>, or hovering over the function name in VS Code. If that doesn't help, carefully read the error message. Sometimes the answer will be buried there! But when you're new to Python, the answer might be in the error message but you don't yet know how to understand it. Another great tool is Google: try googling the error message, as it's likely someone else has had the same problem, and has gotten help online.

## Facets

One way to add additional variables is with encodings. Another way, particularly useful for categorical variables, is to split your plot into __facets__, subplots that each display one subset of the data.

To facet your plot by a single variable, use `facet()`. The first argument of `facet()` is . The variable that you pass to `facet_wrap()` should be discrete.


```python
chart_f = (alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy",
   ).
   facet(
      facet = "class",
      columns = 4
    )
  )
  
chart_f.save("screenshots/altair_facet_1.png")
```


\begin{flushleft}\includegraphics[width=0.7\linewidth]{screenshots/altair_facet_1} \end{flushleft}


To facet your plot on the combination of two variables, The first argument of `facet()` is also `column` and the second is `row`. This time the formula should contain two variable names.


```python
chart_f2 = (alt.Chart(mpg).
  mark_point(filled = True).
  encode(
    x = "displ",
    y = "hwy",
   ).
   facet(
      column = "drv",
      row = "cyl"
    )
  )
  
chart_f2.save("screenshots/altair_facet_2.png")
#> WARN row encoding should be discrete (ordinal / nominal / binned).
```


\begin{flushleft}\includegraphics[width=0.7\linewidth]{screenshots/altair_facet_2} \end{flushleft}

If you prefer to not facet in the rows or columns dimension, simply remove that facet argument. You can read more about [compound charts in the Altair documentation](https://altair-viz.github.io/user_guide/compound_charts.html).

### Exercises

1.  What happens if you facet on a continuous variable?

1.  What do the empty cells in plot with `facet(column = "drv", row = "cyl")` mean?
    How do they relate to this plot?

    
    ```python
    (alt.Chart(mpg).
      mark_point().
      encode(
        x = "drv",
        y = "cyl")
    )
    ```

1.  What plots does the following code make? What does `.` do?

    
    ```python
    (alt.Chart(mpg).
      mark_point(filled = True).
      encode(
        x = "displ",
        y = "hwy").
      facet(column = "drv")
    )
    
    (alt.Chart(mpg).
      mark_point(filled = True).
      encode(
        x = "displ",
        y = "hwy").
      facet(row = "cyl")
    )
    ```

1.  Take the first faceted plot in this section:

    What are the advantages to using faceting instead of the colour aesthetic?
    What are the disadvantages? How might the balance change if you had a
    larger dataset?

1.  When using `facet()` you should usually put the variable with more
    unique levels in the columns. Why?

## Geometric objects

How are these two plots similar?


```python
chartp = (alt.Chart(mpg).
  mark_point().
  encode(
    x = "displ",
    y = "hwy"
    )
  )

chartf = (alt.Chart(mpg).
  encode(
    x = "displ",
    y = "hwy"
    ).
  transform_loess("displ", "hwy").
  mark_line()
  )

chartp.save("screenshots/altair_basic_points.png")  
chartf.save("screenshots/altair_smooth_line.png")
```
  


\includegraphics[width=0.5\linewidth]{screenshots/altair_basic_points} \includegraphics[width=0.5\linewidth]{screenshots/altair_smooth_line} 



Both plots contain the same x variable, the same y variable, and both describe the same data. But the plots are not identical. Each plot uses a different visual object to represent the data. In Altair syntax, we say that they use different __marks__.

A __mark__ is the geometrical object that a plot uses to represent data. People often describe plots by the type of mark that the plot uses. For example, bar charts use bar marks, line charts use line marks, boxplots use boxplot marks, and so on. Scatterplots break the trend; they use the point mark. As we see above, you can use different marks to plot the same data. The first plot uses the point mark, and the second plot uses the line mark, a smooth line fitted to the data is calculated using a transformation. To change the mark in your plot, change the mark function that you add to `Chart()`. 

Every mark function in Altair has `encode` arguments. However, not every encoding works with every mark. You could set the shape of a point, but you couldn't set the "shape" of a line. On the other hand, you _could_ set the type of line. `mark_line()` will draw a different line, with a different `strokeDash`, for each unique value of the variable that you map to `strokeDash`.



```python
chartl = (alt.Chart(mpg).
  transform_loess("displ", "hwy", groupby = ["drv"]).
  mark_line().
  encode(
    x = "displ",
    y = "hwy",
    strokeDash = "drv"
    )
  )
  

chartl.save("screenshots/altair_dashed_lines.png")

  
```


\begin{flushleft}\includegraphics[width=0.7\linewidth]{screenshots/altair_dashed_lines} \end{flushleft}



Here `mark_line()` separates the cars into three lines based on their `drv` value, which describes a car's drivetrain. One line describes all of the points with a `4` value, one line describes all of the points with an `f` value, and one line describes all of the points with an `r` value. Here, `4` stands for four-wheel drive, `f` for front-wheel drive, and `r` for rear-wheel drive.

If this sounds strange, we can make it more clear by overlaying the lines on top of the raw data and then coloring everything according to `drv`.




\begin{flushleft}\includegraphics[width=0.7\linewidth]{screenshots/altair_points_dashed_lines} \end{flushleft}

Notice that this plot contains two marks in the same graph! If this makes you excited, buckle up. We will learn how to place multiple marks on the same chart very soon.

Altair provides about 15 marks. The best way to get a comprehensive overview is the Altair marks page, which you can find at <https://altair-viz.github.io/user_guide/marks.html>. 

Many marks, like `mark_line()`, use a single mark object to display multiple rows of data. For these marks, you can set the `detail` encoding to a categorical variable to draw multiple objects. Altair will draw a separate object for each unique value of the detail variable. In practice, Altair will automatically group the data for these marks whenever you map an encoding to a discrete variable (as in the `strokeDash` example). It is convenient to rely on this feature because the detail encoding by itself does not add a legend or distinguishing features to the marks.



```python
chartleft = (alt.Chart(mpg).
  encode(
    x = "displ",
    y = "hwy",
  ).
  transform_loess("displ", "hwy").
  mark_line()
  
  )

chartmiddle = (alt.Chart(mpg).
  encode(
    x = "displ",
    y = "hwy",
    detail = "drv"
    ).
  transform_loess("displ", "hwy", groupby = ["drv"]).
  mark_line()
  )

chartright = (alt.Chart(mpg).
  encode(
    x = "displ",
    y = "hwy",
    color=alt.Color("drv", legend=None)
    ).
  transform_loess("displ", "hwy", groupby = ["drv"]).
  mark_line()
  )
chartleft.save("screenshots/altair_chartleft.png")
chartmiddle.save("screenshots/altair_chartmiddle.png")
chartright.save("screenshots/altair_chartright.png")

```




\includegraphics[width=0.33\linewidth]{screenshots/altair_chartleft} \includegraphics[width=0.33\linewidth]{screenshots/altair_chartmiddle} \includegraphics[width=0.33\linewidth]{screenshots/altair_chartright} 

To display multiple marks in the same plot, you can add multiple mark functions to `alt.Chart()` or used [layered charts](https://altair-viz.github.io/user_guide/compound_charts.html) as shown in the example below:


```python
chartp = (alt.Chart(mpg).
  encode(
    x = "displ",
    y = "hwy"
  ).
  mark_point()
)

chart = chartp + chartleft  

chart.save("screenshots/altair_chartcombine.png")
  
```



\begin{center}\includegraphics[width=0.7\linewidth]{screenshots/altair_chartcombine} \end{center}

This, however, introduces some duplication in our code. Imagine if you wanted to change the y-axis to display `cty` instead of `hwy`. You'd need to change the variable in two places, and you might forget to update one. You can avoid this type of repetition by passing a set of encodings to base `alt.Chart()`. Altair will treat these encodings as global encodings that apply to each mark in the chart.  In other words, this code will produce the same plot as the previous code:


```python
base =(alt.Chart(mpg).
  encode(
    x = "displ",
    y = "hwy"
  )
)

chart = base.mark_point() + base.transform_loess("displ", "hwy").mark_line()

chart.save("screenshots/altair_combine_clean.png")
  
```



\begin{center}\includegraphics[width=0.7\linewidth]{screenshots/altair_combine_clean} \end{center}
<!-- If you place mappings in a geom function, ggplot2 will treat them as local mappings for the layer. It will use these mappings to extend or overwrite the global mappings _for that layer only_. This makes it possible to display different aesthetics in different layers. -->

<!-- ```{r, message = FALSE} -->
<!-- ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--   geom_point(mapping = aes(color = class)) +  -->
<!--   geom_smooth() -->
<!-- ``` -->

<!-- You can use the same idea to specify different `data` for each layer. Here, our smooth line displays just a subset of the `mpg` dataset, the subcompact cars. The local data argument in `geom_smooth()` overrides the global data argument in `ggplot()` for that layer only. -->

<!-- ```{r, message = FALSE} -->
<!-- ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--   geom_point(mapping = aes(color = class)) +  -->
<!--   geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE) -->
<!-- ``` -->

<!-- (You'll learn how `filter()` works in the chapter on data transformations: for now, just know that this command selects only the subcompact cars.) -->

<!-- ### Exercises -->

<!-- 1.  What geom would you use to draw a line chart? A boxplot?  -->
<!--     A histogram? An area chart? -->

<!-- 1.  Run this code in your head and predict what the output will look like. -->
<!--     Then, run the code in R and check your predictions. -->

<!--     ```{r, eval = FALSE} -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +  -->
<!--       geom_point() +  -->
<!--       geom_smooth(se = FALSE) -->
<!--     ``` -->

<!-- 1.  What does `show.legend = FALSE` do?  What happens if you remove it?   -->
<!--     Why do you think I used it earlier in the chapter? -->

<!-- 1.  What does the `se` argument to `geom_smooth()` do? -->


<!-- 1.  Will these two graphs look different? Why/why not? -->

<!--     ```{r, eval = FALSE} -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_point() +  -->
<!--       geom_smooth() -->

<!--     ggplot() +  -->
<!--       geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy)) -->
<!--     ``` -->

<!-- 1.  Recreate the R code necessary to generate the following graphs. -->

<!--     ```{r echo = FALSE, fig.width = 3, out.width = "50%", fig.align = "default", message = FALSE} -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_point() +  -->
<!--       geom_smooth(se = FALSE) -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_smooth(aes(group = drv), se = FALSE) + -->
<!--       geom_point() -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +  -->
<!--       geom_point() +  -->
<!--       geom_smooth(se = FALSE) -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_point(aes(color = drv)) +  -->
<!--       geom_smooth(se = FALSE) -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_point(aes(color = drv)) + -->
<!--       geom_smooth(aes(linetype = drv), se = FALSE) -->
<!--     ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +  -->
<!--       geom_point(size = 4, colour = "white") +  -->
<!--       geom_point(aes(colour = drv)) -->
<!--     ``` -->

<!-- ## Statistical transformations -->

<!-- Next, let's take a look at a bar chart. Bar charts seem simple, but they are interesting because they reveal something subtle about plots. Consider a basic bar chart, as drawn with `geom_bar()`. The following chart displays the total number of diamonds in the `diamonds` dataset, grouped by `cut`. The `diamonds` dataset comes in ggplot2 and contains information about ~54,000 diamonds, including the `price`, `carat`, `color`, `clarity`, and `cut` of each diamond. The chart shows that more diamonds are available with high quality cuts than with low quality cuts.  -->

<!-- ```{r} -->
<!-- ggplot(data = diamonds) +  -->
<!--   geom_bar(mapping = aes(x = cut)) -->
<!-- ``` -->

<!-- On the x-axis, the chart displays `cut`, a variable from `diamonds`. On the y-axis, it displays count, but count is not a variable in `diamonds`! Where does count come from? Many graphs, like scatterplots, plot the raw values of your dataset. Other graphs, like bar charts, calculate new values to plot: -->

<!-- * bar charts, histograms, and frequency polygons bin your data  -->
<!--   and then plot bin counts, the number of points that fall in each bin. -->

<!-- * smoothers fit a model to your data and then plot predictions from the -->
<!--   model. -->

<!-- * boxplots compute a robust summary of the distribution and then display a  -->
<!--   specially formatted box. -->

<!-- The algorithm used to calculate new values for a graph is called a __stat__, short for statistical transformation. The figure below describes how this process works with `geom_bar()`. -->

<!-- ```{r, echo = FALSE, out.width = "100%"} -->
<!-- knitr::include_graphics("images/visualization-stat-bar.png") -->
<!-- ``` -->

<!-- You can learn which stat a geom uses by inspecting the default value for the `stat` argument. For example, `?geom_bar` shows that the default value for `stat` is "count", which means that `geom_bar()` uses `stat_count()`. `stat_count()` is documented on the same page as `geom_bar()`, and if you scroll down you can find a section called "Computed variables". That describes how it computes two new variables: `count` and `prop`. -->

<!-- You can generally use geoms and stats interchangeably. For example, you can recreate the previous plot using `stat_count()` instead of `geom_bar()`: -->

<!-- ```{r} -->
<!-- ggplot(data = diamonds) +  -->
<!--   stat_count(mapping = aes(x = cut)) -->
<!-- ``` -->

<!-- This works because every geom has a default stat; and every stat has a default geom. This means that you can typically use geoms without worrying about the underlying statistical transformation. There are three reasons you might need to use a stat explicitly: -->

<!-- 1.  You might want to override the default stat. In the code below, I change  -->
<!--     the stat of `geom_bar()` from count (the default) to identity. This lets  -->
<!--     me map the height of the bars to the raw values of a $y$ variable.  -->
<!--     Unfortunately when people talk about bar charts casually, they might be -->
<!--     referring to this type of bar chart, where the height of the bar is already -->
<!--     present in the data, or the previous bar chart where the height of the bar -->
<!--     is generated by counting rows. -->

<!--     ```{r, warning = FALSE} -->
<!--     demo <- tribble( -->
<!--       ~cut,         ~freq, -->
<!--       "Fair",       1610, -->
<!--       "Good",       4906, -->
<!--       "Very Good",  12082, -->
<!--       "Premium",    13791, -->
<!--       "Ideal",      21551 -->
<!--     ) -->

<!--     ggplot(data = demo) + -->
<!--       geom_bar(mapping = aes(x = cut, y = freq), stat = "identity") -->
<!--     ``` -->

<!--     (Don't worry that you haven't seen `<-` or `tribble()` before. You might be -->
<!--     able to guess at their meaning from the context, and you'll learn exactly -->
<!--     what they do soon!) -->

<!-- 1.  You might want to override the default mapping from transformed variables -->
<!--     to aesthetics. For example, you might want to display a bar chart of -->
<!--     proportion, rather than count: -->

<!--     ```{r} -->
<!--     ggplot(data = diamonds) +  -->
<!--       geom_bar(mapping = aes(x = cut, y = stat(prop), group = 1)) -->
<!--     ``` -->

<!--     To find the variables computed by the stat, look for the help section -->
<!--     titled "computed variables". -->

<!-- 1.  You might want to draw greater attention to the statistical transformation -->
<!--     in your code. For example, you might use `stat_summary()`, which -->
<!--     summarises the y values for each unique x value, to draw  -->
<!--     attention to the summary that you're computing: -->

<!--     ```{r} -->
<!--     ggplot(data = diamonds) +  -->
<!--       stat_summary( -->
<!--         mapping = aes(x = cut, y = depth), -->
<!--         fun.ymin = min, -->
<!--         fun.ymax = max, -->
<!--         fun.y = median -->
<!--       ) -->
<!--     ``` -->

<!-- ggplot2 provides over 20 stats for you to use. Each stat is a function, so you can get help in the usual way, e.g. `?stat_bin`. To see a complete list of stats, try the ggplot2 cheatsheet. -->

<!-- ### Exercises -->

<!-- 1.  What is the default geom associated with `stat_summary()`? How could -->
<!--     you rewrite the previous plot to use that geom function instead of the  -->
<!--     stat function? -->

<!-- 1.  What does `geom_col()` do? How is it different to `geom_bar()`? -->

<!-- 1.  Most geoms and stats come in pairs that are almost always used in  -->
<!--     concert. Read through the documentation and make a list of all the  -->
<!--     pairs. What do they have in common? -->

<!-- 1.  What variables does `stat_smooth()` compute? What parameters control -->
<!--     its behaviour? -->

<!-- 1.  In our proportion bar chart, we need to set `group = 1`. Why? In other -->
<!--     words what is the problem with these two graphs? -->

<!--     ```{r, eval = FALSE} -->
<!--     ggplot(data = diamonds) +  -->
<!--       geom_bar(mapping = aes(x = cut, y = ..prop..)) -->
<!--     ggplot(data = diamonds) +  -->
<!--       geom_bar(mapping = aes(x = cut, fill = color, y = ..prop..)) -->
<!--     ``` -->


<!-- ## Position adjustments -->

<!-- There's one more piece of magic associated with bar charts. You can colour a bar chart using either the `colour` aesthetic, or, more usefully, `fill`: -->

<!-- ```{r out.width = "50%", fig.align = "default"} -->
<!-- ggplot(data = diamonds) +  -->
<!--   geom_bar(mapping = aes(x = cut, colour = cut)) -->
<!-- ggplot(data = diamonds) +  -->
<!--   geom_bar(mapping = aes(x = cut, fill = cut)) -->
<!-- ``` -->

<!-- Note what happens if you map the fill aesthetic to another variable, like `clarity`: the bars are automatically stacked. Each colored rectangle represents a combination of `cut` and `clarity`. -->

<!-- ```{r} -->
<!-- ggplot(data = diamonds) +  -->
<!--   geom_bar(mapping = aes(x = cut, fill = clarity)) -->
<!-- ``` -->

<!-- The stacking is performed automatically by the __position adjustment__ specified by the `position` argument. If you don't want a stacked bar chart, you can use one of three other options: `"identity"`, `"dodge"` or `"fill"`. -->

<!-- *   `position = "identity"` will place each object exactly where it falls in  -->
<!--     the context of the graph. This is not very useful for bars, because it -->
<!--     overlaps them. To see that overlapping we either need to make the bars -->
<!--     slightly transparent by setting `alpha` to a small value, or completely -->
<!--     transparent by setting `fill = NA`. -->

<!--     ```{r out.width = "50%", fig.align = "default"} -->
<!--     ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +  -->
<!--       geom_bar(alpha = 1/5, position = "identity") -->
<!--     ggplot(data = diamonds, mapping = aes(x = cut, colour = clarity)) +  -->
<!--       geom_bar(fill = NA, position = "identity") -->
<!--     ``` -->

<!--     The identity position adjustment is more useful for 2d geoms, like points, -->
<!--     where it is the default. -->

<!-- *   `position = "fill"` works like stacking, but makes each set of stacked bars -->
<!--     the same height. This makes it easier to compare proportions across  -->
<!--     groups. -->

<!--     ```{r} -->
<!--     ggplot(data = diamonds) +  -->
<!--       geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill") -->
<!--     ``` -->

<!-- *   `position = "dodge"` places overlapping objects directly _beside_ one  -->
<!--     another. This makes it easier to compare individual values. -->

<!--     ```{r} -->
<!--     ggplot(data = diamonds) +  -->
<!--       geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge") -->
<!--     ``` -->

<!-- There's one other type of adjustment that's not useful for bar charts, but it can be very useful for scatterplots. Recall our first scatterplot. Did you notice that the plot displays only 126 points, even though there are 234 observations in the dataset? -->

<!-- ```{r echo = FALSE} -->
<!-- ggplot(data = mpg) +  -->
<!--   geom_point(mapping = aes(x = displ, y = hwy)) -->
<!-- ``` -->

<!-- The values of `hwy` and `displ` are rounded so the points appear on a grid and many points overlap each other. This problem is known as __overplotting__. This arrangement makes it hard to see where the mass of the data is. Are the data points spread equally throughout the graph, or is there one special combination of `hwy` and `displ` that contains 109 values?  -->

<!-- You can avoid this gridding by setting the position adjustment to "jitter".  `position = "jitter"` adds a small amount of random noise to each point. This spreads the points out because no two points are likely to receive the same amount of random noise. -->

<!-- ```{r} -->
<!-- ggplot(data = mpg) +  -->
<!--   geom_point(mapping = aes(x = displ, y = hwy), position = "jitter") -->
<!-- ``` -->

<!-- Adding randomness seems like a strange way to improve your plot, but while it makes your graph less accurate at small scales, it makes your graph _more_ revealing at large scales. Because this is such a useful operation, ggplot2 comes with a shorthand for `geom_point(position = "jitter")`: `geom_jitter()`. -->

<!-- To learn more about a position adjustment, look up the help page associated with each adjustment: `?position_dodge`, `?position_fill`, `?position_identity`, `?position_jitter`, and `?position_stack`. -->

<!-- ### Exercises -->

<!-- 1.  What is the problem with this plot? How could you improve it? -->

<!--     ```{r} -->
<!--     ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +  -->
<!--       geom_point() -->
<!--     ``` -->

<!-- 1.  What parameters to `geom_jitter()` control the amount of jittering? -->

<!-- 1.  Compare and contrast `geom_jitter()` with `geom_count()`. -->

<!-- 1.  What's the default position adjustment for `geom_boxplot()`? Create -->
<!--     a visualisation of the `mpg` dataset that demonstrates it. -->

<!-- ## Coordinate systems -->

<!-- Coordinate systems are probably the most complicated part of ggplot2. The default coordinate system is the Cartesian coordinate system where the x and y positions act independently to determine the location of each point. There are a number of other coordinate systems that are occasionally helpful. -->

<!-- *   `coord_flip()` switches the x and y axes. This is useful (for example), -->
<!--     if you want horizontal boxplots. It's also useful for long labels: it's -->
<!--     hard to get them to fit without overlapping on the x-axis. -->

<!--     ```{r fig.width = 3, out.width = "50%", fig.align = "default"} -->
<!--     ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +  -->
<!--       geom_boxplot() -->
<!--     ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +  -->
<!--       geom_boxplot() + -->
<!--       coord_flip() -->
<!--     ``` -->

<!-- *   `coord_quickmap()` sets the aspect ratio correctly for maps. This is very -->
<!--     important if you're plotting spatial data with ggplot2 (which unfortunately -->
<!--     we don't have the space to cover in this book). -->

<!--     ```{r fig.width = 3, out.width = "50%", fig.align = "default", message = FALSE} -->
<!--     nz <- map_data("nz") -->

<!--     ggplot(nz, aes(long, lat, group = group)) + -->
<!--       geom_polygon(fill = "white", colour = "black") -->

<!--     ggplot(nz, aes(long, lat, group = group)) + -->
<!--       geom_polygon(fill = "white", colour = "black") + -->
<!--       coord_quickmap() -->
<!--     ``` -->

<!-- *   `coord_polar()` uses polar coordinates. Polar coordinates reveal an  -->
<!--     interesting connection between a bar chart and a Coxcomb chart. -->

<!--     ```{r fig.width = 3, out.width = "50%", fig.align = "default", fig.asp = 1} -->
<!--     bar <- ggplot(data = diamonds) +  -->
<!--       geom_bar( -->
<!--         mapping = aes(x = cut, fill = cut),  -->
<!--         show.legend = FALSE, -->
<!--         width = 1 -->
<!--       ) +  -->
<!--       theme(aspect.ratio = 1) + -->
<!--       labs(x = NULL, y = NULL) -->

<!--     bar + coord_flip() -->
<!--     bar + coord_polar() -->
<!--     ``` -->

<!-- ### Exercises -->

<!-- 1.  Turn a stacked bar chart into a pie chart using `coord_polar()`. -->

<!-- 1.  What does `labs()` do? Read the documentation. -->

<!-- 1.  What's the difference between `coord_quickmap()` and `coord_map()`? -->

<!-- 1.  What does the plot below tell you about the relationship between city -->
<!--     and highway mpg? Why is `coord_fixed()` important? What does  -->
<!--     `geom_abline()` do? -->

<!--     ```{r, fig.asp = 1, out.width = "50%"} -->
<!--     ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + -->
<!--       geom_point() +  -->
<!--       geom_abline() + -->
<!--       coord_fixed() -->
<!--     ``` -->

<!-- ## The layered grammar of graphics -->

<!-- In the previous sections, you learned much more than how to make scatterplots, bar charts, and boxplots. You learned a foundation that you can use to make _any_ type of plot with ggplot2. To see this, let's add position adjustments, stats, coordinate systems, and faceting to our code template: -->

<!-- ``` -->
<!-- ggplot(data = <DATA>) +  -->
<!--   <GEOM_FUNCTION>( -->
<!--      mapping = aes(<MAPPINGS>), -->
<!--      stat = <STAT>,  -->
<!--      position = <POSITION> -->
<!--   ) + -->
<!--   <COORDINATE_FUNCTION> + -->
<!--   <FACET_FUNCTION> -->
<!-- ``` -->

<!-- Our new template takes seven parameters, the bracketed words that appear in the template. In practice, you rarely need to supply all seven parameters to make a graph because ggplot2 will provide useful defaults for everything except the data, the mappings, and the geom function. -->

<!-- The seven parameters in the template compose the grammar of graphics, a formal system for building plots. The grammar of graphics is based on the insight that you can uniquely describe _any_ plot as a combination of a dataset, a geom, a set of mappings, a stat, a position adjustment, a coordinate system, and a faceting scheme.  -->

<!-- To see how this works, consider how you could build a basic plot from scratch: you could start with a dataset and then transform it into the information that you want to display (with a stat). -->

<!-- ```{r, echo = FALSE, out.width = "100%"} -->
<!-- knitr::include_graphics("images/visualization-grammar-1.png") -->
<!-- ``` -->

<!-- Next, you could choose a geometric object to represent each observation in the transformed data. You could then use the aesthetic properties of the geoms to represent variables in the data. You would map the values of each variable to the levels of an aesthetic. -->

<!-- ```{r, echo = FALSE, out.width = "100%"} -->
<!-- knitr::include_graphics("images/visualization-grammar-2.png") -->
<!-- ``` -->

<!-- You'd then select a coordinate system to place the geoms into. You'd use the location of the objects (which is itself an aesthetic property) to display the values of the x and y variables. At that point, you would have a complete graph, but you could further adjust the positions of the geoms within the coordinate system (a position adjustment) or split the graph into subplots (faceting). You could also extend the plot by adding one or more additional layers, where each additional layer uses a dataset, a geom, a set of mappings, a stat, and a position adjustment. -->

<!-- ```{r, echo = FALSE, out.width = "100%"} -->
<!-- knitr::include_graphics("images/visualization-grammar-3.png") -->
<!-- ``` -->

<!-- You could use this method to build _any_ plot that you imagine. In other words, you can use the code template that you've learned in this chapter to build hundreds of thousands of unique plots. -->
