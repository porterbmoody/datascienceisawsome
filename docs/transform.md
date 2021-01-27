# Data transformation {#transform}




## Introduction

Visualization is an important tool for insight generation, but it is rare that you get the data in exactly the right form you need. Often you'll need to create some new variables or summaries, or maybe you just want to rename the variables or reorder the observations in order to make the data a little easier to work with. You'll learn how to do all that (and more!) in this chapter, which will teach you how to transform your data using the pandas package and a new dataset on flights departing New York City in 2013.

### Prerequisites

In this chapter we're going to focus on how to use the pandas package, the foundational package for data science in Python. We'll illustrate the key ideas using data from the nycflights13 R package, and use Altair to help us understand the data. We will also need two additional Python packages to help us with mathematical and statistical functions - [NumPy](https://numpy.org/) and [SciPy](https://www.scipy.org/scipylib/index.html). Notice the `from ____ import ____` follows the [SciPy guidance](https://docs.scipy.org/doc/scipy/reference/api.html) to import functions from submodule spaces. Now we will call functions using the SciPy package with the `stats.<FUNCTION>` structure.


```python
import pandas as pd
import altair as alt
import numpy as np
from scipy import stats

flights_url = "https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/flights/flights.csv"

flights = pd.read_csv(flights_url)
flights['time_hour'] = pd.to_datetime(flights.time_hour, format = "%Y-%m-%d %H:%M:%S")
```

### nycflights13

To explore the basic data manipulation verbs of pandas, we'll use `flights`. This data frame contains all 336,776 flights that departed from New York City in 2013. The data comes from the US [Bureau of Transportation Statistics](http://www.transtats.bts.gov/DatabaseInfo.asp?DB_ID=120&Link=0), and is [documented here](https://github.com/byuidatascience/data4python4ds/blob/master/data.md).


```
#>         year  month  day  ...  hour  minute                 time_hour
#> 0       2013      1    1  ...     5      15 2013-01-01 10:00:00+00:00
#> 1       2013      1    1  ...     5      29 2013-01-01 10:00:00+00:00
#> 2       2013      1    1  ...     5      40 2013-01-01 10:00:00+00:00
#> 3       2013      1    1  ...     5      45 2013-01-01 10:00:00+00:00
#> 4       2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
#> ...      ...    ...  ...  ...   ...     ...                       ...
#> 336771  2013      9   30  ...    14      55 2013-09-30 18:00:00+00:00
#> 336772  2013      9   30  ...    22       0 2013-10-01 02:00:00+00:00
#> 336773  2013      9   30  ...    12      10 2013-09-30 16:00:00+00:00
#> 336774  2013      9   30  ...    11      59 2013-09-30 15:00:00+00:00
#> 336775  2013      9   30  ...     8      40 2013-09-30 12:00:00+00:00
#> 
#> [336776 rows x 19 columns]
```

You might notice that this data frame does not print in its entirety as other data frames you might have seen in the past: it only shows the first few and last few rows with only the columns that fit on one screen. (To see the whole dataset, you can open the variable view in your interactive Python window and double click on the flights object which will open the dataset in the VS Code data viewer). 

Using `flights.dtypes` will show you the variables types for each column.  These describe the type of each variable:


```
#> year                            int64
#> month                           int64
#> day                             int64
#> dep_time                      float64
#> sched_dep_time                  int64
#> dep_delay                     float64
#> arr_time                      float64
#> sched_arr_time                  int64
#> arr_delay                     float64
#> carrier                        object
#> flight                          int64
#> tailnum                        object
#> origin                         object
#> dest                           object
#> air_time                      float64
#> distance                        int64
#> hour                            int64
#> minute                          int64
#> time_hour         datetime64[ns, UTC]
#> dtype: object
```

* `int64` stands for integers.

* `float64` stands for doubles, or real numbers.

* `object` stands for character vectors, or strings.

* `datetime64` stands for date-times (a date + a time) and dates. You can read [more about pandas datetime tools](https://pandas.pydata.org/pandas-docs/stable/user_guide/timeseries.html)

There are three other common types of variables that aren't used in this dataset but you'll encounter later in the book:

* `bool` stands for logical, vectors that contain only `True` or `False`.

* `category` stands for factors, which pandas uses to represent categorical variables
  with fixed possible values.

Using `flights.info()` also provides a print out of data types on other useful information about your pandas data frame.


```python
flights.info()
#> <class 'pandas.core.frame.DataFrame'>
#> RangeIndex: 336776 entries, 0 to 336775
#> Data columns (total 19 columns):
#>  #   Column          Non-Null Count   Dtype              
#> ---  ------          --------------   -----              
#>  0   year            336776 non-null  int64              
#>  1   month           336776 non-null  int64              
#>  2   day             336776 non-null  int64              
#>  3   dep_time        328521 non-null  float64            
#>  4   sched_dep_time  336776 non-null  int64              
#>  5   dep_delay       328521 non-null  float64            
#>  6   arr_time        328063 non-null  float64            
#>  7   sched_arr_time  336776 non-null  int64              
#>  8   arr_delay       327346 non-null  float64            
#>  9   carrier         336776 non-null  object             
#>  10  flight          336776 non-null  int64              
#>  11  tailnum         334264 non-null  object             
#>  12  origin          336776 non-null  object             
#>  13  dest            336776 non-null  object             
#>  14  air_time        327346 non-null  float64            
#>  15  distance        336776 non-null  int64              
#>  16  hour            336776 non-null  int64              
#>  17  minute          336776 non-null  int64              
#>  18  time_hour       336776 non-null  datetime64[ns, UTC]
#> dtypes: datetime64[ns, UTC](1), float64(5), int64(9), object(4)
#> memory usage: 48.8+ MB
```



### pandas data manipulation basics

<!-- https://pandas.pydata.org/pandas-docs/stable/getting_started/basics.html -->
<!-- https://www.dataquest.io/blog/pandas-cheat-sheet/ -->
<!-- https://medium.com/dunder-data/minimally-sufficient-pandas-a8e67f2a2428 -->

In this chapter you are going to learn five key pandas functions or object methods. Object methods are things the objects can perform. For example, pandas data frames know how to tell you their shape, the pandas object knows how to concatenate two data frames together. The way we tell an object we want it to do something is with the ‘dot operator’. We will refer to these object operators as functions or methods. Below are the five methods that allow you to solve the vast majority of your data manipulation challenges:

* Pick observations by their values (`query()`).
* Reorder the rows (`sort_values()`).
* Pick variables by their names (`filter()`).
* Create new variables with functions of existing variables (`assign()`).
* Collapse many values down to a single summary (`groupby()`).

The pandas package can handle all of the same functionality of dplyr in R.  You can read [pandas mapping guide](https://pandas.pydata.org/docs/getting_started/comparison/comparison_with_r.html) and [this towards data science article](https://towardsdatascience.com/tidying-up-pandas-4572bfa38776) to get more details on the following brief table. 



Table: (\#tab:unnamed-chunk-5)Comparable functions in R-Dplyr and Python-Pandas

R dplyr function   Python pandas function 
-----------------  -----------------------
`filter()`         `query()`              
`arrange()`        `sort_values()`        
`select()`         `filter()` or `loc[]`  
`rename ()`        `rename()`             
`mutate()`         `assign()` (see note)  
`group_by ()`      `groupby()`            
`summarise()`      `agg()`                


**Note:** The `dpylr::mutate()` function works similar to `assign()` in pandas on data frames.  But you cannot use `assign()` on grouped data frame in pandas like you would use `dplyr::mutate()` on a grouped object. In that case you would use `transform()` and even then the functionality is not quite the same.

The `groupby()` changes the scope of each function from operating on the entire dataset to operating on it group-by-group. These functions provide the verbs for a language of data manipulation.

All verbs work similarly:

1.  The first argument is a pandas dataFrame.

1.  The subsequent methods describe what to do with the data frame.

1.  The result is a new data frame.

Together these properties make it easy to chain together multiple simple steps to achieve a complex result. Let's dive in and see how these verbs work.

## Filter rows with `.query()`

`.query()` allows you to subset observations based on their values. The first argument specifies the rows to be selected. This argument can be label names or a boolean series. The second argument specifies the columns to be selected. The bolean filter on the rows is our focus. For example, we can select all flights on January 1st with:


```python
flights.query('month == 1 & day == 1')
#>      year  month  day  ...  hour  minute                 time_hour
#> 0    2013      1    1  ...     5      15 2013-01-01 10:00:00+00:00
#> 1    2013      1    1  ...     5      29 2013-01-01 10:00:00+00:00
#> 2    2013      1    1  ...     5      40 2013-01-01 10:00:00+00:00
#> 3    2013      1    1  ...     5      45 2013-01-01 10:00:00+00:00
#> 4    2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
#> ..    ...    ...  ...  ...   ...     ...                       ...
#> 837  2013      1    1  ...    23      59 2013-01-02 04:00:00+00:00
#> 838  2013      1    1  ...    16      30 2013-01-01 21:00:00+00:00
#> 839  2013      1    1  ...    19      35 2013-01-02 00:00:00+00:00
#> 840  2013      1    1  ...    15       0 2013-01-01 20:00:00+00:00
#> 841  2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
#> 
#> [842 rows x 19 columns]
```

The previous expression is equivalent to `flights[(flights.month == 1) & (flights.day == 1)]`


When you run that line of code, pandas executes the filtering operation and returns a new data frame. pandas functions usually don't modify their inputs, so if you want to save the result, you'll need to use the assignment operator, `=`:


```pandas
jan1 = flights.query('month == 1 & day == 1')
```

Interactive Python either prints out the results, or saves them to a variable. 

### Comparisons

To use filtering effectively, you have to know how to select the observations that you want using the comparison operators. Python provides the standard suite: `>`, `>=`, `<`, `<=`, `!=` (not equal), and `==` (equal).

When you're starting out with Python, the easiest mistake to make is to use `=` instead of `==` when testing for equality. When this happens you'll get an error:


```python
flights.query('month = 1')
#> Error in py_call_impl(callable, dots$args, dots$keywords): ValueError: cannot assign without a target object
#> 
#> Detailed traceback: 
#>   File "<string>", line 1, in <module>
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/frame.py", line 3231, in query
#>     res = self.eval(expr, **kwargs)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/frame.py", line 3346, in eval
#>     return _eval(expr, inplace=inplace, **kwargs)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/eval.py", line 332, in eval
#>     parsed_expr = Expr(expr, engine=engine, parser=parser, env=env)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/expr.py", line 764, in __init__
#>     self.terms = self.parse()
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/expr.py", line 781, in parse
#>     return self._visitor.visit(self.expr)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/expr.py", line 375, in visit
#>     return visitor(node, **kwargs)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/expr.py", line 381, in visit_Module
#>     return self.visit(expr, **kwargs)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/expr.py", line 375, in visit
#>     return visitor(node, **kwargs)
#>   File "/usr/local/lib/python3.7/site-packages/pandas/core/computation/expr.py", line 585, in visit_Assign
#>     raise ValueError("cannot assign without a target object")
```

There's another common problem you might encounter when using `==`: floating point numbers. The following result might surprise you!


```python
np.sqrt(2) ** 2 ==  2
#> False
1 / 49 * 49 == 1
#> False
```

Computers use finite precision arithmetic (they obviously can't store an infinite number of digits!) so remember that every number you see is an approximation. Instead of relying on `==`, use `np.isclose()`:


```python
np.isclose(np.sqrt(2) ** 2,  2)
#> True
np.isclose(1 / 49 * 49, 1)
#> True
```

### Logical operators

Multiple arguments to `query()` are combined with "and": every expression must be true in order for a row to be included in the output. For other types of combinations, you'll need to use Boolean operators yourself: `&` is "and", `|` is "or", and `!` is "not". Figure \@ref(fig:bool-ops) shows the complete set of Boolean operations.

<div class="figure" style="text-align: center">
<img src="diagrams/transform-logical.png" alt="Complete set of boolean operations. `x` is the left-hand circle, `y` is the right-hand circle, and the shaded region show which parts each operator selects." width="70%" />
<p class="caption">(\#fig:bool-ops)Complete set of boolean operations. `x` is the left-hand circle, `y` is the right-hand circle, and the shaded region show which parts each operator selects.</p>
</div>

The following code finds all flights that departed in November or December:


```python
flights.query('month == 11 | month == 12')
```

The order of operations doesn't work like English. You can't write `flights.query(month == (11 | 12))`, which you might literally translate into  "finds all flights that departed in November or December". Instead it finds all months that equal `11 | 12`, an expression that evaluates to `True`. In a numeric context (like here), `True` becomes one, so this finds all flights in January, not November or December. This is quite confusing!

A useful short-hand for this problem is `x in y`. This will select every row where `x` is one of the values in `y`. We could use it to rewrite the code above:


```python
nov_dec = flights.query('month in [11, 12]')
```

Sometimes you can simplify complicated subsetting by remembering De Morgan's law: `!(x & y)` is the same as `!x | !y`, and `!(x | y)` is the same as `!x & !y`. For example, if you wanted to find flights that weren't delayed (on arrival or departure) by more than two hours, you could use either of the following two filters:


```python
flights.query('arr_delay > 120 | dep_delay > 120')
flights.query('arr_delay <= 120 | dep_delay <= 120')
```

<!-- As well as `&` and `|`, Python also has `&&` and `||`. Don't use them here! You'll learn when you should use them in [conditional execution]. -->

Whenever you start using complicated, multipart expressions in `.query()`, consider making them explicit variables instead. That makes it much easier to check your work. You'll learn how to create new variables shortly.

### Missing values

One important feature of pandas in Python that can make comparison tricky are missing values, or `NA`s ("not availables"). `NA` represents an unknown value so missing values are "contagious": almost any operation involving an unknown value will also be unknown.


```python
np.nan + 10
#> nan
np.nan / 2
#> nan
```

The most confusing result are the comparisons. They always return a `False`. The logic for this result [is explained on stackoverflow](https://stackoverflow.com/questions/1565164/what-is-the-rationale-for-all-comparisons-returning-false-for-ieee754-nan-values). The [pandas missing data guide](https://pandas.pydata.org/pandas-docs/dev/user_guide/missing_data.html) is a helpful read.


```python
np.nan > 5
#> False
10 == np.nan
#> False
np.nan == np.nan
#> False
```

It's easiest to understand why this is true with a bit more context:


```python
# Let x be Mary's age. We don't know how old she is.
x = np.nan

# Let y be John's age. We don't know how old he is.
y = np.nan

# Are John and Mary the same age?
x == y
# Illogical comparisons are False.
#> False
```

The Python development team did decide to provide functionality to find `np.nan` objects in your code by allowing `np.nan != np.nan` to return `True`.  Once again you can [read the rationale for this decision](https://stackoverflow.com/questions/1565164/what-is-the-rationale-for-all-comparisons-returning-false-for-ieee754-nan-values). Python now has `isnan()` functions to make this comparison more straight forward in your code. 

Pandas uses the `nan` structure in Python to identify __NA__ or 'missing' values. If you want to determine if a value is missing, use `pd.isna()`:


```python
pd.isna(x)
#> True
```

`query()` only includes rows where the condition is `TRUE`; it excludes both `FALSE` and __NA__ values. 


```python
df = pd.DataFrame({'x': [1, np.nan, 3]})
df.query('x > 1')
#>      x
#> 2  3.0
```

If you want to preserve missing values, ask for them explicitly using the trick mentioned in the previous paragraph or by using `pd.isna()` with the symbolic reference `@` in your condition:


```python
df.query('x != x | x > 1')
#>      x
#> 1  NaN
#> 2  3.0
df.query('@pd.isna(x) | x > 1')
#>      x
#> 1  NaN
#> 2  3.0
```

### Exercises

1.  Find all flights that

    1. Had an arrival delay of two or more hours
    1. Flew to Houston (`IAH` or `HOU`)
    1. Were operated by United, American, or Delta
    1. Departed in summer (July, August, and September)
    1. Arrived more than two hours late, but didn't leave late
    1. Were delayed by at least an hour, but made up over 30 minutes in flight
    1. Departed between midnight and 6am (inclusive)

1.  How many flights have a missing `dep_time`? What other variables are
    missing? What might these rows represent?

## Arrange or sort rows with `.sort_values()`

`.sort_values()` works similarly to `.query()` except that instead of selecting rows, it changes their order. It takes a data frame and a column name or a list of column names to order by. If you provide more than one column name, each additional column will be used to break ties in the values of preceding columns:


```python
flights.sort_values(by = ['year', 'month', 'day'])
#>         year  month  day  ...  hour  minute                 time_hour
#> 0       2013      1    1  ...     5      15 2013-01-01 10:00:00+00:00
#> 1       2013      1    1  ...     5      29 2013-01-01 10:00:00+00:00
#> 2       2013      1    1  ...     5      40 2013-01-01 10:00:00+00:00
#> 3       2013      1    1  ...     5      45 2013-01-01 10:00:00+00:00
#> 4       2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
#> ...      ...    ...  ...  ...   ...     ...                       ...
#> 111291  2013     12   31  ...     7       5 2013-12-31 12:00:00+00:00
#> 111292  2013     12   31  ...     8      25 2013-12-31 13:00:00+00:00
#> 111293  2013     12   31  ...    16      15 2013-12-31 21:00:00+00:00
#> 111294  2013     12   31  ...     6       0 2013-12-31 11:00:00+00:00
#> 111295  2013     12   31  ...     8      30 2013-12-31 13:00:00+00:00
#> 
#> [336776 rows x 19 columns]
```

Use the argument `ascending = False` to re-order by a column in descending order:


```python
flights.sort_values(by = ['year', 'month', 'day'], ascending = False)
#>         year  month  day  ...  hour  minute                 time_hour
#> 110520  2013     12   31  ...    23      59 2014-01-01 04:00:00+00:00
#> 110521  2013     12   31  ...    23      59 2014-01-01 04:00:00+00:00
#> 110522  2013     12   31  ...    22      45 2014-01-01 03:00:00+00:00
#> 110523  2013     12   31  ...     5       0 2013-12-31 10:00:00+00:00
#> 110524  2013     12   31  ...     5      15 2013-12-31 10:00:00+00:00
#> ...      ...    ...  ...  ...   ...     ...                       ...
#> 837     2013      1    1  ...    23      59 2013-01-02 04:00:00+00:00
#> 838     2013      1    1  ...    16      30 2013-01-01 21:00:00+00:00
#> 839     2013      1    1  ...    19      35 2013-01-02 00:00:00+00:00
#> 840     2013      1    1  ...    15       0 2013-01-01 20:00:00+00:00
#> 841     2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
#> 
#> [336776 rows x 19 columns]
```

Missing values are always sorted at the end:


```python
df = pd.DataFrame({'x': [5, 2, np.nan]})
df.sort_values('x')
#>      x
#> 1  2.0
#> 0  5.0
#> 2  NaN
df.sort_values('x', ascending = False)
#>      x
#> 0  5.0
#> 1  2.0
#> 2  NaN
```

### Exercises

1.  How could you use `sort()` to sort all missing values to the start?
    (Hint: use `isna()`). 
    
    <!-- df.sort_values('x', ascending = False, na_position = "first") -->


1.  Sort `flights` to find the most delayed flights. Find the flights that
    left earliest.

1.  Sort `flights` to find the fastest (highest speed) flights.

1.  Which flights travelled the farthest? Which travelled the shortest?

## Select columns with `filter()` or `loc[]` {#select}

It's not uncommon to get datasets with hundreds or even thousands of variables. In this case, the first challenge is often narrowing in on the variables you're actually interested in. `.filter()` allows you to rapidly zoom in on a useful subset using operations based on the names of the variables.

Additionaly, `.loc[]` is often used to select columns by many user of pandas. You can read more about the `.loc[]` method in the [pandas documentation](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.loc.html#pandas.DataFrame.loc)

`.filter()` is not terribly useful with the flights data because we only have 19 variables, but you can still get the general idea:



```python
# Select columns by name
flights.filter(['year', 'month', 'day'])
# Select all columns except year and day (inclusive)
#>         year  month  day
#> 0       2013      1    1
#> 1       2013      1    1
#> 2       2013      1    1
#> 3       2013      1    1
#> 4       2013      1    1
#> ...      ...    ...  ...
#> 336771  2013      9   30
#> 336772  2013      9   30
#> 336773  2013      9   30
#> 336774  2013      9   30
#> 336775  2013      9   30
#> 
#> [336776 rows x 3 columns]
flights.drop(columns = ['year', 'day'])
#>         month  dep_time  sched_dep_time  ...  hour  minute                 time_hour
#> 0           1     517.0             515  ...     5      15 2013-01-01 10:00:00+00:00
#> 1           1     533.0             529  ...     5      29 2013-01-01 10:00:00+00:00
#> 2           1     542.0             540  ...     5      40 2013-01-01 10:00:00+00:00
#> 3           1     544.0             545  ...     5      45 2013-01-01 10:00:00+00:00
#> 4           1     554.0             600  ...     6       0 2013-01-01 11:00:00+00:00
#> ...       ...       ...             ...  ...   ...     ...                       ...
#> 336771      9       NaN            1455  ...    14      55 2013-09-30 18:00:00+00:00
#> 336772      9       NaN            2200  ...    22       0 2013-10-01 02:00:00+00:00
#> 336773      9       NaN            1210  ...    12      10 2013-09-30 16:00:00+00:00
#> 336774      9       NaN            1159  ...    11      59 2013-09-30 15:00:00+00:00
#> 336775      9       NaN             840  ...     8      40 2013-09-30 12:00:00+00:00
#> 
#> [336776 rows x 17 columns]
```

`loc[]` functions in a similar fashion.


```python
# Select columns by name
flights.loc[:, ['year', 'month', 'day']]
# Select all columns between year and day (inclusive)
#>         year  month  day
#> 0       2013      1    1
#> 1       2013      1    1
#> 2       2013      1    1
#> 3       2013      1    1
#> 4       2013      1    1
#> ...      ...    ...  ...
#> 336771  2013      9   30
#> 336772  2013      9   30
#> 336773  2013      9   30
#> 336774  2013      9   30
#> 336775  2013      9   30
#> 
#> [336776 rows x 3 columns]
flights.loc[:, 'year':'day']
# Select all columns except year and day (inclusive)
#>         year  month  day
#> 0       2013      1    1
#> 1       2013      1    1
#> 2       2013      1    1
#> 3       2013      1    1
#> 4       2013      1    1
#> ...      ...    ...  ...
#> 336771  2013      9   30
#> 336772  2013      9   30
#> 336773  2013      9   30
#> 336774  2013      9   30
#> 336775  2013      9   30
#> 
#> [336776 rows x 3 columns]
```

There are a number of helper regular expressions you can use within `filter()`:

* `flights.filter(regex = '^sch')`: matches column names that begin with "sch".

* `flights.filter(regex = "time$")`: matches names that end with "time".

* `flights.filter(regex = "_dep_")`: matches names that contain "_dep_".

* `flights.filter(regex = '(.)\\1')`: selects variables that match a regular expression.
   This one matches any variables that contain repeated characters. You'll
   learn more about regular expressions in [strings].

See [pandas filter documentation](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.filter.html) for more details.

Use `rename()` to rename a column or multiple columns.


```python
flights.rename(columns = {'year': 'YEAR', 'month':'MONTH'})
#>         YEAR  MONTH  day  ...  hour  minute                 time_hour
#> 0       2013      1    1  ...     5      15 2013-01-01 10:00:00+00:00
#> 1       2013      1    1  ...     5      29 2013-01-01 10:00:00+00:00
#> 2       2013      1    1  ...     5      40 2013-01-01 10:00:00+00:00
#> 3       2013      1    1  ...     5      45 2013-01-01 10:00:00+00:00
#> 4       2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
#> ...      ...    ...  ...  ...   ...     ...                       ...
#> 336771  2013      9   30  ...    14      55 2013-09-30 18:00:00+00:00
#> 336772  2013      9   30  ...    22       0 2013-10-01 02:00:00+00:00
#> 336773  2013      9   30  ...    12      10 2013-09-30 16:00:00+00:00
#> 336774  2013      9   30  ...    11      59 2013-09-30 15:00:00+00:00
#> 336775  2013      9   30  ...     8      40 2013-09-30 12:00:00+00:00
#> 
#> [336776 rows x 19 columns]
```


### Exercises

1.  Brainstorm as many ways as possible to select `dep_time`, `dep_delay`,
    `arr_time`, and `arr_delay` from `flights`.

1.  What happens if you include the name of a variable multiple times in
    a `filter()` call?

1.  Does the result of running the following code surprise you?  How do the
    select helpers deal with case by default? How can you change that default?

    
    ```r
    flights.filter(regex = "TIME")
    ```

## Add new variables with `.assign()`

Besides selecting sets of existing columns, it's often useful to add new columns that are functions of existing columns. That's the job of `.assign()`.

`.assign()` always adds new columns at the end of your dataset so we'll start by creating a narrower dataset so we can see the new variables. 


```python

flights_sml = (flights
    .filter(regex = "^year$|^month$|^day$|delay$|^distance$|^air_time$"))

(flights_sml
  .assign(
    gain = lambda x: x.dep_delay - x.arr_delay,
    speed = lambda x: x.distance / x.air_time * 60
    )
  .head())
#>    year  month  day  dep_delay  arr_delay  air_time  distance  gain       speed
#> 0  2013      1    1        2.0       11.0     227.0      1400  -9.0  370.044053
#> 1  2013      1    1        4.0       20.0     227.0      1416 -16.0  374.273128
#> 2  2013      1    1        2.0       33.0     160.0      1089 -31.0  408.375000
#> 3  2013      1    1       -1.0      -18.0     183.0      1576  17.0  516.721311
#> 4  2013      1    1       -6.0      -25.0     116.0       762  19.0  394.137931
```

Note that you can refer to columns that you've just created:


```python
(flights_sml
  .assign(
    gain = lambda x: x.dep_delay - x.arr_delay,
    hours = lambda x: x.air_time / 60,
    gain_per_hour = lambda x: x.gain / x.hours
    )
  .head())
#>    year  month  day  dep_delay  ...  distance  gain     hours  gain_per_hour
#> 0  2013      1    1        2.0  ...      1400  -9.0  3.783333      -2.378855
#> 1  2013      1    1        4.0  ...      1416 -16.0  3.783333      -4.229075
#> 2  2013      1    1        2.0  ...      1089 -31.0  2.666667     -11.625000
#> 3  2013      1    1       -1.0  ...      1576  17.0  3.050000       5.573770
#> 4  2013      1    1       -6.0  ...       762  19.0  1.933333       9.827586
#> 
#> [5 rows x 10 columns]
```

### Useful creation functions {#mutate-funs}

There are many functions for creating new variables that you can use with `.assign()`. The key property is that the function must be vectorised: it must take a vector of values as input, return a vector with the same number of values as output. Some arithmetic operators are available in Python without the need for any additional packages. However, many arithmetic functions like `mean()` and `std()` are accessed through importing additional packages. Python comes with a `math` and `statistics` package. However, we recommend the __NumPy__ package for accessing the suite of mathematical functions needed. You would import NumPy with `import numpy as np`. There's no way to list every possible function that you might use, but here's a selection of functions that are frequently useful:

*   Arithmetic operators: `+`, `-`, `*`, `/`, `^`. These are all vectorised,
    using the so called "recycling rules". If one parameter is shorter than
    the other, it will be automatically extended to be the same length. This
    is most useful when one of the arguments is a single number: `air_time / 60`,
    `hours * 60 + minute`, etc.

    Arithmetic operators are also useful in conjunction with the aggregate
    functions you'll learn about later. For example, `x / np.sum(x)` calculates
    the proportion of a total, and `y - np.mean(y)` computes the difference from
    the mean.

*   Modular arithmetic: `//` (integer division) and `%` (remainder), where
    `x == y * (x // y) + (x % y)`. Modular arithmetic is a handy tool because
    it allows you to break integers up into pieces. For example, in the
    flights dataset, you can compute `hour` and `minute` from `dep_time` with:

    
    ```python
    (flights
        .filter(['dep_time'])
        .assign(
          hour = lambda x: x.dep_time // 100,
          minute = lambda x: x.dep_time % 100
          ))
    #>         dep_time  hour  minute
    #> 0          517.0   5.0    17.0
    #> 1          533.0   5.0    33.0
    #> 2          542.0   5.0    42.0
    #> 3          544.0   5.0    44.0
    #> 4          554.0   5.0    54.0
    #> ...          ...   ...     ...
    #> 336771       NaN   NaN     NaN
    #> 336772       NaN   NaN     NaN
    #> 336773       NaN   NaN     NaN
    #> 336774       NaN   NaN     NaN
    #> 336775       NaN   NaN     NaN
    #> 
    #> [336776 rows x 3 columns]
    ```

*   Logs: `np.log()`, `np.log2()`, `np.log10()`. Logarithms are an incredibly useful
    transformation for dealing with data that ranges across multiple orders of
    magnitude. They also convert multiplicative relationships to additive, a
    feature we'll come back to in modelling.

    All else being equal, I recommend using `np.log2()` because it's easy to
    interpret: a difference of 1 on the log scale corresponds to doubling on
    the original scale and a difference of -1 corresponds to halving.

*   Offsets: `shift(1)` and `shift(-1)` allow you to refer to leading or lagging
    values. This allows you to compute running differences (e.g. `x - x.shift(1)`)
    or find when values change (`x != x.shift(1)`). They are most useful in
    conjunction with `groupby()`, which you'll learn about shortly.

    
    ```python
    x = pd.Series(np.arange(1,10))
    x.shift(1)
    #> 0    NaN
    #> 1    1.0
    #> 2    2.0
    #> 3    3.0
    #> 4    4.0
    #> 5    5.0
    #> 6    6.0
    #> 7    7.0
    #> 8    8.0
    #> dtype: float64
    x.shift(-1)
    #> 0    2.0
    #> 1    3.0
    #> 2    4.0
    #> 3    5.0
    #> 4    6.0
    #> 5    7.0
    #> 6    8.0
    #> 7    9.0
    #> 8    NaN
    #> dtype: float64
    ```

*   Cumulative and rolling aggregates: pandas provides functions for running sums,
    products, mins and maxes: `cumsum()`, `cumprod()`, `cummin()`, `cummax()`.
    If you need rolling aggregates (i.e. a sum computed over a rolling window), 
    try the `rolling()` in the pandas package.

    
    ```python
    x
    #> 0    1
    #> 1    2
    #> 2    3
    #> 3    4
    #> 4    5
    #> 5    6
    #> 6    7
    #> 7    8
    #> 8    9
    #> dtype: int64
    x.cumsum()
    #> 0     1
    #> 1     3
    #> 2     6
    #> 3    10
    #> 4    15
    #> 5    21
    #> 6    28
    #> 7    36
    #> 8    45
    #> dtype: int64
    x.rolling(2).mean()
    #> 0    NaN
    #> 1    1.5
    #> 2    2.5
    #> 3    3.5
    #> 4    4.5
    #> 5    5.5
    #> 6    6.5
    #> 7    7.5
    #> 8    8.5
    #> dtype: float64
    ```

*   Logical comparisons, `<`, `<=`, `>`, `>=`, `!=`, and `==`, which you learned about
    earlier. If you're doing a complex sequence of logical operations it's
    often a good idea to store the interim values in new variables so you can
    check that each step is working as expected.

*   Ranking: there are a number of ranking functions, but you should
    start with `min_rank()`. It does the most usual type of ranking
    (e.g. 1st, 2nd, 2nd, 4th). The default gives smallest values the small
    ranks; use `desc(x)` to give the largest values the smallest ranks.

    
    ```python
    y = pd.Series([1, 2, 2, np.nan, 3, 4])
    y.rank(method = 'min')
    #> 0    1.0
    #> 1    2.0
    #> 2    2.0
    #> 3    NaN
    #> 4    4.0
    #> 5    5.0
    #> dtype: float64
    y.rank(ascending=False, method = 'min')
    #> 0    5.0
    #> 1    3.0
    #> 2    3.0
    #> 3    NaN
    #> 4    2.0
    #> 5    1.0
    #> dtype: float64
    ```

    If `method = 'min'` doesn't do what you need, look at the variants
    `method = 'first'`, `method = 'dense'`, `method = 'percent'`, `pct = True`.
    See the rank [help page](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.rank.html) for more details.

    
    ```python
    y.rank(method = 'first')
    #> 0    1.0
    #> 1    2.0
    #> 2    3.0
    #> 3    NaN
    #> 4    4.0
    #> 5    5.0
    #> dtype: float64
    y.rank(method = 'dense')
    #> 0    1.0
    #> 1    2.0
    #> 2    2.0
    #> 3    NaN
    #> 4    3.0
    #> 5    4.0
    #> dtype: float64
    y.rank(pct = True)
    #> 0    0.2
    #> 1    0.5
    #> 2    0.5
    #> 3    NaN
    #> 4    0.8
    #> 5    1.0
    #> dtype: float64
    ```

### Exercises


1.  Currently `dep_time` and `sched_dep_time` are convenient to look at, but
    hard to compute with because they're not really continuous numbers.
    Convert them to a more convenient representation of number of minutes
    since midnight.

1.  Compare `air_time` with `arr_time - dep_time`. What do you expect to see?
    What do you see? What do you need to do to fix it?

1.  Compare `dep_time`, `sched_dep_time`, and `dep_delay`. How would you
    expect those three numbers to be related?

1.  Find the 10 most delayed flights using a ranking function. How do you want
    to handle ties? Carefully read the documentation for `method = 'min'`.

1.  What trigonometric functions does __NumPy__ provide?

## Grouped summaries or aggregations with `agg()`

The last key verb is `agg()`. It collapses a data frame to a single row:


```python
flights.agg({'dep_delay': np.mean})
#> dep_delay    12.63907
#> dtype: float64
```

(Pandas aggregate functions ignores the `np.nan` values like `na.rm = TRUE` in R.)

`agg()` is not terribly useful unless we pair it with `.groupby()`. This changes the unit of analysis from the complete dataset to individual groups. Then, when you use the pandas functions on a grouped data frame they'll be automatically applied "by group". For example, if we applied similiar code to a data frame grouped by date, we get the average delay per date. Note that with the `.groupby()` function we used tuple to identify the column (first entry) and the function to apply on the column (second entry). This is called [named aggregation](https://pandas.pydata.org/pandas-docs/stable/user_guide/groupby.html#named-aggregation) in pandas:


```python
by_day = flights.groupby(['year', 'month', 'day'])
by_day.agg(delay = ('dep_delay', np.mean)).reset_index()
#>      year  month  day      delay
#> 0    2013      1    1  11.548926
#> 1    2013      1    2  13.858824
#> 2    2013      1    3  10.987832
#> 3    2013      1    4   8.951595
#> 4    2013      1    5   5.732218
#> ..    ...    ...  ...        ...
#> 360  2013     12   27  10.937630
#> 361  2013     12   28   7.981550
#> 362  2013     12   29  22.309551
#> 363  2013     12   30  10.698113
#> 364  2013     12   31   6.996053
#> 
#> [365 rows x 4 columns]
```

Note the use of `.reset_index()` to remove pandas creation of a [MultiIndex](https://pandas.pydata.org/pandas-docs/stable/user_guide/advanced.html#advanced-hierarchical). You can read more about the use of grouby in pandas with their [Group By: split-apply-combine user Guid documentation](https://pandas.pydata.org/pandas-docs/stable/user_guide/groupby.html)

Together `.groupby()` and `.agg()` provide one of the tools that you'll use most commonly when working with pandas: grouped summaries. But before we go any further with this, we need to introduce a structure for pandas code when doing data science work. We structure our code much like 'the pipe', `%>%` in the tidyverse packages from R-Studio.

### Combining multiple operations

Imagine that we want to explore the relationship between the distance and average delay for each location. Using what you know about pandas, you might write code like this:


```python
by_dest = flights.groupby('dest')

delay = by_dest.agg(
    count = ('distance', 'size'),
    dist = ('distance', np.mean),
    delay = ('arr_delay', np.mean)
    )

delay_filter = delay.query('count > 20 & dest != "HNL"')

# It looks like delays increase with distance up to ~750 miles
# and then decrease. Maybe as flights get longer there's more
# ability to make up delays in the air?
chart_base = (alt.Chart(delay_filter)
  .encode(
    x = 'dist',
    y = 'delay'
    ))
  
chart = chart_base.mark_point() + chart_base.transform_loess('dist', 'delay').mark_line()  
```

<!--html_preserve--><div id="htmlwidget-ac96cb3ee4656e2e9ec3" style="width:auto;height:auto;" class="vegawidget html-widget"></div>
<script type="application/json" data-for="htmlwidget-ac96cb3ee4656e2e9ec3">{"x":{
  "chart_spec": {
    "$schema": "https://vega.github.io/schema/vega-lite/v4.8.1.json",
    "config": {
      "view": {
        "continuousHeight": 300,
        "continuousWidth": 400
      }
    },
    "data": {
      "name": "data-3702ca1c412d99811a48df476b255e71"
    },
    "datasets": {
      "data-3702ca1c412d99811a48df476b255e71": [
        {
          "count": 254,
          "delay": 4.3819,
          "dist": 1826
        },
        {
          "count": 265,
          "delay": 4.8523,
          "dist": 199
        },
        {
          "count": 439,
          "delay": 14.3971,
          "dist": 143
        },
        {
          "count": 17215,
          "delay": 11.3001,
          "dist": 757.1082
        },
        {
          "count": 2439,
          "delay": 6.0199,
          "dist": 1514.253
        },
        {
          "count": 275,
          "delay": 8.0038,
          "dist": 583.5818
        },
        {
          "count": 443,
          "delay": 7.0485,
          "dist": 116
        },
        {
          "count": 375,
          "delay": 8.0279,
          "dist": 378
        },
        {
          "count": 297,
          "delay": 16.8773,
          "dist": 865.9966
        },
        {
          "count": 6333,
          "delay": 11.8125,
          "dist": 758.2135
        },
        {
          "count": 15508,
          "delay": 2.9144,
          "dist": 190.637
        },
        {
          "count": 896,
          "delay": 8.2455,
          "dist": 1578.9833
        },
        {
          "count": 2589,
          "delay": 8.951,
          "dist": 265.0915
        },
        {
          "count": 4681,
          "delay": 8.946,
          "dist": 296.8084
        },
        {
          "count": 371,
          "delay": 8.1757,
          "dist": 2465
        },
        {
          "count": 1781,
          "delay": 10.7267,
          "dist": 179.4183
        },
        {
          "count": 36,
          "delay": 7.6,
          "dist": 1882
        },
        {
          "count": 116,
          "delay": 41.7642,
          "dist": 603.5517
        },
        {
          "count": 864,
          "delay": 19.6983,
          "dist": 397
        },
        {
          "count": 52,
          "delay": 9.5,
          "dist": 305
        },
        {
          "count": 2884,
          "delay": 10.593,
          "dist": 632.9168
        },
        {
          "count": 4573,
          "delay": 9.1816,
          "dist": 414.1743
        },
        {
          "count": 14064,
          "delay": 7.3603,
          "dist": 538.0273
        },
        {
          "count": 3524,
          "delay": 10.6013,
          "dist": 476.5551
        },
        {
          "count": 138,
          "delay": 14.6716,
          "dist": 444
        },
        {
          "count": 3941,
          "delay": 15.3646,
          "dist": 575.1599
        },
        {
          "count": 1525,
          "delay": 12.6805,
          "dist": 537.1023
        },
        {
          "count": 9705,
          "delay": 9.067,
          "dist": 211.0062
        },
        {
          "count": 7266,
          "delay": 8.6065,
          "dist": 1614.6784
        },
        {
          "count": 8738,
          "delay": 0.3221,
          "dist": 1383.043
        },
        {
          "count": 569,
          "delay": 19.0057,
          "dist": 1020.8875
        },
        {
          "count": 9384,
          "delay": 5.43,
          "dist": 498.1285
        },
        {
          "count": 213,
          "delay": 6.3043,
          "dist": 1735.7089
        },
        {
          "count": 12055,
          "delay": 8.0821,
          "dist": 1070.0688
        },
        {
          "count": 765,
          "delay": 18.1896,
          "dist": 605.7817
        },
        {
          "count": 1606,
          "delay": 14.1126,
          "dist": 449.8418
        },
        {
          "count": 849,
          "delay": 15.9354,
          "dist": 595.96
        },
        {
          "count": 2115,
          "delay": 7.1762,
          "dist": 1420.1551
        },
        {
          "count": 5700,
          "delay": 13.8642,
          "dist": 224.8468
        },
        {
          "count": 7198,
          "delay": 4.2408,
          "dist": 1407.2067
        },
        {
          "count": 110,
          "delay": 4.6355,
          "dist": 500
        },
        {
          "count": 2077,
          "delay": 9.9404,
          "dist": 652.2629
        },
        {
          "count": 25,
          "delay": 28.0952,
          "dist": 1875.6
        },
        {
          "count": 2720,
          "delay": 11.8448,
          "dist": 824.6761
        },
        {
          "count": 5997,
          "delay": 0.2577,
          "dist": 2240.9615
        },
        {
          "count": 16174,
          "delay": 0.5471,
          "dist": 2468.6224
        },
        {
          "count": 668,
          "delay": -0.062,
          "dist": 2465
        },
        {
          "count": 2008,
          "delay": 14.5141,
          "dist": 1097.6952
        },
        {
          "count": 14082,
          "delay": 5.4546,
          "dist": 943.1106
        },
        {
          "count": 4113,
          "delay": 12.3642,
          "dist": 718.046
        },
        {
          "count": 1789,
          "delay": 10.6453,
          "dist": 954.2012
        },
        {
          "count": 1009,
          "delay": 14.7876,
          "dist": 207.0297
        },
        {
          "count": 11728,
          "delay": 0.2991,
          "dist": 1091.5524
        },
        {
          "count": 2802,
          "delay": 14.1672,
          "dist": 733.3815
        },
        {
          "count": 572,
          "delay": 20.196,
          "dist": 803.9545
        },
        {
          "count": 7185,
          "delay": 7.2702,
          "dist": 1017.4017
        },
        {
          "count": 3799,
          "delay": 6.4902,
          "dist": 1177.7057
        },
        {
          "count": 221,
          "delay": -0.2857,
          "dist": 173
        },
        {
          "count": 59,
          "delay": 4.6034,
          "dist": 550.661
        },
        {
          "count": 312,
          "delay": 3.0777,
          "dist": 2576
        },
        {
          "count": 346,
          "delay": 30.619,
          "dist": 1325
        },
        {
          "count": 849,
          "delay": 14.6989,
          "dist": 1135.5665
        },
        {
          "count": 17283,
          "delay": 5.8766,
          "dist": 729.0008
        },
        {
          "count": 1536,
          "delay": 10.9491,
          "dist": 288.5234
        },
        {
          "count": 6554,
          "delay": 8.563,
          "dist": 1028.8381
        },
        {
          "count": 1354,
          "delay": 5.1416,
          "dist": 2445.5657
        },
        {
          "count": 1632,
          "delay": 10.1272,
          "dist": 94.3235
        },
        {
          "count": 4656,
          "delay": 2.097,
          "dist": 2141.3033
        },
        {
          "count": 2875,
          "delay": 7.681,
          "dist": 334.0612
        },
        {
          "count": 365,
          "delay": 7.8715,
          "dist": 1617
        },
        {
          "count": 376,
          "delay": 16.2346,
          "dist": 160
        },
        {
          "count": 2352,
          "delay": 11.6604,
          "dist": 276.1284
        },
        {
          "count": 8163,
          "delay": 10.0524,
          "dist": 426.7577
        },
        {
          "count": 2454,
          "delay": 20.1113,
          "dist": 281.4046
        },
        {
          "count": 2416,
          "delay": 11.5606,
          "dist": 259.2508
        },
        {
          "count": 3537,
          "delay": 3.2381,
          "dist": 1072.8533
        },
        {
          "count": 2737,
          "delay": 3.1392,
          "dist": 2437.2992
        },
        {
          "count": 686,
          "delay": 6.9454,
          "dist": 1578.3411
        },
        {
          "count": 804,
          "delay": 15.1295,
          "dist": 709.1841
        },
        {
          "count": 1157,
          "delay": 12.6694,
          "dist": 645.9836
        },
        {
          "count": 3923,
          "delay": -1.0991,
          "dist": 2412.6653
        },
        {
          "count": 13331,
          "delay": 2.6729,
          "dist": 2577.9236
        },
        {
          "count": 329,
          "delay": 3.4482,
          "dist": 2569
        },
        {
          "count": 5819,
          "delay": 2.5205,
          "dist": 1599.8336
        },
        {
          "count": 2467,
          "delay": 0.1763,
          "dist": 1986.9866
        },
        {
          "count": 284,
          "delay": 12.1099,
          "dist": 2521
        },
        {
          "count": 825,
          "delay": -7.8682,
          "dist": 2434
        },
        {
          "count": 1211,
          "delay": 3.0824,
          "dist": 1044.6515
        },
        {
          "count": 4339,
          "delay": 11.0785,
          "dist": 878.7232
        },
        {
          "count": 522,
          "delay": -3.8359,
          "dist": 1626.9828
        },
        {
          "count": 1761,
          "delay": 8.9039,
          "dist": 205.9216
        },
        {
          "count": 7466,
          "delay": 7.4085,
          "dist": 1003.9356
        },
        {
          "count": 315,
          "delay": 33.6599,
          "dist": 1215
        },
        {
          "count": 101,
          "delay": 12.9684,
          "dist": 652.3861
        },
        {
          "count": 631,
          "delay": 24.0692,
          "dist": 638.8098
        },
        {
          "count": 1036,
          "delay": 7.4657,
          "dist": 1142.5058
        }
      ]
    },
    "layer": [
      {
        "encoding": {
          "x": {
            "field": "dist",
            "type": "quantitative"
          },
          "y": {
            "field": "delay",
            "type": "quantitative"
          }
        },
        "mark": "point"
      },
      {
        "encoding": {
          "x": {
            "field": "dist",
            "type": "quantitative"
          },
          "y": {
            "field": "delay",
            "type": "quantitative"
          }
        },
        "mark": "line",
        "transform": [
          {
            "loess": "delay",
            "on": "dist"
          }
        ]
      }
    ]
  },
  "embed_options": {
    "defaultStyle": true,
    "renderer": "canvas"
  }
},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

There are three steps to prepare this data:

1.  Group flights by destination.

1.  Summarise to compute distance, average delay, and number of flights.

1.  Filter to remove noisy points and Honolulu airport, which is almost
    twice as far away as the next closest airport.

This code is a little frustrating to write because we have to give each intermediate data frame a name, even though we don't care about it. Naming things is hard, so this slows down our analysis.

There's another way to tackle the same problem without the additional objects:


```python
delays = (flights
    .groupby('dest')
    .agg(
      count = ('distance', 'size'),
      dist = ('distance', np.mean),
      delay = ('arr_delay', np.mean) 
      )
    .query('count > 20 & dest != "HNL"'))
```

This focuses on the transformations, not what's being transformed, which makes the code easier to read. You can read it as a series of imperative statements: group, then summarise, then filter. As suggested by this reading, a good way to pronounce `.` when reading pandas code is "then".

You can use the `()` with `.` to rewrite multiple operations in a way that you can read left-to-right, top-to-bottom. We'll use this format frequently from now on because it considerably improves the readability of complex pandas code.

### Missing values

You may have wondered about the `np.nan` values we put into our pandas data frame above. Pandas just started an experimental options (version 1.0) for `pd.NA` but it is not standard as in the R language.  You can read the full details about [missing data in pandas](https://pandas.pydata.org/pandas-docs/stable/user_guide/missing_data.html#working-with-missing-data). 

Pandas' and NumPy's handling of missing values defaults to the opposite functionality of R and the Tidyverse. Here are three key defaults when using Pandas. 

1. When summing data, NA (missing) values will be treated as zero.

1. If the data are all NA, the result will be 0.

1. Cumulative methods ignore NA values by default, but preserve them in the resulting arrays. To override this behaviour and include missing values, use `skipna=False`.

1. All the `.groupby()` methods exclude missing values in their calculations as described in the [pandas groupby documentation](https://pandas.pydata.org/pandas-docs/stable/reference/groupby.html).

In our case, where missing values represent cancelled flights, we could also tackle the problem by first removing the cancelled flights. We'll save this dataset so we can reuse it in the next few examples.


```python
not_cancelled = flights.dropna(subset = ['dep_delay', 'arr_delay']) 
```

### Counts

Whenever you do any aggregation, it's always a good idea to include either a count (`size()`), or a count of non-missing values (`sum(!is.na(x))`). That way you can check that you're not drawing conclusions based on very small amounts of data. For example, let's look at the planes (identified by their tail number) that have the highest average delays:


```python
delays = not_cancelled.groupby('tailnum').agg(
    delay = ("arr_delay", np.mean)
)

chart = (alt.Chart(delays)
    .transform_density(
      density = 'delay',
      as_ = ['delay', 'density'],
      bandwidth=10
      )
    .encode(
      x = 'delay:Q',
      y = 'density:Q'
      )
    .mark_line())
```

<!--html_preserve--><div id="htmlwidget-e5c8c404fe174e4c81bd" style="width:auto;height:auto;" class="vegawidget html-widget"></div>
<script type="application/json" data-for="htmlwidget-e5c8c404fe174e4c81bd">{"x":{
  "chart_spec": {
    "$schema": "https://vega.github.io/schema/vega-lite/v4.8.1.json",
    "config": {
      "view": {
        "continuousHeight": 300,
        "continuousWidth": 400
      }
    },
    "data": {
      "name": "data-3702ca1c412d99811a48df476b255e71"
    },
    "datasets": {
      "data-3702ca1c412d99811a48df476b255e71": [
        {
          "count": 254,
          "delay": 4.3819,
          "dist": 1826
        },
        {
          "count": 265,
          "delay": 4.8523,
          "dist": 199
        },
        {
          "count": 439,
          "delay": 14.3971,
          "dist": 143
        },
        {
          "count": 17215,
          "delay": 11.3001,
          "dist": 757.1082
        },
        {
          "count": 2439,
          "delay": 6.0199,
          "dist": 1514.253
        },
        {
          "count": 275,
          "delay": 8.0038,
          "dist": 583.5818
        },
        {
          "count": 443,
          "delay": 7.0485,
          "dist": 116
        },
        {
          "count": 375,
          "delay": 8.0279,
          "dist": 378
        },
        {
          "count": 297,
          "delay": 16.8773,
          "dist": 865.9966
        },
        {
          "count": 6333,
          "delay": 11.8125,
          "dist": 758.2135
        },
        {
          "count": 15508,
          "delay": 2.9144,
          "dist": 190.637
        },
        {
          "count": 896,
          "delay": 8.2455,
          "dist": 1578.9833
        },
        {
          "count": 2589,
          "delay": 8.951,
          "dist": 265.0915
        },
        {
          "count": 4681,
          "delay": 8.946,
          "dist": 296.8084
        },
        {
          "count": 371,
          "delay": 8.1757,
          "dist": 2465
        },
        {
          "count": 1781,
          "delay": 10.7267,
          "dist": 179.4183
        },
        {
          "count": 36,
          "delay": 7.6,
          "dist": 1882
        },
        {
          "count": 116,
          "delay": 41.7642,
          "dist": 603.5517
        },
        {
          "count": 864,
          "delay": 19.6983,
          "dist": 397
        },
        {
          "count": 52,
          "delay": 9.5,
          "dist": 305
        },
        {
          "count": 2884,
          "delay": 10.593,
          "dist": 632.9168
        },
        {
          "count": 4573,
          "delay": 9.1816,
          "dist": 414.1743
        },
        {
          "count": 14064,
          "delay": 7.3603,
          "dist": 538.0273
        },
        {
          "count": 3524,
          "delay": 10.6013,
          "dist": 476.5551
        },
        {
          "count": 138,
          "delay": 14.6716,
          "dist": 444
        },
        {
          "count": 3941,
          "delay": 15.3646,
          "dist": 575.1599
        },
        {
          "count": 1525,
          "delay": 12.6805,
          "dist": 537.1023
        },
        {
          "count": 9705,
          "delay": 9.067,
          "dist": 211.0062
        },
        {
          "count": 7266,
          "delay": 8.6065,
          "dist": 1614.6784
        },
        {
          "count": 8738,
          "delay": 0.3221,
          "dist": 1383.043
        },
        {
          "count": 569,
          "delay": 19.0057,
          "dist": 1020.8875
        },
        {
          "count": 9384,
          "delay": 5.43,
          "dist": 498.1285
        },
        {
          "count": 213,
          "delay": 6.3043,
          "dist": 1735.7089
        },
        {
          "count": 12055,
          "delay": 8.0821,
          "dist": 1070.0688
        },
        {
          "count": 765,
          "delay": 18.1896,
          "dist": 605.7817
        },
        {
          "count": 1606,
          "delay": 14.1126,
          "dist": 449.8418
        },
        {
          "count": 849,
          "delay": 15.9354,
          "dist": 595.96
        },
        {
          "count": 2115,
          "delay": 7.1762,
          "dist": 1420.1551
        },
        {
          "count": 5700,
          "delay": 13.8642,
          "dist": 224.8468
        },
        {
          "count": 7198,
          "delay": 4.2408,
          "dist": 1407.2067
        },
        {
          "count": 110,
          "delay": 4.6355,
          "dist": 500
        },
        {
          "count": 2077,
          "delay": 9.9404,
          "dist": 652.2629
        },
        {
          "count": 25,
          "delay": 28.0952,
          "dist": 1875.6
        },
        {
          "count": 2720,
          "delay": 11.8448,
          "dist": 824.6761
        },
        {
          "count": 5997,
          "delay": 0.2577,
          "dist": 2240.9615
        },
        {
          "count": 16174,
          "delay": 0.5471,
          "dist": 2468.6224
        },
        {
          "count": 668,
          "delay": -0.062,
          "dist": 2465
        },
        {
          "count": 2008,
          "delay": 14.5141,
          "dist": 1097.6952
        },
        {
          "count": 14082,
          "delay": 5.4546,
          "dist": 943.1106
        },
        {
          "count": 4113,
          "delay": 12.3642,
          "dist": 718.046
        },
        {
          "count": 1789,
          "delay": 10.6453,
          "dist": 954.2012
        },
        {
          "count": 1009,
          "delay": 14.7876,
          "dist": 207.0297
        },
        {
          "count": 11728,
          "delay": 0.2991,
          "dist": 1091.5524
        },
        {
          "count": 2802,
          "delay": 14.1672,
          "dist": 733.3815
        },
        {
          "count": 572,
          "delay": 20.196,
          "dist": 803.9545
        },
        {
          "count": 7185,
          "delay": 7.2702,
          "dist": 1017.4017
        },
        {
          "count": 3799,
          "delay": 6.4902,
          "dist": 1177.7057
        },
        {
          "count": 221,
          "delay": -0.2857,
          "dist": 173
        },
        {
          "count": 59,
          "delay": 4.6034,
          "dist": 550.661
        },
        {
          "count": 312,
          "delay": 3.0777,
          "dist": 2576
        },
        {
          "count": 346,
          "delay": 30.619,
          "dist": 1325
        },
        {
          "count": 849,
          "delay": 14.6989,
          "dist": 1135.5665
        },
        {
          "count": 17283,
          "delay": 5.8766,
          "dist": 729.0008
        },
        {
          "count": 1536,
          "delay": 10.9491,
          "dist": 288.5234
        },
        {
          "count": 6554,
          "delay": 8.563,
          "dist": 1028.8381
        },
        {
          "count": 1354,
          "delay": 5.1416,
          "dist": 2445.5657
        },
        {
          "count": 1632,
          "delay": 10.1272,
          "dist": 94.3235
        },
        {
          "count": 4656,
          "delay": 2.097,
          "dist": 2141.3033
        },
        {
          "count": 2875,
          "delay": 7.681,
          "dist": 334.0612
        },
        {
          "count": 365,
          "delay": 7.8715,
          "dist": 1617
        },
        {
          "count": 376,
          "delay": 16.2346,
          "dist": 160
        },
        {
          "count": 2352,
          "delay": 11.6604,
          "dist": 276.1284
        },
        {
          "count": 8163,
          "delay": 10.0524,
          "dist": 426.7577
        },
        {
          "count": 2454,
          "delay": 20.1113,
          "dist": 281.4046
        },
        {
          "count": 2416,
          "delay": 11.5606,
          "dist": 259.2508
        },
        {
          "count": 3537,
          "delay": 3.2381,
          "dist": 1072.8533
        },
        {
          "count": 2737,
          "delay": 3.1392,
          "dist": 2437.2992
        },
        {
          "count": 686,
          "delay": 6.9454,
          "dist": 1578.3411
        },
        {
          "count": 804,
          "delay": 15.1295,
          "dist": 709.1841
        },
        {
          "count": 1157,
          "delay": 12.6694,
          "dist": 645.9836
        },
        {
          "count": 3923,
          "delay": -1.0991,
          "dist": 2412.6653
        },
        {
          "count": 13331,
          "delay": 2.6729,
          "dist": 2577.9236
        },
        {
          "count": 329,
          "delay": 3.4482,
          "dist": 2569
        },
        {
          "count": 5819,
          "delay": 2.5205,
          "dist": 1599.8336
        },
        {
          "count": 2467,
          "delay": 0.1763,
          "dist": 1986.9866
        },
        {
          "count": 284,
          "delay": 12.1099,
          "dist": 2521
        },
        {
          "count": 825,
          "delay": -7.8682,
          "dist": 2434
        },
        {
          "count": 1211,
          "delay": 3.0824,
          "dist": 1044.6515
        },
        {
          "count": 4339,
          "delay": 11.0785,
          "dist": 878.7232
        },
        {
          "count": 522,
          "delay": -3.8359,
          "dist": 1626.9828
        },
        {
          "count": 1761,
          "delay": 8.9039,
          "dist": 205.9216
        },
        {
          "count": 7466,
          "delay": 7.4085,
          "dist": 1003.9356
        },
        {
          "count": 315,
          "delay": 33.6599,
          "dist": 1215
        },
        {
          "count": 101,
          "delay": 12.9684,
          "dist": 652.3861
        },
        {
          "count": 631,
          "delay": 24.0692,
          "dist": 638.8098
        },
        {
          "count": 1036,
          "delay": 7.4657,
          "dist": 1142.5058
        }
      ]
    },
    "layer": [
      {
        "encoding": {
          "x": {
            "field": "dist",
            "type": "quantitative"
          },
          "y": {
            "field": "delay",
            "type": "quantitative"
          }
        },
        "mark": "point"
      },
      {
        "encoding": {
          "x": {
            "field": "dist",
            "type": "quantitative"
          },
          "y": {
            "field": "delay",
            "type": "quantitative"
          }
        },
        "mark": "line",
        "transform": [
          {
            "loess": "delay",
            "on": "dist"
          }
        ]
      }
    ]
  },
  "embed_options": {
    "defaultStyle": true,
    "renderer": "canvas"
  }
},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Wow, there are some planes that have an _average_ delay of 5 hours (300 minutes)!

The story is actually a little more nuanced. We can get more insight if we draw a scatterplot of number of flights vs. average delay:


```python
delays = (not_cancelled
  .groupby('tailnum')
  .agg(
    delay = ("arr_delay", np.mean),
    n = ('arr_delay', 'size')
    ))

chart = (alt.Chart(delays)
    .encode(
      x = 'n',
      y = 'delay'
      )
    .mark_point(
      filled = True, 
      opacity = 1/10))
```


<!--html_preserve--><div id="htmlwidget-36aa3d2a04d42bbc2145" style="width:auto;height:auto;" class="vegawidget html-widget"></div>
<script type="application/json" data-for="htmlwidget-36aa3d2a04d42bbc2145">{"x":{
  "chart_spec": {
    "$schema": "https://vega.github.io/schema/vega-lite/v4.8.1.json",
    "config": {
      "view": {
        "continuousHeight": 300,
        "continuousWidth": 400
      }
    },
    "data": {
      "name": "data-13db3e4b2a84794fad5c0c94ebc8debf"
    },
    "datasets": {
      "data-13db3e4b2a84794fad5c0c94ebc8debf": [
        {
          "delay": 31.5,
          "n": 4
        },
        {
          "delay": 9.983,
          "n": 352
        },
        {
          "delay": 12.7172,
          "n": 145
        },
        {
          "delay": 2.9375,
          "n": 48
        },
        {
          "delay": -6.9348,
          "n": 46
        },
        {
          "delay": 1.8043,
          "n": 46
        },
        {
          "delay": 20.6914,
          "n": 269
        },
        {
          "delay": -0.2667,
          "n": 45
        },
        {
          "delay": -5.7317,
          "n": 41
        },
        {
          "delay": -1.25,
          "n": 60
        },
        {
          "delay": -2.5208,
          "n": 48
        },
        {
          "delay": 2.8,
          "n": 40
        },
        {
          "delay": 14.881,
          "n": 126
        },
        {
          "delay": 15.0144,
          "n": 139
        },
        {
          "delay": 14.8511,
          "n": 141
        },
        {
          "delay": 15.7619,
          "n": 126
        },
        {
          "delay": 30.3066,
          "n": 137
        },
        {
          "delay": 10.3061,
          "n": 147
        },
        {
          "delay": 13.605,
          "n": 119
        },
        {
          "delay": 20.5514,
          "n": 107
        },
        {
          "delay": 18.3121,
          "n": 141
        },
        {
          "delay": 8.8915,
          "n": 129
        },
        {
          "delay": 12.9896,
          "n": 96
        },
        {
          "delay": 21.6496,
          "n": 137
        },
        {
          "delay": 8.3467,
          "n": 150
        },
        {
          "delay": 20.4046,
          "n": 131
        },
        {
          "delay": 9.075,
          "n": 120
        },
        {
          "delay": 6.9844,
          "n": 128
        },
        {
          "delay": 11.1905,
          "n": 126
        },
        {
          "delay": 6.7372,
          "n": 137
        },
        {
          "delay": 21.9355,
          "n": 124
        },
        {
          "delay": 25.8523,
          "n": 149
        },
        {
          "delay": 16.3784,
          "n": 148
        },
        {
          "delay": 8.1486,
          "n": 148
        },
        {
          "delay": 20,
          "n": 123
        },
        {
          "delay": -0.4667,
          "n": 30
        },
        {
          "delay": 12.7387,
          "n": 111
        },
        {
          "delay": -0.9474,
          "n": 38
        },
        {
          "delay": -0.7442,
          "n": 43
        },
        {
          "delay": -2.2308,
          "n": 39
        },
        {
          "delay": 21.5625,
          "n": 208
        },
        {
          "delay": 11.7116,
          "n": 267
        },
        {
          "delay": 13.3853,
          "n": 218
        },
        {
          "delay": 14.9624,
          "n": 213
        },
        {
          "delay": 18.004,
          "n": 253
        },
        {
          "delay": 16.7763,
          "n": 228
        },
        {
          "delay": 12.2723,
          "n": 224
        },
        {
          "delay": 20.7045,
          "n": 220
        },
        {
          "delay": -6.2826,
          "n": 46
        },
        {
          "delay": 2.3023,
          "n": 43
        },
        {
          "delay": -0.1538,
          "n": 39
        },
        {
          "delay": -9.381,
          "n": 21
        },
        {
          "delay": 7.375,
          "n": 16
        },
        {
          "delay": 10.4767,
          "n": 86
        },
        {
          "delay": 6.9559,
          "n": 68
        },
        {
          "delay": 7.0649,
          "n": 77
        },
        {
          "delay": 14.4472,
          "n": 123
        },
        {
          "delay": -1.0426,
          "n": 94
        },
        {
          "delay": 18.1319,
          "n": 144
        },
        {
          "delay": 18.8971,
          "n": 136
        },
        {
          "delay": 22.3103,
          "n": 116
        },
        {
          "delay": 11.784,
          "n": 125
        },
        {
          "delay": 6.3095,
          "n": 84
        },
        {
          "delay": 15.2143,
          "n": 140
        },
        {
          "delay": 13.2252,
          "n": 111
        },
        {
          "delay": 15.232,
          "n": 125
        },
        {
          "delay": 10.9573,
          "n": 117
        },
        {
          "delay": 11.36,
          "n": 150
        },
        {
          "delay": 22.3689,
          "n": 122
        },
        {
          "delay": 20.7469,
          "n": 162
        },
        {
          "delay": 17.2826,
          "n": 138
        },
        {
          "delay": 15,
          "n": 2
        },
        {
          "delay": 13.6129,
          "n": 31
        },
        {
          "delay": 17.216,
          "n": 125
        },
        {
          "delay": 1.2233,
          "n": 103
        },
        {
          "delay": -0.0991,
          "n": 111
        },
        {
          "delay": 7.2033,
          "n": 123
        },
        {
          "delay": -3.4286,
          "n": 112
        },
        {
          "delay": 9.6489,
          "n": 94
        },
        {
          "delay": -1.9778,
          "n": 45
        },
        {
          "delay": -0.9394,
          "n": 33
        },
        {
          "delay": -1.3478,
          "n": 46
        },
        {
          "delay": 19.6571,
          "n": 210
        },
        {
          "delay": 18.25,
          "n": 228
        },
        {
          "delay": 19.4794,
          "n": 194
        },
        {
          "delay": 16.8477,
          "n": 243
        },
        {
          "delay": 16.0795,
          "n": 264
        },
        {
          "delay": 15.7022,
          "n": 225
        },
        {
          "delay": -7.6857,
          "n": 35
        },
        {
          "delay": -5.0227,
          "n": 44
        },
        {
          "delay": -0.619,
          "n": 42
        },
        {
          "delay": -5.1795,
          "n": 39
        },
        {
          "delay": 21.5688,
          "n": 218
        },
        {
          "delay": 21.8415,
          "n": 265
        },
        {
          "delay": 13.974,
          "n": 231
        },
        {
          "delay": 12.8283,
          "n": 233
        },
        {
          "delay": 16.4689,
          "n": 209
        },
        {
          "delay": 23.0558,
          "n": 215
        },
        {
          "delay": 20.9412,
          "n": 238
        },
        {
          "delay": -5.2967,
          "n": 91
        },
        {
          "delay": -0.5278,
          "n": 72
        },
        {
          "delay": 14.5593,
          "n": 118
        },
        {
          "delay": 25.9735,
          "n": 113
        },
        {
          "delay": 18.0511,
          "n": 137
        },
        {
          "delay": 10.8239,
          "n": 142
        },
        {
          "delay": 19.5581,
          "n": 129
        },
        {
          "delay": 3.3333,
          "n": 90
        },
        {
          "delay": 12.6102,
          "n": 118
        },
        {
          "delay": 10.9804,
          "n": 51
        },
        {
          "delay": 16.6417,
          "n": 120
        },
        {
          "delay": 1.8644,
          "n": 118
        },
        {
          "delay": 15.3714,
          "n": 35
        },
        {
          "delay": 22.3143,
          "n": 35
        },
        {
          "delay": 2.2286,
          "n": 35
        },
        {
          "delay": 21.5772,
          "n": 246
        },
        {
          "delay": 17.3021,
          "n": 235
        },
        {
          "delay": 16.5486,
          "n": 257
        },
        {
          "delay": 16.8289,
          "n": 228
        },
        {
          "delay": 7.4878,
          "n": 41
        },
        {
          "delay": 146,
          "n": 1
        },
        {
          "delay": -0.4722,
          "n": 36
        },
        {
          "delay": 4.8253,
          "n": 166
        },
        {
          "delay": 5.2795,
          "n": 161
        },
        {
          "delay": 6.0309,
          "n": 162
        },
        {
          "delay": -5,
          "n": 1
        },
        {
          "delay": 15.3889,
          "n": 36
        },
        {
          "delay": 29.3846,
          "n": 26
        },
        {
          "delay": 8.8918,
          "n": 231
        },
        {
          "delay": 21.3655,
          "n": 249
        },
        {
          "delay": 21.2346,
          "n": 260
        },
        {
          "delay": 18.9961,
          "n": 257
        },
        {
          "delay": 16.4925,
          "n": 266
        },
        {
          "delay": 18.7222,
          "n": 252
        },
        {
          "delay": 13.5161,
          "n": 248
        },
        {
          "delay": 22.6613,
          "n": 248
        },
        {
          "delay": 19.1225,
          "n": 204
        },
        {
          "delay": 22.2387,
          "n": 243
        },
        {
          "delay": 20.1143,
          "n": 245
        },
        {
          "delay": 18.907,
          "n": 215
        },
        {
          "delay": 21.3032,
          "n": 221
        },
        {
          "delay": 22.1375,
          "n": 240
        },
        {
          "delay": 17.508,
          "n": 250
        },
        {
          "delay": 10.0949,
          "n": 253
        },
        {
          "delay": 21.194,
          "n": 201
        },
        {
          "delay": 19.4739,
          "n": 230
        },
        {
          "delay": 15.2839,
          "n": 236
        },
        {
          "delay": 19.4789,
          "n": 261
        },
        {
          "delay": 11.7216,
          "n": 194
        },
        {
          "delay": 17.4635,
          "n": 233
        },
        {
          "delay": 2.043,
          "n": 93
        },
        {
          "delay": 10.1046,
          "n": 153
        },
        {
          "delay": 3.3415,
          "n": 82
        },
        {
          "delay": -4.527,
          "n": 74
        },
        {
          "delay": -1.1757,
          "n": 74
        },
        {
          "delay": 18.7667,
          "n": 120
        },
        {
          "delay": 16.6387,
          "n": 119
        },
        {
          "delay": 1.5545,
          "n": 110
        },
        {
          "delay": 0.7162,
          "n": 74
        },
        {
          "delay": 0.4023,
          "n": 87
        },
        {
          "delay": 20.0826,
          "n": 109
        },
        {
          "delay": 14.8074,
          "n": 135
        },
        {
          "delay": 22.3413,
          "n": 126
        },
        {
          "delay": 10.9481,
          "n": 135
        },
        {
          "delay": 6.975,
          "n": 120
        },
        {
          "delay": 19.0336,
          "n": 119
        },
        {
          "delay": 12.7483,
          "n": 143
        },
        {
          "delay": 15.7217,
          "n": 115
        },
        {
          "delay": 12.1293,
          "n": 116
        },
        {
          "delay": 17.6211,
          "n": 161
        },
        {
          "delay": 21.2761,
          "n": 134
        },
        {
          "delay": 17.5862,
          "n": 145
        },
        {
          "delay": 13.5714,
          "n": 161
        },
        {
          "delay": 22.25,
          "n": 112
        },
        {
          "delay": 18.0265,
          "n": 113
        },
        {
          "delay": 18.822,
          "n": 118
        },
        {
          "delay": 17.24,
          "n": 100
        },
        {
          "delay": 10.3158,
          "n": 133
        },
        {
          "delay": 4.3411,
          "n": 129
        },
        {
          "delay": 9.8678,
          "n": 121
        },
        {
          "delay": 3.7117,
          "n": 111
        },
        {
          "delay": -1.2602,
          "n": 123
        },
        {
          "delay": 17.3628,
          "n": 113
        },
        {
          "delay": 5.0943,
          "n": 106
        },
        {
          "delay": 12.246,
          "n": 126
        },
        {
          "delay": 2.2432,
          "n": 111
        },
        {
          "delay": 24,
          "n": 1
        },
        {
          "delay": 11.1124,
          "n": 249
        },
        {
          "delay": 15.0858,
          "n": 233
        },
        {
          "delay": 19.791,
          "n": 268
        },
        {
          "delay": 19.5485,
          "n": 237
        },
        {
          "delay": 13.336,
          "n": 247
        },
        {
          "delay": 14.278,
          "n": 241
        },
        {
          "delay": 20.0929,
          "n": 269
        },
        {
          "delay": -6,
          "n": 1
        },
        {
          "delay": -16.25,
          "n": 4
        },
        {
          "delay": 14.0789,
          "n": 38
        },
        {
          "delay": -1.1667,
          "n": 174
        },
        {
          "delay": -3.8503,
          "n": 147
        },
        {
          "delay": -0.7143,
          "n": 14
        },
        {
          "delay": 15.8551,
          "n": 214
        },
        {
          "delay": 13.7888,
          "n": 251
        },
        {
          "delay": 22.6071,
          "n": 196
        },
        {
          "delay": 19.124,
          "n": 242
        },
        {
          "delay": 12.6803,
          "n": 244
        },
        {
          "delay": 18.6611,
          "n": 239
        },
        {
          "delay": 21.5248,
          "n": 202
        },
        {
          "delay": 25.2878,
          "n": 205
        },
        {
          "delay": 15.9336,
          "n": 256
        },
        {
          "delay": 21.9012,
          "n": 243
        },
        {
          "delay": 14.3941,
          "n": 236
        },
        {
          "delay": 18.3057,
          "n": 193
        },
        {
          "delay": 15.4513,
          "n": 195
        },
        {
          "delay": 21.1893,
          "n": 206
        },
        {
          "delay": 21.1931,
          "n": 233
        },
        {
          "delay": 9.7227,
          "n": 238
        },
        {
          "delay": 14.755,
          "n": 249
        },
        {
          "delay": 27.922,
          "n": 218
        },
        {
          "delay": 19.6818,
          "n": 22
        },
        {
          "delay": -6.5,
          "n": 6
        },
        {
          "delay": 0.0299,
          "n": 67
        },
        {
          "delay": -3.1852,
          "n": 54
        },
        {
          "delay": 24,
          "n": 2
        },
        {
          "delay": 2.6471,
          "n": 51
        },
        {
          "delay": 35.75,
          "n": 4
        },
        {
          "delay": 6.4667,
          "n": 30
        },
        {
          "delay": -1.55,
          "n": 60
        },
        {
          "delay": 3.48,
          "n": 50
        },
        {
          "delay": 0.1765,
          "n": 51
        },
        {
          "delay": 17.8571,
          "n": 224
        },
        {
          "delay": 16.8151,
          "n": 292
        },
        {
          "delay": 17.9482,
          "n": 193
        },
        {
          "delay": 30.6667,
          "n": 9
        },
        {
          "delay": -4.25,
          "n": 40
        },
        {
          "delay": 4.4375,
          "n": 16
        },
        {
          "delay": -8.7436,
          "n": 39
        },
        {
          "delay": -1.8478,
          "n": 184
        },
        {
          "delay": -1.0199,
          "n": 151
        },
        {
          "delay": -6.8,
          "n": 40
        },
        {
          "delay": 27.6113,
          "n": 265
        },
        {
          "delay": 14.9612,
          "n": 232
        },
        {
          "delay": 16.9478,
          "n": 230
        },
        {
          "delay": 23.5446,
          "n": 303
        },
        {
          "delay": 16.4874,
          "n": 238
        },
        {
          "delay": 10.3556,
          "n": 225
        },
        {
          "delay": 21.7411,
          "n": 224
        },
        {
          "delay": -5.0833,
          "n": 12
        },
        {
          "delay": 15.3125,
          "n": 16
        },
        {
          "delay": -7.6111,
          "n": 18
        },
        {
          "delay": 4.4,
          "n": 20
        },
        {
          "delay": -11.9286,
          "n": 14
        },
        {
          "delay": -16,
          "n": 3
        },
        {
          "delay": -11.3333,
          "n": 3
        },
        {
          "delay": 6.25,
          "n": 4
        },
        {
          "delay": -14.5,
          "n": 2
        },
        {
          "delay": 5.8941,
          "n": 85
        },
        {
          "delay": 7.5,
          "n": 2
        },
        {
          "delay": -20.875,
          "n": 8
        },
        {
          "delay": -6.1429,
          "n": 7
        },
        {
          "delay": 15.3832,
          "n": 107
        },
        {
          "delay": 21.6601,
          "n": 153
        },
        {
          "delay": 16.6446,
          "n": 121
        },
        {
          "delay": 20.6376,
          "n": 149
        },
        {
          "delay": 18.5243,
          "n": 103
        },
        {
          "delay": 14.632,
          "n": 125
        },
        {
          "delay": -12,
          "n": 2
        },
        {
          "delay": 2.2073,
          "n": 82
        },
        {
          "delay": -1.102,
          "n": 98
        },
        {
          "delay": -2.0636,
          "n": 110
        },
        {
          "delay": 62.5,
          "n": 2
        },
        {
          "delay": 4.2162,
          "n": 74
        },
        {
          "delay": 6.1446,
          "n": 83
        },
        {
          "delay": 19.71,
          "n": 231
        },
        {
          "delay": 20.0961,
          "n": 229
        },
        {
          "delay": 18.2689,
          "n": 212
        },
        {
          "delay": 14.9815,
          "n": 216
        },
        {
          "delay": 15.4961,
          "n": 258
        },
        {
          "delay": 2.1154,
          "n": 78
        },
        {
          "delay": -20,
          "n": 10
        },
        {
          "delay": 10.1795,
          "n": 39
        },
        {
          "delay": 0.5714,
          "n": 154
        },
        {
          "delay": 2.8294,
          "n": 170
        },
        {
          "delay": 3.6084,
          "n": 166
        },
        {
          "delay": -2.5536,
          "n": 168
        },
        {
          "delay": 1.1342,
          "n": 149
        },
        {
          "delay": 8.1333,
          "n": 90
        },
        {
          "delay": 33.8824,
          "n": 17
        },
        {
          "delay": 20.5628,
          "n": 247
        },
        {
          "delay": 20.0251,
          "n": 239
        },
        {
          "delay": 29.8874,
          "n": 231
        },
        {
          "delay": 20.0535,
          "n": 187
        },
        {
          "delay": 17.5075,
          "n": 201
        },
        {
          "delay": 23.0359,
          "n": 223
        },
        {
          "delay": 17.2026,
          "n": 227
        },
        {
          "delay": 18.7738,
          "n": 221
        },
        {
          "delay": 13.8988,
          "n": 257
        },
        {
          "delay": 21.5192,
          "n": 208
        },
        {
          "delay": 21.2113,
          "n": 194
        },
        {
          "delay": 34.1818,
          "n": 11
        },
        {
          "delay": -5.3333,
          "n": 12
        },
        {
          "delay": 5.3333,
          "n": 72
        },
        {
          "delay": -6.7143,
          "n": 7
        },
        {
          "delay": 4.2603,
          "n": 73
        },
        {
          "delay": -0.7614,
          "n": 88
        },
        {
          "delay": 1.1084,
          "n": 83
        },
        {
          "delay": 16.3942,
          "n": 137
        },
        {
          "delay": 15.1129,
          "n": 124
        },
        {
          "delay": -3.3299,
          "n": 97
        },
        {
          "delay": -0.5789,
          "n": 95
        },
        {
          "delay": 5.382,
          "n": 89
        },
        {
          "delay": -2.2159,
          "n": 88
        },
        {
          "delay": 13.5154,
          "n": 130
        },
        {
          "delay": -2.9011,
          "n": 91
        },
        {
          "delay": 17.069,
          "n": 116
        },
        {
          "delay": 7.7541,
          "n": 122
        },
        {
          "delay": 16.3985,
          "n": 133
        },
        {
          "delay": 9.4088,
          "n": 137
        },
        {
          "delay": 7.5035,
          "n": 141
        },
        {
          "delay": -4.8182,
          "n": 11
        },
        {
          "delay": -6.4375,
          "n": 16
        },
        {
          "delay": 1.642,
          "n": 81
        },
        {
          "delay": 5.5211,
          "n": 142
        },
        {
          "delay": 4.7027,
          "n": 111
        },
        {
          "delay": 7.5047,
          "n": 107
        },
        {
          "delay": 4.7851,
          "n": 121
        },
        {
          "delay": 20.2667,
          "n": 15
        },
        {
          "delay": -5.7692,
          "n": 13
        },
        {
          "delay": 2.7077,
          "n": 65
        },
        {
          "delay": 50.6667,
          "n": 9
        },
        {
          "delay": 17.8095,
          "n": 21
        },
        {
          "delay": 3.8171,
          "n": 82
        },
        {
          "delay": 6.5,
          "n": 8
        },
        {
          "delay": 25.7895,
          "n": 19
        },
        {
          "delay": -16.4,
          "n": 15
        },
        {
          "delay": 4.1294,
          "n": 85
        },
        {
          "delay": 19.6125,
          "n": 160
        },
        {
          "delay": 21.2,
          "n": 5
        },
        {
          "delay": -14.9,
          "n": 10
        },
        {
          "delay": -7,
          "n": 19
        },
        {
          "delay": 15.5,
          "n": 2
        },
        {
          "delay": 41.5556,
          "n": 9
        },
        {
          "delay": 46.25,
          "n": 12
        },
        {
          "delay": 3.7647,
          "n": 17
        },
        {
          "delay": 11.7778,
          "n": 27
        },
        {
          "delay": 6.1807,
          "n": 83
        },
        {
          "delay": -3.6093,
          "n": 151
        },
        {
          "delay": 1.3882,
          "n": 152
        },
        {
          "delay": 2.7,
          "n": 10
        },
        {
          "delay": -6.5,
          "n": 8
        },
        {
          "delay": -1.4861,
          "n": 72
        },
        {
          "delay": -0.9167,
          "n": 12
        },
        {
          "delay": 7.0909,
          "n": 11
        },
        {
          "delay": 13.7524,
          "n": 315
        },
        {
          "delay": 4.9538,
          "n": 65
        },
        {
          "delay": 23.713,
          "n": 223
        },
        {
          "delay": -4,
          "n": 6
        },
        {
          "delay": 14.3055,
          "n": 311
        },
        {
          "delay": 1.7237,
          "n": 76
        },
        {
          "delay": 4.8,
          "n": 35
        },
        {
          "delay": 5.8281,
          "n": 64
        },
        {
          "delay": 17.3366,
          "n": 101
        },
        {
          "delay": 14.3578,
          "n": 109
        },
        {
          "delay": -3.4535,
          "n": 86
        },
        {
          "delay": 17.4959,
          "n": 123
        },
        {
          "delay": -0.6667,
          "n": 111
        },
        {
          "delay": 16.7373,
          "n": 118
        },
        {
          "delay": -1.1667,
          "n": 12
        },
        {
          "delay": -1.4571,
          "n": 35
        },
        {
          "delay": 10.2698,
          "n": 63
        },
        {
          "delay": 1.6887,
          "n": 106
        },
        {
          "delay": 2.1091,
          "n": 110
        },
        {
          "delay": 6.31,
          "n": 100
        },
        {
          "delay": -8.4167,
          "n": 12
        },
        {
          "delay": 3.9818,
          "n": 55
        },
        {
          "delay": 10.0435,
          "n": 23
        },
        {
          "delay": 8.409,
          "n": 357
        },
        {
          "delay": 1.9,
          "n": 60
        },
        {
          "delay": 17.25,
          "n": 4
        },
        {
          "delay": 43.5625,
          "n": 16
        },
        {
          "delay": 11.2485,
          "n": 342
        },
        {
          "delay": 5.56,
          "n": 75
        },
        {
          "delay": 20.6564,
          "n": 195
        },
        {
          "delay": 18.0926,
          "n": 270
        },
        {
          "delay": 3.2143,
          "n": 14
        },
        {
          "delay": 2.1618,
          "n": 68
        },
        {
          "delay": 3.5556,
          "n": 27
        },
        {
          "delay": 7.6071,
          "n": 28
        },
        {
          "delay": 4.5714,
          "n": 63
        },
        {
          "delay": -1.2,
          "n": 65
        },
        {
          "delay": 10.5468,
          "n": 331
        },
        {
          "delay": 2.4,
          "n": 5
        },
        {
          "delay": -0.4865,
          "n": 74
        },
        {
          "delay": -0.7083,
          "n": 72
        },
        {
          "delay": 8.9789,
          "n": 95
        },
        {
          "delay": -4.1455,
          "n": 55
        },
        {
          "delay": 5.52,
          "n": 75
        },
        {
          "delay": -3.2308,
          "n": 52
        },
        {
          "delay": 12.323,
          "n": 356
        },
        {
          "delay": 1.5972,
          "n": 72
        },
        {
          "delay": 0.2317,
          "n": 82
        },
        {
          "delay": 0.1284,
          "n": 109
        },
        {
          "delay": 3.1618,
          "n": 68
        },
        {
          "delay": 1.6292,
          "n": 89
        },
        {
          "delay": -2.3492,
          "n": 63
        },
        {
          "delay": -2.2344,
          "n": 64
        },
        {
          "delay": 6.3966,
          "n": 58
        },
        {
          "delay": 18.5623,
          "n": 313
        },
        {
          "delay": 1.8706,
          "n": 85
        },
        {
          "delay": -4.2321,
          "n": 56
        },
        {
          "delay": 2.8761,
          "n": 331
        },
        {
          "delay": 1.0103,
          "n": 97
        },
        {
          "delay": -1.7925,
          "n": 53
        },
        {
          "delay": 5.8553,
          "n": 76
        },
        {
          "delay": 16.1192,
          "n": 302
        },
        {
          "delay": 8.5303,
          "n": 66
        },
        {
          "delay": 15.1333,
          "n": 15
        },
        {
          "delay": 1.625,
          "n": 72
        },
        {
          "delay": 7.1702,
          "n": 47
        },
        {
          "delay": 5.6667,
          "n": 66
        },
        {
          "delay": -5.7414,
          "n": 58
        },
        {
          "delay": 13.2739,
          "n": 230
        },
        {
          "delay": 8.4194,
          "n": 31
        },
        {
          "delay": 4.3294,
          "n": 85
        },
        {
          "delay": -5.3585,
          "n": 53
        },
        {
          "delay": 14.1605,
          "n": 299
        },
        {
          "delay": 1.5422,
          "n": 83
        },
        {
          "delay": 21.299,
          "n": 204
        },
        {
          "delay": -2.0741,
          "n": 54
        },
        {
          "delay": 0.4412,
          "n": 68
        },
        {
          "delay": 14.67,
          "n": 200
        },
        {
          "delay": -10.3333,
          "n": 30
        },
        {
          "delay": 11.9706,
          "n": 34
        },
        {
          "delay": 12.9643,
          "n": 28
        },
        {
          "delay": 14.1176,
          "n": 51
        },
        {
          "delay": 34.4412,
          "n": 34
        },
        {
          "delay": 17.5625,
          "n": 32
        },
        {
          "delay": 4.8571,
          "n": 35
        },
        {
          "delay": 20.1489,
          "n": 47
        },
        {
          "delay": 13.1364,
          "n": 22
        },
        {
          "delay": 59.122,
          "n": 41
        },
        {
          "delay": 12.7801,
          "n": 282
        },
        {
          "delay": 14.4118,
          "n": 34
        },
        {
          "delay": 37.3542,
          "n": 48
        },
        {
          "delay": 4.3929,
          "n": 28
        },
        {
          "delay": 22.8723,
          "n": 47
        },
        {
          "delay": 11.9048,
          "n": 21
        },
        {
          "delay": 8.8788,
          "n": 33
        },
        {
          "delay": 5.2993,
          "n": 304
        },
        {
          "delay": -20,
          "n": 1
        },
        {
          "delay": 8.8095,
          "n": 21
        },
        {
          "delay": 14.2121,
          "n": 33
        },
        {
          "delay": -0.3462,
          "n": 26
        },
        {
          "delay": 18.56,
          "n": 25
        },
        {
          "delay": 3.45,
          "n": 20
        },
        {
          "delay": -22,
          "n": 2
        },
        {
          "delay": 15.1765,
          "n": 34
        },
        {
          "delay": -5.8438,
          "n": 32
        },
        {
          "delay": 15.15,
          "n": 40
        },
        {
          "delay": 14.0769,
          "n": 26
        },
        {
          "delay": -1.92,
          "n": 100
        },
        {
          "delay": 18.2031,
          "n": 128
        },
        {
          "delay": 24.9661,
          "n": 118
        },
        {
          "delay": 21.2677,
          "n": 127
        },
        {
          "delay": 14.0654,
          "n": 153
        },
        {
          "delay": 17.559,
          "n": 161
        },
        {
          "delay": 12.1935,
          "n": 31
        },
        {
          "delay": 4.5455,
          "n": 33
        },
        {
          "delay": 10.8889,
          "n": 18
        },
        {
          "delay": 8.1915,
          "n": 47
        },
        {
          "delay": 10.9643,
          "n": 28
        },
        {
          "delay": 14.1429,
          "n": 42
        },
        {
          "delay": 1.8696,
          "n": 23
        },
        {
          "delay": 23.4203,
          "n": 207
        },
        {
          "delay": 16.3333,
          "n": 24
        },
        {
          "delay": 21.5952,
          "n": 42
        },
        {
          "delay": 10.3009,
          "n": 339
        },
        {
          "delay": 8.5862,
          "n": 29
        },
        {
          "delay": 3.3521,
          "n": 142
        },
        {
          "delay": 6.0882,
          "n": 34
        },
        {
          "delay": 18.9706,
          "n": 68
        },
        {
          "delay": 16.08,
          "n": 25
        },
        {
          "delay": 20.3182,
          "n": 22
        },
        {
          "delay": 15.2083,
          "n": 24
        },
        {
          "delay": -3,
          "n": 4
        },
        {
          "delay": 13.7667,
          "n": 30
        },
        {
          "delay": 19.9167,
          "n": 24
        },
        {
          "delay": 19.0357,
          "n": 28
        },
        {
          "delay": 0.1379,
          "n": 29
        },
        {
          "delay": 10.1364,
          "n": 22
        },
        {
          "delay": 8.1923,
          "n": 26
        },
        {
          "delay": 34.88,
          "n": 25
        },
        {
          "delay": 17.8368,
          "n": 380
        },
        {
          "delay": 3.7407,
          "n": 27
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": 6.9259,
          "n": 27
        },
        {
          "delay": 20.4332,
          "n": 247
        },
        {
          "delay": 24.7477,
          "n": 214
        },
        {
          "delay": 12.5181,
          "n": 359
        },
        {
          "delay": 12.963,
          "n": 27
        },
        {
          "delay": 1.5714,
          "n": 21
        },
        {
          "delay": 12.6493,
          "n": 134
        },
        {
          "delay": 11.0325,
          "n": 277
        },
        {
          "delay": 26,
          "n": 41
        },
        {
          "delay": 13.0976,
          "n": 41
        },
        {
          "delay": 15.8788,
          "n": 33
        },
        {
          "delay": 21.4,
          "n": 30
        },
        {
          "delay": 2.7879,
          "n": 33
        },
        {
          "delay": 36.0385,
          "n": 26
        },
        {
          "delay": 7.6634,
          "n": 303
        },
        {
          "delay": 12.6111,
          "n": 36
        },
        {
          "delay": 0.1916,
          "n": 167
        },
        {
          "delay": 4.5155,
          "n": 161
        },
        {
          "delay": 1.4228,
          "n": 149
        },
        {
          "delay": 8.8611,
          "n": 36
        },
        {
          "delay": 14.2645,
          "n": 310
        },
        {
          "delay": 0.0857,
          "n": 35
        },
        {
          "delay": 11.5451,
          "n": 266
        },
        {
          "delay": 12.2308,
          "n": 26
        },
        {
          "delay": 53.6,
          "n": 5
        },
        {
          "delay": 5.2381,
          "n": 21
        },
        {
          "delay": 5.2598,
          "n": 127
        },
        {
          "delay": 24.918,
          "n": 122
        },
        {
          "delay": 19.9643,
          "n": 28
        },
        {
          "delay": 0.7404,
          "n": 104
        },
        {
          "delay": 7.7,
          "n": 130
        },
        {
          "delay": 7.3417,
          "n": 120
        },
        {
          "delay": 5.9487,
          "n": 78
        },
        {
          "delay": 16.4722,
          "n": 36
        },
        {
          "delay": 9,
          "n": 32
        },
        {
          "delay": 15.3333,
          "n": 36
        },
        {
          "delay": -1,
          "n": 2
        },
        {
          "delay": 8,
          "n": 26
        },
        {
          "delay": 10,
          "n": 8
        },
        {
          "delay": 18.7143,
          "n": 35
        },
        {
          "delay": 0.1754,
          "n": 171
        },
        {
          "delay": -0.4663,
          "n": 178
        },
        {
          "delay": -2,
          "n": 162
        },
        {
          "delay": 2.7619,
          "n": 168
        },
        {
          "delay": 8.6127,
          "n": 346
        },
        {
          "delay": 12.2188,
          "n": 32
        },
        {
          "delay": 9.0714,
          "n": 42
        },
        {
          "delay": 8.8052,
          "n": 349
        },
        {
          "delay": -9.2414,
          "n": 29
        },
        {
          "delay": 4.1667,
          "n": 30
        },
        {
          "delay": 18.3235,
          "n": 102
        },
        {
          "delay": 4.4848,
          "n": 33
        },
        {
          "delay": 2.4074,
          "n": 27
        },
        {
          "delay": 0.7407,
          "n": 27
        },
        {
          "delay": 4.9667,
          "n": 30
        },
        {
          "delay": -3.1795,
          "n": 39
        },
        {
          "delay": 3.1429,
          "n": 21
        },
        {
          "delay": 2.7289,
          "n": 166
        },
        {
          "delay": 8.6667,
          "n": 30
        },
        {
          "delay": 13.069,
          "n": 420
        },
        {
          "delay": 7.9231,
          "n": 39
        },
        {
          "delay": -4.75,
          "n": 24
        },
        {
          "delay": 0.3871,
          "n": 31
        },
        {
          "delay": 4.215,
          "n": 107
        },
        {
          "delay": 2.6182,
          "n": 110
        },
        {
          "delay": 62.4444,
          "n": 9
        },
        {
          "delay": 13.3333,
          "n": 6
        },
        {
          "delay": 3.4571,
          "n": 35
        },
        {
          "delay": 0.7107,
          "n": 121
        },
        {
          "delay": 5.3146,
          "n": 89
        },
        {
          "delay": 0.6931,
          "n": 101
        },
        {
          "delay": -4.3478,
          "n": 115
        },
        {
          "delay": 6.2121,
          "n": 33
        },
        {
          "delay": 25.7317,
          "n": 41
        },
        {
          "delay": 5.5938,
          "n": 32
        },
        {
          "delay": 17.3667,
          "n": 30
        },
        {
          "delay": 16.8656,
          "n": 253
        },
        {
          "delay": 18.5404,
          "n": 235
        },
        {
          "delay": 10.2284,
          "n": 289
        },
        {
          "delay": 20.56,
          "n": 25
        },
        {
          "delay": 12.5441,
          "n": 340
        },
        {
          "delay": 2.32,
          "n": 25
        },
        {
          "delay": 29.5238,
          "n": 21
        },
        {
          "delay": 11.2948,
          "n": 329
        },
        {
          "delay": 3.9259,
          "n": 27
        },
        {
          "delay": 6.9655,
          "n": 29
        },
        {
          "delay": 19,
          "n": 1
        },
        {
          "delay": 8.6571,
          "n": 35
        },
        {
          "delay": 3.8889,
          "n": 27
        },
        {
          "delay": 14.2476,
          "n": 105
        },
        {
          "delay": 3.9661,
          "n": 118
        },
        {
          "delay": 0.68,
          "n": 25
        },
        {
          "delay": 24.5101,
          "n": 149
        },
        {
          "delay": 1.5614,
          "n": 114
        },
        {
          "delay": 5.5701,
          "n": 107
        },
        {
          "delay": 2.2054,
          "n": 112
        },
        {
          "delay": 19.5882,
          "n": 17
        },
        {
          "delay": 8.9231,
          "n": 39
        },
        {
          "delay": 2.0833,
          "n": 24
        },
        {
          "delay": 30.0769,
          "n": 13
        },
        {
          "delay": 12.8839,
          "n": 267
        },
        {
          "delay": -4.9615,
          "n": 26
        },
        {
          "delay": -0.3095,
          "n": 84
        },
        {
          "delay": 2.0909,
          "n": 44
        },
        {
          "delay": 9.2161,
          "n": 361
        },
        {
          "delay": 35.2727,
          "n": 22
        },
        {
          "delay": 7.3462,
          "n": 26
        },
        {
          "delay": 80.3333,
          "n": 6
        },
        {
          "delay": 8.7059,
          "n": 34
        },
        {
          "delay": 2.8442,
          "n": 154
        },
        {
          "delay": 3.8571,
          "n": 175
        },
        {
          "delay": 4.6949,
          "n": 177
        },
        {
          "delay": 7.4,
          "n": 30
        },
        {
          "delay": 48.1429,
          "n": 7
        },
        {
          "delay": 1.8276,
          "n": 29
        },
        {
          "delay": -1,
          "n": 1
        },
        {
          "delay": 16.5878,
          "n": 262
        },
        {
          "delay": 3.4286,
          "n": 7
        },
        {
          "delay": 15.629,
          "n": 283
        },
        {
          "delay": 12.6667,
          "n": 42
        },
        {
          "delay": 13.2593,
          "n": 27
        },
        {
          "delay": 6.3611,
          "n": 36
        },
        {
          "delay": 29.8235,
          "n": 17
        },
        {
          "delay": 10.9241,
          "n": 316
        },
        {
          "delay": 2.1212,
          "n": 33
        },
        {
          "delay": 15.4286,
          "n": 28
        },
        {
          "delay": 34.5,
          "n": 14
        },
        {
          "delay": 8.4269,
          "n": 342
        },
        {
          "delay": -2.4615,
          "n": 26
        },
        {
          "delay": 0,
          "n": 109
        },
        {
          "delay": -2.9623,
          "n": 53
        },
        {
          "delay": 51.5556,
          "n": 9
        },
        {
          "delay": 12.2904,
          "n": 272
        },
        {
          "delay": 2.3056,
          "n": 36
        },
        {
          "delay": 7.9286,
          "n": 14
        },
        {
          "delay": 0.7941,
          "n": 34
        },
        {
          "delay": 21.2432,
          "n": 37
        },
        {
          "delay": -18,
          "n": 1
        },
        {
          "delay": 2.6667,
          "n": 27
        },
        {
          "delay": 6.5676,
          "n": 37
        },
        {
          "delay": 17,
          "n": 6
        },
        {
          "delay": 12,
          "n": 26
        },
        {
          "delay": 36.9375,
          "n": 16
        },
        {
          "delay": 6.641,
          "n": 39
        },
        {
          "delay": -4.3846,
          "n": 91
        },
        {
          "delay": 3.697,
          "n": 99
        },
        {
          "delay": 8.25,
          "n": 4
        },
        {
          "delay": 8.5938,
          "n": 32
        },
        {
          "delay": 18.3671,
          "n": 316
        },
        {
          "delay": 12.3443,
          "n": 61
        },
        {
          "delay": 25.8462,
          "n": 26
        },
        {
          "delay": 10.5152,
          "n": 66
        },
        {
          "delay": 15.5714,
          "n": 21
        },
        {
          "delay": 6.4686,
          "n": 303
        },
        {
          "delay": 22.3784,
          "n": 37
        },
        {
          "delay": 23.0625,
          "n": 32
        },
        {
          "delay": 30.75,
          "n": 4
        },
        {
          "delay": 7.7917,
          "n": 48
        },
        {
          "delay": 8.5,
          "n": 24
        },
        {
          "delay": 12.6507,
          "n": 355
        },
        {
          "delay": 16.4889,
          "n": 45
        },
        {
          "delay": 8.1875,
          "n": 32
        },
        {
          "delay": 1.2481,
          "n": 133
        },
        {
          "delay": 23.1364,
          "n": 22
        },
        {
          "delay": 28,
          "n": 31
        },
        {
          "delay": 9.9552,
          "n": 402
        },
        {
          "delay": 21.2963,
          "n": 27
        },
        {
          "delay": 11.25,
          "n": 24
        },
        {
          "delay": 17.2864,
          "n": 199
        },
        {
          "delay": 19.3684,
          "n": 247
        },
        {
          "delay": 32.6667,
          "n": 6
        },
        {
          "delay": 9.1364,
          "n": 22
        },
        {
          "delay": -9.8,
          "n": 30
        },
        {
          "delay": 2.274,
          "n": 146
        },
        {
          "delay": 5.4227,
          "n": 220
        },
        {
          "delay": 29,
          "n": 1
        },
        {
          "delay": 1.1056,
          "n": 142
        },
        {
          "delay": 2.1552,
          "n": 232
        },
        {
          "delay": 46,
          "n": 1
        },
        {
          "delay": 5.6875,
          "n": 128
        },
        {
          "delay": 5.3667,
          "n": 90
        },
        {
          "delay": -0.0956,
          "n": 136
        },
        {
          "delay": 10.4157,
          "n": 332
        },
        {
          "delay": 90.5,
          "n": 2
        },
        {
          "delay": -4.259,
          "n": 139
        },
        {
          "delay": -25,
          "n": 1
        },
        {
          "delay": -1.6512,
          "n": 129
        },
        {
          "delay": 7.6477,
          "n": 281
        },
        {
          "delay": -8,
          "n": 2
        },
        {
          "delay": -1.1885,
          "n": 122
        },
        {
          "delay": 8.4903,
          "n": 257
        },
        {
          "delay": 31.4286,
          "n": 14
        },
        {
          "delay": 3.536,
          "n": 125
        },
        {
          "delay": 51,
          "n": 2
        },
        {
          "delay": 8.2857,
          "n": 14
        },
        {
          "delay": -0.2977,
          "n": 131
        },
        {
          "delay": 6.408,
          "n": 299
        },
        {
          "delay": 8.7407,
          "n": 135
        },
        {
          "delay": 3.5211,
          "n": 142
        },
        {
          "delay": 9.9358,
          "n": 109
        },
        {
          "delay": 20.7041,
          "n": 98
        },
        {
          "delay": 6.4237,
          "n": 59
        },
        {
          "delay": 10.3271,
          "n": 107
        },
        {
          "delay": 1.283,
          "n": 106
        },
        {
          "delay": 6.589,
          "n": 73
        },
        {
          "delay": 1.6419,
          "n": 215
        },
        {
          "delay": 1.4578,
          "n": 83
        },
        {
          "delay": -51,
          "n": 1
        },
        {
          "delay": -3.3333,
          "n": 3
        },
        {
          "delay": -3.1202,
          "n": 208
        },
        {
          "delay": 2.2473,
          "n": 93
        },
        {
          "delay": 12.7692,
          "n": 13
        },
        {
          "delay": 4.6356,
          "n": 247
        },
        {
          "delay": 1.1837,
          "n": 196
        },
        {
          "delay": 1.6463,
          "n": 82
        },
        {
          "delay": 12.2788,
          "n": 330
        },
        {
          "delay": -2.5632,
          "n": 190
        },
        {
          "delay": 5.9487,
          "n": 78
        },
        {
          "delay": -5,
          "n": 2
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": 25.8,
          "n": 5
        },
        {
          "delay": 10.0753,
          "n": 292
        },
        {
          "delay": -1.12,
          "n": 200
        },
        {
          "delay": 1.8118,
          "n": 85
        },
        {
          "delay": 2.1048,
          "n": 353
        },
        {
          "delay": 3.3333,
          "n": 3
        },
        {
          "delay": 2.8698,
          "n": 215
        },
        {
          "delay": 2.7083,
          "n": 120
        },
        {
          "delay": -4.8464,
          "n": 306
        },
        {
          "delay": -9.5,
          "n": 2
        },
        {
          "delay": -2.1509,
          "n": 265
        },
        {
          "delay": 0.1538,
          "n": 104
        },
        {
          "delay": -2.5938,
          "n": 224
        },
        {
          "delay": -3.566,
          "n": 106
        },
        {
          "delay": 0,
          "n": 15
        },
        {
          "delay": 0.3689,
          "n": 206
        },
        {
          "delay": 9.8,
          "n": 110
        },
        {
          "delay": -2.5296,
          "n": 355
        },
        {
          "delay": 38,
          "n": 2
        },
        {
          "delay": 10.6458,
          "n": 319
        },
        {
          "delay": -2.1502,
          "n": 213
        },
        {
          "delay": 5.8571,
          "n": 98
        },
        {
          "delay": 4.551,
          "n": 98
        },
        {
          "delay": -0.2562,
          "n": 324
        },
        {
          "delay": 12.7439,
          "n": 367
        },
        {
          "delay": 2.3232,
          "n": 198
        },
        {
          "delay": 4.0515,
          "n": 136
        },
        {
          "delay": 1.2857,
          "n": 7
        },
        {
          "delay": 0.8531,
          "n": 177
        },
        {
          "delay": 10.065,
          "n": 123
        },
        {
          "delay": 5,
          "n": 1
        },
        {
          "delay": 26.4118,
          "n": 17
        },
        {
          "delay": 5.7725,
          "n": 233
        },
        {
          "delay": 2.1524,
          "n": 105
        },
        {
          "delay": 1.1706,
          "n": 381
        },
        {
          "delay": -0.0229,
          "n": 218
        },
        {
          "delay": 3.0833,
          "n": 108
        },
        {
          "delay": -3.5219,
          "n": 389
        },
        {
          "delay": 23.6667,
          "n": 3
        },
        {
          "delay": 10.4542,
          "n": 306
        },
        {
          "delay": 7.5319,
          "n": 47
        },
        {
          "delay": 5.6058,
          "n": 104
        },
        {
          "delay": -2.7807,
          "n": 342
        },
        {
          "delay": 7.6667,
          "n": 18
        },
        {
          "delay": 8.6558,
          "n": 276
        },
        {
          "delay": 2.1405,
          "n": 242
        },
        {
          "delay": 7.6,
          "n": 120
        },
        {
          "delay": 24.8889,
          "n": 18
        },
        {
          "delay": 3.4091,
          "n": 44
        },
        {
          "delay": -4.4248,
          "n": 113
        },
        {
          "delay": -0.1262,
          "n": 103
        },
        {
          "delay": 2.092,
          "n": 87
        },
        {
          "delay": 10.9062,
          "n": 160
        },
        {
          "delay": 12.5932,
          "n": 59
        },
        {
          "delay": 0.2422,
          "n": 128
        },
        {
          "delay": 4.0729,
          "n": 96
        },
        {
          "delay": 5.0291,
          "n": 103
        },
        {
          "delay": 3.5397,
          "n": 126
        },
        {
          "delay": 0.8056,
          "n": 108
        },
        {
          "delay": 4.0813,
          "n": 123
        },
        {
          "delay": 4.8261,
          "n": 115
        },
        {
          "delay": 1.6068,
          "n": 117
        },
        {
          "delay": 2.4622,
          "n": 119
        },
        {
          "delay": 5.1721,
          "n": 122
        },
        {
          "delay": 3.7228,
          "n": 101
        },
        {
          "delay": 2.1662,
          "n": 325
        },
        {
          "delay": -1.7026,
          "n": 232
        },
        {
          "delay": 1.0476,
          "n": 105
        },
        {
          "delay": -0.916,
          "n": 119
        },
        {
          "delay": 9.6852,
          "n": 108
        },
        {
          "delay": 9.9133,
          "n": 323
        },
        {
          "delay": -2.4615,
          "n": 182
        },
        {
          "delay": -1.3689,
          "n": 103
        },
        {
          "delay": -1.7592,
          "n": 382
        },
        {
          "delay": 2.4787,
          "n": 188
        },
        {
          "delay": -3.7273,
          "n": 99
        },
        {
          "delay": 2.4274,
          "n": 351
        },
        {
          "delay": 8,
          "n": 16
        },
        {
          "delay": -2.2869,
          "n": 251
        },
        {
          "delay": 4.6777,
          "n": 121
        },
        {
          "delay": 5.0734,
          "n": 177
        },
        {
          "delay": 66.5385,
          "n": 13
        },
        {
          "delay": 13.4579,
          "n": 297
        },
        {
          "delay": 1.5488,
          "n": 164
        },
        {
          "delay": -2.53,
          "n": 100
        },
        {
          "delay": -2.3516,
          "n": 384
        },
        {
          "delay": 20.5625,
          "n": 16
        },
        {
          "delay": 6.1429,
          "n": 210
        },
        {
          "delay": 0.7434,
          "n": 113
        },
        {
          "delay": -3.9292,
          "n": 325
        },
        {
          "delay": 7.7892,
          "n": 332
        },
        {
          "delay": 0.9378,
          "n": 193
        },
        {
          "delay": 2.26,
          "n": 100
        },
        {
          "delay": 17.5,
          "n": 2
        },
        {
          "delay": 0.1045,
          "n": 201
        },
        {
          "delay": 4.973,
          "n": 74
        },
        {
          "delay": 14.7388,
          "n": 134
        },
        {
          "delay": 7.0798,
          "n": 163
        },
        {
          "delay": 8.0833,
          "n": 108
        },
        {
          "delay": 3.3837,
          "n": 86
        },
        {
          "delay": 0.8201,
          "n": 139
        },
        {
          "delay": -0.177,
          "n": 113
        },
        {
          "delay": 1.9406,
          "n": 101
        },
        {
          "delay": 8.81,
          "n": 100
        },
        {
          "delay": 36.6316,
          "n": 19
        },
        {
          "delay": -1.4974,
          "n": 189
        },
        {
          "delay": 15.991,
          "n": 111
        },
        {
          "delay": 7.1667,
          "n": 12
        },
        {
          "delay": -0.8319,
          "n": 119
        },
        {
          "delay": -5.1852,
          "n": 108
        },
        {
          "delay": -0.0094,
          "n": 106
        },
        {
          "delay": 3.4222,
          "n": 90
        },
        {
          "delay": 41.1667,
          "n": 12
        },
        {
          "delay": 25.3226,
          "n": 31
        },
        {
          "delay": -0.8427,
          "n": 178
        },
        {
          "delay": 1.6702,
          "n": 94
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 24.1905,
          "n": 21
        },
        {
          "delay": 3.2865,
          "n": 178
        },
        {
          "delay": -1.5333,
          "n": 60
        },
        {
          "delay": 17,
          "n": 3
        },
        {
          "delay": -11.5,
          "n": 16
        },
        {
          "delay": 14.7878,
          "n": 311
        },
        {
          "delay": 0.2041,
          "n": 196
        },
        {
          "delay": 19,
          "n": 3
        },
        {
          "delay": -1.3462,
          "n": 26
        },
        {
          "delay": -4.3735,
          "n": 166
        },
        {
          "delay": 3.2778,
          "n": 72
        },
        {
          "delay": 3.6538,
          "n": 26
        },
        {
          "delay": 5.4464,
          "n": 345
        },
        {
          "delay": 0.7662,
          "n": 154
        },
        {
          "delay": 3.0337,
          "n": 89
        },
        {
          "delay": 14,
          "n": 18
        },
        {
          "delay": 1.8072,
          "n": 166
        },
        {
          "delay": 0.5543,
          "n": 92
        },
        {
          "delay": -10.6667,
          "n": 3
        },
        {
          "delay": -0.8462,
          "n": 13
        },
        {
          "delay": 1.0899,
          "n": 89
        },
        {
          "delay": -19,
          "n": 1
        },
        {
          "delay": 8.2609,
          "n": 23
        },
        {
          "delay": 5.0921,
          "n": 391
        },
        {
          "delay": 9.7949,
          "n": 78
        },
        {
          "delay": 3.0973,
          "n": 113
        },
        {
          "delay": -2.1176,
          "n": 119
        },
        {
          "delay": 2.9704,
          "n": 135
        },
        {
          "delay": 6.032,
          "n": 125
        },
        {
          "delay": 17.4286,
          "n": 21
        },
        {
          "delay": 15.5366,
          "n": 41
        },
        {
          "delay": 2.6024,
          "n": 83
        },
        {
          "delay": -1.75,
          "n": 4
        },
        {
          "delay": -2.75,
          "n": 16
        },
        {
          "delay": 41.1905,
          "n": 21
        },
        {
          "delay": 7.9702,
          "n": 403
        },
        {
          "delay": 1.1341,
          "n": 179
        },
        {
          "delay": 4.4286,
          "n": 105
        },
        {
          "delay": 39,
          "n": 5
        },
        {
          "delay": 0.23,
          "n": 100
        },
        {
          "delay": 4.84,
          "n": 25
        },
        {
          "delay": 68.1,
          "n": 10
        },
        {
          "delay": 8.1054,
          "n": 332
        },
        {
          "delay": 7.6154,
          "n": 26
        },
        {
          "delay": 5.1414,
          "n": 99
        },
        {
          "delay": 2.75,
          "n": 4
        },
        {
          "delay": 6.2,
          "n": 10
        },
        {
          "delay": 13.8746,
          "n": 279
        },
        {
          "delay": 0.871,
          "n": 124
        },
        {
          "delay": 3.7129,
          "n": 101
        },
        {
          "delay": 5,
          "n": 2
        },
        {
          "delay": 12.0952,
          "n": 21
        },
        {
          "delay": -1.5321,
          "n": 109
        },
        {
          "delay": 10.8,
          "n": 5
        },
        {
          "delay": 20.75,
          "n": 28
        },
        {
          "delay": -1.2759,
          "n": 145
        },
        {
          "delay": -2.0877,
          "n": 114
        },
        {
          "delay": -10.5,
          "n": 8
        },
        {
          "delay": 27,
          "n": 11
        },
        {
          "delay": 0.0672,
          "n": 268
        },
        {
          "delay": 2.1129,
          "n": 186
        },
        {
          "delay": 7.6296,
          "n": 108
        },
        {
          "delay": 32,
          "n": 2
        },
        {
          "delay": 11.3333,
          "n": 18
        },
        {
          "delay": -5.3279,
          "n": 183
        },
        {
          "delay": 5.275,
          "n": 80
        },
        {
          "delay": -7.75,
          "n": 4
        },
        {
          "delay": 1.9524,
          "n": 21
        },
        {
          "delay": 4.26,
          "n": 150
        },
        {
          "delay": 9.6396,
          "n": 111
        },
        {
          "delay": 0.25,
          "n": 4
        },
        {
          "delay": -1.5455,
          "n": 22
        },
        {
          "delay": 3.3896,
          "n": 154
        },
        {
          "delay": 8.4369,
          "n": 103
        },
        {
          "delay": -9,
          "n": 2
        },
        {
          "delay": 2.4348,
          "n": 46
        },
        {
          "delay": 0.3565,
          "n": 115
        },
        {
          "delay": 3.1389,
          "n": 108
        },
        {
          "delay": 1.7025,
          "n": 121
        },
        {
          "delay": 4.2124,
          "n": 113
        },
        {
          "delay": 5.1875,
          "n": 16
        },
        {
          "delay": -2.6164,
          "n": 73
        },
        {
          "delay": 4.4095,
          "n": 105
        },
        {
          "delay": 5.5714,
          "n": 7
        },
        {
          "delay": -9.6,
          "n": 15
        },
        {
          "delay": -6.5233,
          "n": 86
        },
        {
          "delay": 1.25,
          "n": 112
        },
        {
          "delay": 3.25,
          "n": 4
        },
        {
          "delay": -0.1942,
          "n": 103
        },
        {
          "delay": 1.4336,
          "n": 113
        },
        {
          "delay": -0.5784,
          "n": 102
        },
        {
          "delay": 2.9438,
          "n": 89
        },
        {
          "delay": 16.2037,
          "n": 54
        },
        {
          "delay": -2.2273,
          "n": 22
        },
        {
          "delay": -3.3163,
          "n": 196
        },
        {
          "delay": 1.5304,
          "n": 115
        },
        {
          "delay": 2.5,
          "n": 6
        },
        {
          "delay": 30.6452,
          "n": 31
        },
        {
          "delay": 1.1346,
          "n": 156
        },
        {
          "delay": 3.0729,
          "n": 96
        },
        {
          "delay": -10.4,
          "n": 5
        },
        {
          "delay": 43.75,
          "n": 12
        },
        {
          "delay": -3.5455,
          "n": 154
        },
        {
          "delay": 7.1961,
          "n": 102
        },
        {
          "delay": 2.8333,
          "n": 6
        },
        {
          "delay": -1.8333,
          "n": 12
        },
        {
          "delay": 1.6917,
          "n": 120
        },
        {
          "delay": -1,
          "n": 2
        },
        {
          "delay": -6.5455,
          "n": 11
        },
        {
          "delay": 3.1747,
          "n": 229
        },
        {
          "delay": 0.9824,
          "n": 170
        },
        {
          "delay": 10.4524,
          "n": 84
        },
        {
          "delay": 18.2,
          "n": 5
        },
        {
          "delay": 24.1389,
          "n": 216
        },
        {
          "delay": 11.5714,
          "n": 14
        },
        {
          "delay": 4.3443,
          "n": 183
        },
        {
          "delay": 4.4066,
          "n": 91
        },
        {
          "delay": 7.4,
          "n": 5
        },
        {
          "delay": 6.1053,
          "n": 19
        },
        {
          "delay": -2.22,
          "n": 150
        },
        {
          "delay": 6.9587,
          "n": 121
        },
        {
          "delay": 48.3333,
          "n": 6
        },
        {
          "delay": -3.7083,
          "n": 24
        },
        {
          "delay": 8.6862,
          "n": 188
        },
        {
          "delay": -3.4583,
          "n": 120
        },
        {
          "delay": -2.6309,
          "n": 149
        },
        {
          "delay": 4.3077,
          "n": 78
        },
        {
          "delay": -3.6,
          "n": 5
        },
        {
          "delay": 2.748,
          "n": 123
        },
        {
          "delay": -1.0825,
          "n": 97
        },
        {
          "delay": 10.1121,
          "n": 107
        },
        {
          "delay": 4.9692,
          "n": 130
        },
        {
          "delay": 3.2562,
          "n": 121
        },
        {
          "delay": -2.1308,
          "n": 107
        },
        {
          "delay": 3.6777,
          "n": 121
        },
        {
          "delay": 9.4821,
          "n": 56
        },
        {
          "delay": 1.598,
          "n": 102
        },
        {
          "delay": 4.8387,
          "n": 124
        },
        {
          "delay": 3.8333,
          "n": 102
        },
        {
          "delay": 4.1667,
          "n": 102
        },
        {
          "delay": -0.1644,
          "n": 146
        },
        {
          "delay": -9.375,
          "n": 8
        },
        {
          "delay": 12.869,
          "n": 84
        },
        {
          "delay": 10.0442,
          "n": 113
        },
        {
          "delay": 3.3333,
          "n": 3
        },
        {
          "delay": 3.2397,
          "n": 121
        },
        {
          "delay": -0.5351,
          "n": 114
        },
        {
          "delay": -0.1574,
          "n": 108
        },
        {
          "delay": 0.4706,
          "n": 102
        },
        {
          "delay": 0.375,
          "n": 112
        },
        {
          "delay": 1.9485,
          "n": 136
        },
        {
          "delay": 5.0168,
          "n": 119
        },
        {
          "delay": -0.2832,
          "n": 113
        },
        {
          "delay": -3.2125,
          "n": 80
        },
        {
          "delay": -2.8252,
          "n": 103
        },
        {
          "delay": 15.1333,
          "n": 15
        },
        {
          "delay": -4.3208,
          "n": 106
        },
        {
          "delay": 5.3435,
          "n": 230
        },
        {
          "delay": -1.3945,
          "n": 109
        },
        {
          "delay": 21.625,
          "n": 8
        },
        {
          "delay": -0.3708,
          "n": 89
        },
        {
          "delay": -0.4419,
          "n": 86
        },
        {
          "delay": 2.0574,
          "n": 122
        },
        {
          "delay": 6.0196,
          "n": 102
        },
        {
          "delay": -1.1158,
          "n": 95
        },
        {
          "delay": -2.2385,
          "n": 109
        },
        {
          "delay": 0.5185,
          "n": 108
        },
        {
          "delay": 4.0625,
          "n": 96
        },
        {
          "delay": -6.4719,
          "n": 89
        },
        {
          "delay": -5.5204,
          "n": 98
        },
        {
          "delay": -5.8099,
          "n": 121
        },
        {
          "delay": -5.0792,
          "n": 101
        },
        {
          "delay": -1.3901,
          "n": 141
        },
        {
          "delay": -2.6259,
          "n": 139
        },
        {
          "delay": -7.8409,
          "n": 88
        },
        {
          "delay": -2.5802,
          "n": 162
        },
        {
          "delay": 2.8969,
          "n": 97
        },
        {
          "delay": -5.3523,
          "n": 88
        },
        {
          "delay": 3.5688,
          "n": 109
        },
        {
          "delay": -0.5051,
          "n": 99
        },
        {
          "delay": -0.6832,
          "n": 101
        },
        {
          "delay": 4.0565,
          "n": 124
        },
        {
          "delay": 3.9873,
          "n": 79
        },
        {
          "delay": 6.12,
          "n": 100
        },
        {
          "delay": 2.3562,
          "n": 73
        },
        {
          "delay": -3.3239,
          "n": 142
        },
        {
          "delay": -3.8033,
          "n": 122
        },
        {
          "delay": -1.609,
          "n": 156
        },
        {
          "delay": 27.0667,
          "n": 15
        },
        {
          "delay": -0.3762,
          "n": 101
        },
        {
          "delay": 6.5,
          "n": 236
        },
        {
          "delay": 3.7913,
          "n": 115
        },
        {
          "delay": -0.6667,
          "n": 6
        },
        {
          "delay": -6.2183,
          "n": 142
        },
        {
          "delay": -6.4662,
          "n": 133
        },
        {
          "delay": -6.0764,
          "n": 144
        },
        {
          "delay": -10.155,
          "n": 129
        },
        {
          "delay": -6.8608,
          "n": 158
        },
        {
          "delay": -3.4393,
          "n": 107
        },
        {
          "delay": -5.5859,
          "n": 128
        },
        {
          "delay": -3.8201,
          "n": 139
        },
        {
          "delay": -3.9448,
          "n": 163
        },
        {
          "delay": -4.2846,
          "n": 123
        },
        {
          "delay": -0.2308,
          "n": 13
        },
        {
          "delay": -5.0105,
          "n": 95
        },
        {
          "delay": -0.0345,
          "n": 58
        },
        {
          "delay": 12.4941,
          "n": 85
        },
        {
          "delay": -1.1111,
          "n": 9
        },
        {
          "delay": 0.9127,
          "n": 126
        },
        {
          "delay": 0.0154,
          "n": 130
        },
        {
          "delay": 4.4846,
          "n": 130
        },
        {
          "delay": -3.3109,
          "n": 119
        },
        {
          "delay": -0.4759,
          "n": 166
        },
        {
          "delay": -1.3333,
          "n": 132
        },
        {
          "delay": -4.6903,
          "n": 113
        },
        {
          "delay": -0.7793,
          "n": 145
        },
        {
          "delay": -6.6587,
          "n": 126
        },
        {
          "delay": -6.0062,
          "n": 160
        },
        {
          "delay": 6.8333,
          "n": 18
        },
        {
          "delay": 7.3867,
          "n": 75
        },
        {
          "delay": 3.1556,
          "n": 135
        },
        {
          "delay": 6,
          "n": 5
        },
        {
          "delay": -7.2201,
          "n": 159
        },
        {
          "delay": 5.2632,
          "n": 114
        },
        {
          "delay": -9.729,
          "n": 155
        },
        {
          "delay": -3.5103,
          "n": 145
        },
        {
          "delay": 2.56,
          "n": 25
        },
        {
          "delay": -6.8889,
          "n": 99
        },
        {
          "delay": 4.7636,
          "n": 110
        },
        {
          "delay": 12,
          "n": 12
        },
        {
          "delay": 5.8788,
          "n": 99
        },
        {
          "delay": 1.5909,
          "n": 132
        },
        {
          "delay": 17.5714,
          "n": 7
        },
        {
          "delay": 2.6154,
          "n": 13
        },
        {
          "delay": 0.9195,
          "n": 87
        },
        {
          "delay": 0.7143,
          "n": 7
        },
        {
          "delay": 14.4737,
          "n": 19
        },
        {
          "delay": -4.5556,
          "n": 108
        },
        {
          "delay": -4.375,
          "n": 40
        },
        {
          "delay": -13.3333,
          "n": 3
        },
        {
          "delay": 3.5,
          "n": 22
        },
        {
          "delay": 4.9208,
          "n": 101
        },
        {
          "delay": -11.48,
          "n": 25
        },
        {
          "delay": -2.7838,
          "n": 111
        },
        {
          "delay": -3.1897,
          "n": 116
        },
        {
          "delay": 29,
          "n": 17
        },
        {
          "delay": 4.3217,
          "n": 115
        },
        {
          "delay": -23.5,
          "n": 26
        },
        {
          "delay": 2.7778,
          "n": 9
        },
        {
          "delay": 5.6667,
          "n": 24
        },
        {
          "delay": 0.0168,
          "n": 119
        },
        {
          "delay": -14.4615,
          "n": 26
        },
        {
          "delay": 13,
          "n": 4
        },
        {
          "delay": -0.507,
          "n": 71
        },
        {
          "delay": -3.5,
          "n": 70
        },
        {
          "delay": -2.4175,
          "n": 103
        },
        {
          "delay": 0.4486,
          "n": 107
        },
        {
          "delay": -2.7212,
          "n": 104
        },
        {
          "delay": 2.1979,
          "n": 96
        },
        {
          "delay": -0.3077,
          "n": 104
        },
        {
          "delay": 2.2308,
          "n": 91
        },
        {
          "delay": -4.1284,
          "n": 109
        },
        {
          "delay": 5.236,
          "n": 89
        },
        {
          "delay": 3.9014,
          "n": 71
        },
        {
          "delay": 35.6,
          "n": 10
        },
        {
          "delay": 5.2581,
          "n": 93
        },
        {
          "delay": 23.4545,
          "n": 33
        },
        {
          "delay": -3.5,
          "n": 4
        },
        {
          "delay": -2.1579,
          "n": 19
        },
        {
          "delay": -1.9515,
          "n": 103
        },
        {
          "delay": -6.9643,
          "n": 28
        },
        {
          "delay": 3.8261,
          "n": 23
        },
        {
          "delay": -3.57,
          "n": 100
        },
        {
          "delay": -10.76,
          "n": 25
        },
        {
          "delay": -11,
          "n": 7
        },
        {
          "delay": -2.564,
          "n": 172
        },
        {
          "delay": 30.4375,
          "n": 16
        },
        {
          "delay": 5.7711,
          "n": 83
        },
        {
          "delay": 62.5,
          "n": 4
        },
        {
          "delay": 17.5556,
          "n": 18
        },
        {
          "delay": 4.6731,
          "n": 104
        },
        {
          "delay": -13,
          "n": 36
        },
        {
          "delay": 53.5,
          "n": 6
        },
        {
          "delay": 31.1111,
          "n": 9
        },
        {
          "delay": -3.4211,
          "n": 133
        },
        {
          "delay": -9.625,
          "n": 32
        },
        {
          "delay": 14,
          "n": 7
        },
        {
          "delay": 1.9286,
          "n": 14
        },
        {
          "delay": 3.5149,
          "n": 101
        },
        {
          "delay": -10,
          "n": 20
        },
        {
          "delay": 6.8182,
          "n": 11
        },
        {
          "delay": 1.6667,
          "n": 12
        },
        {
          "delay": 6.5725,
          "n": 138
        },
        {
          "delay": -3.0099,
          "n": 101
        },
        {
          "delay": -5.7143,
          "n": 21
        },
        {
          "delay": -7.75,
          "n": 4
        },
        {
          "delay": 1.3269,
          "n": 104
        },
        {
          "delay": -2.7857,
          "n": 14
        },
        {
          "delay": 5.5185,
          "n": 108
        },
        {
          "delay": -4.4615,
          "n": 13
        },
        {
          "delay": 16.4,
          "n": 5
        },
        {
          "delay": 22.4348,
          "n": 23
        },
        {
          "delay": -2.4819,
          "n": 83
        },
        {
          "delay": -0.8,
          "n": 10
        },
        {
          "delay": -0.93,
          "n": 100
        },
        {
          "delay": 1.5138,
          "n": 109
        },
        {
          "delay": -1.6571,
          "n": 105
        },
        {
          "delay": -2.1782,
          "n": 101
        },
        {
          "delay": 1.7582,
          "n": 91
        },
        {
          "delay": 0.9813,
          "n": 107
        },
        {
          "delay": 2.1589,
          "n": 107
        },
        {
          "delay": 5.7941,
          "n": 68
        },
        {
          "delay": 12.2941,
          "n": 17
        },
        {
          "delay": 5.6264,
          "n": 91
        },
        {
          "delay": -4.75,
          "n": 4
        },
        {
          "delay": 4.6667,
          "n": 6
        },
        {
          "delay": -8.5714,
          "n": 7
        },
        {
          "delay": 4.2963,
          "n": 108
        },
        {
          "delay": -9.1429,
          "n": 7
        },
        {
          "delay": -5.75,
          "n": 4
        },
        {
          "delay": 3.1429,
          "n": 21
        },
        {
          "delay": 0.5106,
          "n": 94
        },
        {
          "delay": 15.6,
          "n": 5
        },
        {
          "delay": -1.8743,
          "n": 167
        },
        {
          "delay": 4.2,
          "n": 195
        },
        {
          "delay": 2.05,
          "n": 20
        },
        {
          "delay": 0.8879,
          "n": 116
        },
        {
          "delay": 21,
          "n": 5
        },
        {
          "delay": 0.0526,
          "n": 19
        },
        {
          "delay": 8.8443,
          "n": 167
        },
        {
          "delay": 0.1207,
          "n": 116
        },
        {
          "delay": 1.8333,
          "n": 6
        },
        {
          "delay": -3.7083,
          "n": 24
        },
        {
          "delay": -0.7167,
          "n": 120
        },
        {
          "delay": -1.3333,
          "n": 3
        },
        {
          "delay": 3.7838,
          "n": 74
        },
        {
          "delay": -1.5781,
          "n": 64
        },
        {
          "delay": -1.3908,
          "n": 87
        },
        {
          "delay": 0.9508,
          "n": 61
        },
        {
          "delay": -7.8448,
          "n": 58
        },
        {
          "delay": 15.4,
          "n": 260
        },
        {
          "delay": -0.1111,
          "n": 63
        },
        {
          "delay": 1.549,
          "n": 51
        },
        {
          "delay": -3.7544,
          "n": 57
        },
        {
          "delay": 12.8871,
          "n": 62
        },
        {
          "delay": 8.0548,
          "n": 73
        },
        {
          "delay": 3.5873,
          "n": 63
        },
        {
          "delay": 3.9429,
          "n": 70
        },
        {
          "delay": 5.3514,
          "n": 74
        },
        {
          "delay": 12.9194,
          "n": 62
        },
        {
          "delay": 1.9571,
          "n": 70
        },
        {
          "delay": 4.8333,
          "n": 60
        },
        {
          "delay": 2.1,
          "n": 60
        },
        {
          "delay": 6.5303,
          "n": 66
        },
        {
          "delay": -6.4833,
          "n": 60
        },
        {
          "delay": -6.1803,
          "n": 61
        },
        {
          "delay": 0.9032,
          "n": 62
        },
        {
          "delay": -4.2794,
          "n": 68
        },
        {
          "delay": 4.9863,
          "n": 73
        },
        {
          "delay": -3.8814,
          "n": 59
        },
        {
          "delay": 2.6867,
          "n": 83
        },
        {
          "delay": 4.6824,
          "n": 85
        },
        {
          "delay": 11.8333,
          "n": 48
        },
        {
          "delay": -3.9206,
          "n": 63
        },
        {
          "delay": 1.4242,
          "n": 66
        },
        {
          "delay": -2.908,
          "n": 87
        },
        {
          "delay": -2.1091,
          "n": 55
        },
        {
          "delay": -0.9067,
          "n": 75
        },
        {
          "delay": -4.0308,
          "n": 65
        },
        {
          "delay": -2.1818,
          "n": 22
        },
        {
          "delay": 9.6977,
          "n": 43
        },
        {
          "delay": -1.2857,
          "n": 77
        },
        {
          "delay": 3.119,
          "n": 84
        },
        {
          "delay": -3.6226,
          "n": 53
        },
        {
          "delay": 19.2444,
          "n": 45
        },
        {
          "delay": 4.1286,
          "n": 70
        },
        {
          "delay": -4.7835,
          "n": 97
        },
        {
          "delay": 5.3974,
          "n": 78
        },
        {
          "delay": -1.1912,
          "n": 68
        },
        {
          "delay": -1.716,
          "n": 81
        },
        {
          "delay": 4.6029,
          "n": 68
        },
        {
          "delay": 6.5082,
          "n": 61
        },
        {
          "delay": 2.9,
          "n": 80
        },
        {
          "delay": 0.1212,
          "n": 66
        },
        {
          "delay": -1.9041,
          "n": 73
        },
        {
          "delay": 3.8235,
          "n": 102
        },
        {
          "delay": 9.1558,
          "n": 77
        },
        {
          "delay": 3,
          "n": 77
        },
        {
          "delay": 3.0909,
          "n": 55
        },
        {
          "delay": 1.5692,
          "n": 65
        },
        {
          "delay": -0.2879,
          "n": 66
        },
        {
          "delay": 3.1613,
          "n": 62
        },
        {
          "delay": -4.9091,
          "n": 66
        },
        {
          "delay": 1.9571,
          "n": 70
        },
        {
          "delay": 6.3151,
          "n": 73
        },
        {
          "delay": -0.8806,
          "n": 67
        },
        {
          "delay": 4.9483,
          "n": 58
        },
        {
          "delay": -6.0217,
          "n": 46
        },
        {
          "delay": 24.0833,
          "n": 36
        },
        {
          "delay": -0.3971,
          "n": 68
        },
        {
          "delay": 3.6471,
          "n": 51
        },
        {
          "delay": 0.2464,
          "n": 69
        },
        {
          "delay": 0.4186,
          "n": 43
        },
        {
          "delay": 1.1449,
          "n": 69
        },
        {
          "delay": 4.0196,
          "n": 51
        },
        {
          "delay": 2.9531,
          "n": 64
        },
        {
          "delay": 2.2308,
          "n": 65
        },
        {
          "delay": 2.3556,
          "n": 45
        },
        {
          "delay": 15.4561,
          "n": 57
        },
        {
          "delay": 15.3529,
          "n": 34
        },
        {
          "delay": 4.3636,
          "n": 44
        },
        {
          "delay": 1.0175,
          "n": 57
        },
        {
          "delay": 1.2162,
          "n": 74
        },
        {
          "delay": 0.5745,
          "n": 47
        },
        {
          "delay": 4.4286,
          "n": 63
        },
        {
          "delay": -0.3474,
          "n": 95
        },
        {
          "delay": -0.2159,
          "n": 88
        },
        {
          "delay": -8.9844,
          "n": 64
        },
        {
          "delay": 5.4627,
          "n": 67
        },
        {
          "delay": -0.0145,
          "n": 69
        },
        {
          "delay": -2.7941,
          "n": 68
        },
        {
          "delay": -7.3235,
          "n": 68
        },
        {
          "delay": -4.3607,
          "n": 61
        },
        {
          "delay": 7.1132,
          "n": 53
        },
        {
          "delay": -4.6883,
          "n": 77
        },
        {
          "delay": -4.2632,
          "n": 57
        },
        {
          "delay": -0.7963,
          "n": 54
        },
        {
          "delay": 0.0345,
          "n": 87
        },
        {
          "delay": 3.625,
          "n": 56
        },
        {
          "delay": 0.25,
          "n": 56
        },
        {
          "delay": -5.3521,
          "n": 71
        },
        {
          "delay": -5.5,
          "n": 72
        },
        {
          "delay": 0.2444,
          "n": 45
        },
        {
          "delay": -4.5738,
          "n": 61
        },
        {
          "delay": 7.4242,
          "n": 66
        },
        {
          "delay": -3.9524,
          "n": 63
        },
        {
          "delay": 5.0926,
          "n": 54
        },
        {
          "delay": 8.7656,
          "n": 64
        },
        {
          "delay": -6.8088,
          "n": 68
        },
        {
          "delay": -4.65,
          "n": 60
        },
        {
          "delay": -0.8393,
          "n": 56
        },
        {
          "delay": 4.9302,
          "n": 86
        },
        {
          "delay": 0.6479,
          "n": 71
        },
        {
          "delay": 9,
          "n": 64
        },
        {
          "delay": -2.8738,
          "n": 103
        },
        {
          "delay": -4.8077,
          "n": 78
        },
        {
          "delay": -4.7746,
          "n": 71
        },
        {
          "delay": 6.9423,
          "n": 52
        },
        {
          "delay": 2.9474,
          "n": 76
        },
        {
          "delay": -5.1111,
          "n": 63
        },
        {
          "delay": -4.1538,
          "n": 65
        },
        {
          "delay": 2.4902,
          "n": 51
        },
        {
          "delay": 1.679,
          "n": 81
        },
        {
          "delay": 4.5918,
          "n": 98
        },
        {
          "delay": -1.1282,
          "n": 78
        },
        {
          "delay": -1.0923,
          "n": 65
        },
        {
          "delay": -0.6892,
          "n": 74
        },
        {
          "delay": 11.8305,
          "n": 59
        },
        {
          "delay": -5.1356,
          "n": 59
        },
        {
          "delay": 5.8594,
          "n": 64
        },
        {
          "delay": -0.8442,
          "n": 77
        },
        {
          "delay": -2.1628,
          "n": 86
        },
        {
          "delay": -7.0426,
          "n": 94
        },
        {
          "delay": 0.3673,
          "n": 49
        },
        {
          "delay": -3.5833,
          "n": 84
        },
        {
          "delay": -3.6588,
          "n": 85
        },
        {
          "delay": -0.1529,
          "n": 85
        },
        {
          "delay": -1.7683,
          "n": 82
        },
        {
          "delay": 5.3621,
          "n": 58
        },
        {
          "delay": -4.37,
          "n": 100
        },
        {
          "delay": -5.1081,
          "n": 74
        },
        {
          "delay": 9.3333,
          "n": 78
        },
        {
          "delay": -7.875,
          "n": 96
        },
        {
          "delay": -3.4861,
          "n": 72
        },
        {
          "delay": 11.6528,
          "n": 72
        },
        {
          "delay": 9.0769,
          "n": 65
        },
        {
          "delay": 4.9733,
          "n": 75
        },
        {
          "delay": -1.6087,
          "n": 92
        },
        {
          "delay": 5.4627,
          "n": 67
        },
        {
          "delay": -0.8475,
          "n": 59
        },
        {
          "delay": -0.9524,
          "n": 63
        },
        {
          "delay": 2.6709,
          "n": 79
        },
        {
          "delay": 4.7683,
          "n": 82
        },
        {
          "delay": 4.9833,
          "n": 60
        },
        {
          "delay": -8.6364,
          "n": 77
        },
        {
          "delay": -6.8493,
          "n": 73
        },
        {
          "delay": 4.1642,
          "n": 67
        },
        {
          "delay": -0.1948,
          "n": 77
        },
        {
          "delay": 0.2667,
          "n": 60
        },
        {
          "delay": 4.0147,
          "n": 68
        },
        {
          "delay": -7.4177,
          "n": 79
        },
        {
          "delay": -1.3625,
          "n": 80
        },
        {
          "delay": -5.5672,
          "n": 67
        },
        {
          "delay": 14.0513,
          "n": 78
        },
        {
          "delay": 0.4426,
          "n": 61
        },
        {
          "delay": 4.3875,
          "n": 80
        },
        {
          "delay": 5.86,
          "n": 50
        },
        {
          "delay": -2.8701,
          "n": 77
        },
        {
          "delay": -9.6111,
          "n": 54
        },
        {
          "delay": -1.1356,
          "n": 59
        },
        {
          "delay": -3.9737,
          "n": 76
        },
        {
          "delay": 0.3662,
          "n": 71
        },
        {
          "delay": -8.2174,
          "n": 46
        },
        {
          "delay": 0.9625,
          "n": 80
        },
        {
          "delay": 6.0597,
          "n": 67
        },
        {
          "delay": 2.3509,
          "n": 57
        },
        {
          "delay": 0.1224,
          "n": 49
        },
        {
          "delay": -3.4727,
          "n": 55
        },
        {
          "delay": -8.9024,
          "n": 82
        },
        {
          "delay": 2.3571,
          "n": 70
        },
        {
          "delay": -8.4265,
          "n": 68
        },
        {
          "delay": 2.7,
          "n": 60
        },
        {
          "delay": -5.0909,
          "n": 55
        },
        {
          "delay": -4.5652,
          "n": 69
        },
        {
          "delay": -1.8333,
          "n": 78
        },
        {
          "delay": 6.9574,
          "n": 47
        },
        {
          "delay": -0.7463,
          "n": 67
        },
        {
          "delay": -2.0714,
          "n": 56
        },
        {
          "delay": -1,
          "n": 72
        },
        {
          "delay": 0.6395,
          "n": 86
        },
        {
          "delay": -4.902,
          "n": 51
        },
        {
          "delay": 1.1558,
          "n": 77
        },
        {
          "delay": 8.4211,
          "n": 57
        },
        {
          "delay": 3.7937,
          "n": 63
        },
        {
          "delay": -3.7,
          "n": 100
        },
        {
          "delay": -1.5143,
          "n": 70
        },
        {
          "delay": -1.2778,
          "n": 72
        },
        {
          "delay": 1.2564,
          "n": 78
        },
        {
          "delay": 2.0441,
          "n": 68
        },
        {
          "delay": -4.2817,
          "n": 71
        },
        {
          "delay": -0.2778,
          "n": 72
        },
        {
          "delay": 1.2759,
          "n": 58
        },
        {
          "delay": -8.4107,
          "n": 56
        },
        {
          "delay": -5.8548,
          "n": 62
        },
        {
          "delay": 0.3448,
          "n": 58
        },
        {
          "delay": 3.3433,
          "n": 67
        },
        {
          "delay": -5.5397,
          "n": 63
        },
        {
          "delay": 1.4242,
          "n": 66
        },
        {
          "delay": 2.5893,
          "n": 56
        },
        {
          "delay": -7.5686,
          "n": 51
        },
        {
          "delay": -1.4561,
          "n": 57
        },
        {
          "delay": -2.2857,
          "n": 70
        },
        {
          "delay": -4.3509,
          "n": 57
        },
        {
          "delay": 5.2273,
          "n": 44
        },
        {
          "delay": 2.7414,
          "n": 58
        },
        {
          "delay": -4.2821,
          "n": 39
        },
        {
          "delay": 0.5417,
          "n": 48
        },
        {
          "delay": -0.725,
          "n": 40
        },
        {
          "delay": 2.2941,
          "n": 34
        },
        {
          "delay": -10.7949,
          "n": 39
        },
        {
          "delay": -5.2667,
          "n": 15
        },
        {
          "delay": 3.7667,
          "n": 30
        },
        {
          "delay": -8.24,
          "n": 25
        },
        {
          "delay": -0.6,
          "n": 25
        },
        {
          "delay": -2.0968,
          "n": 31
        },
        {
          "delay": -7.5385,
          "n": 13
        },
        {
          "delay": 9.375,
          "n": 24
        },
        {
          "delay": -5,
          "n": 1
        },
        {
          "delay": -7.75,
          "n": 4
        },
        {
          "delay": 3,
          "n": 1
        },
        {
          "delay": -24.5,
          "n": 2
        },
        {
          "delay": 25.5714,
          "n": 21
        },
        {
          "delay": 6.7857,
          "n": 70
        },
        {
          "delay": 15.6538,
          "n": 26
        },
        {
          "delay": -9.5,
          "n": 46
        },
        {
          "delay": 6.4959,
          "n": 121
        },
        {
          "delay": 14.1081,
          "n": 37
        },
        {
          "delay": 2.3611,
          "n": 36
        },
        {
          "delay": -11.0784,
          "n": 51
        },
        {
          "delay": 11.4273,
          "n": 110
        },
        {
          "delay": 35.375,
          "n": 16
        },
        {
          "delay": 3.0353,
          "n": 85
        },
        {
          "delay": 1.1471,
          "n": 34
        },
        {
          "delay": 2.0727,
          "n": 110
        },
        {
          "delay": 6.12,
          "n": 25
        },
        {
          "delay": 11.202,
          "n": 99
        },
        {
          "delay": -0.3333,
          "n": 9
        },
        {
          "delay": 2.8095,
          "n": 21
        },
        {
          "delay": -4.125,
          "n": 40
        },
        {
          "delay": 6.8481,
          "n": 79
        },
        {
          "delay": 7.5,
          "n": 26
        },
        {
          "delay": -4.8,
          "n": 35
        },
        {
          "delay": 5.7188,
          "n": 96
        },
        {
          "delay": 23.75,
          "n": 28
        },
        {
          "delay": -8.1795,
          "n": 39
        },
        {
          "delay": 3.4157,
          "n": 89
        },
        {
          "delay": -6.4286,
          "n": 7
        },
        {
          "delay": 5.4643,
          "n": 28
        },
        {
          "delay": -0.898,
          "n": 98
        },
        {
          "delay": -0.5455,
          "n": 22
        },
        {
          "delay": 14.6903,
          "n": 113
        },
        {
          "delay": 5.9434,
          "n": 106
        },
        {
          "delay": 0.0215,
          "n": 93
        },
        {
          "delay": 6.2521,
          "n": 119
        },
        {
          "delay": 9.4167,
          "n": 24
        },
        {
          "delay": 7.781,
          "n": 105
        },
        {
          "delay": 15.4545,
          "n": 22
        },
        {
          "delay": -2.0714,
          "n": 28
        },
        {
          "delay": 2.3495,
          "n": 103
        },
        {
          "delay": -0.6538,
          "n": 26
        },
        {
          "delay": 1.0116,
          "n": 86
        },
        {
          "delay": 15.5,
          "n": 26
        },
        {
          "delay": 2.9293,
          "n": 99
        },
        {
          "delay": 11.44,
          "n": 25
        },
        {
          "delay": 5.2083,
          "n": 96
        },
        {
          "delay": -0.7143,
          "n": 21
        },
        {
          "delay": 0.0633,
          "n": 79
        },
        {
          "delay": 29.7241,
          "n": 29
        },
        {
          "delay": 2.7527,
          "n": 93
        },
        {
          "delay": 1.0952,
          "n": 21
        },
        {
          "delay": -11.3125,
          "n": 32
        },
        {
          "delay": 6.1158,
          "n": 95
        },
        {
          "delay": -5.8571,
          "n": 7
        },
        {
          "delay": 9.4286,
          "n": 21
        },
        {
          "delay": -2.1395,
          "n": 86
        },
        {
          "delay": -19.4,
          "n": 5
        },
        {
          "delay": 12.7083,
          "n": 24
        },
        {
          "delay": -0.069,
          "n": 29
        },
        {
          "delay": 4.9541,
          "n": 109
        },
        {
          "delay": 7.381,
          "n": 105
        },
        {
          "delay": 10.0769,
          "n": 26
        },
        {
          "delay": -22.3103,
          "n": 29
        },
        {
          "delay": 11.3441,
          "n": 93
        },
        {
          "delay": 9.6429,
          "n": 28
        },
        {
          "delay": 6.7209,
          "n": 43
        },
        {
          "delay": -4.9681,
          "n": 94
        },
        {
          "delay": 6.4583,
          "n": 24
        },
        {
          "delay": -1.6585,
          "n": 41
        },
        {
          "delay": -1.5652,
          "n": 23
        },
        {
          "delay": 14.2529,
          "n": 87
        },
        {
          "delay": -1.94,
          "n": 50
        },
        {
          "delay": 2.3368,
          "n": 95
        },
        {
          "delay": -5.1667,
          "n": 6
        },
        {
          "delay": 26.0303,
          "n": 33
        },
        {
          "delay": 157,
          "n": 1
        },
        {
          "delay": -1.2959,
          "n": 98
        },
        {
          "delay": -8.6667,
          "n": 3
        },
        {
          "delay": -3.5,
          "n": 24
        },
        {
          "delay": 2.0787,
          "n": 89
        },
        {
          "delay": 2.2432,
          "n": 37
        },
        {
          "delay": 3.5,
          "n": 106
        },
        {
          "delay": -1.5556,
          "n": 27
        },
        {
          "delay": 2.3404,
          "n": 94
        },
        {
          "delay": -6.3333,
          "n": 3
        },
        {
          "delay": 3.2,
          "n": 25
        },
        {
          "delay": -21.125,
          "n": 8
        },
        {
          "delay": 16.2981,
          "n": 104
        },
        {
          "delay": 15.6667,
          "n": 33
        },
        {
          "delay": 9.6,
          "n": 75
        },
        {
          "delay": 15.25,
          "n": 4
        },
        {
          "delay": 0.725,
          "n": 40
        },
        {
          "delay": -17.0909,
          "n": 22
        },
        {
          "delay": -16.7143,
          "n": 7
        },
        {
          "delay": 10.0333,
          "n": 30
        },
        {
          "delay": 24.5696,
          "n": 79
        },
        {
          "delay": 4.25,
          "n": 8
        },
        {
          "delay": -5.2927,
          "n": 41
        },
        {
          "delay": -0.3774,
          "n": 106
        },
        {
          "delay": -6.4444,
          "n": 9
        },
        {
          "delay": 11.5938,
          "n": 32
        },
        {
          "delay": 9.4138,
          "n": 29
        },
        {
          "delay": -13.5,
          "n": 4
        },
        {
          "delay": 1.06,
          "n": 100
        },
        {
          "delay": 0,
          "n": 6
        },
        {
          "delay": 10,
          "n": 25
        },
        {
          "delay": -5.2045,
          "n": 44
        },
        {
          "delay": 7.9896,
          "n": 96
        },
        {
          "delay": 1.9286,
          "n": 28
        },
        {
          "delay": 5.5333,
          "n": 45
        },
        {
          "delay": 3.3053,
          "n": 95
        },
        {
          "delay": 11.3438,
          "n": 32
        },
        {
          "delay": 3.3636,
          "n": 44
        },
        {
          "delay": 9.6786,
          "n": 84
        },
        {
          "delay": -4.3636,
          "n": 11
        },
        {
          "delay": 12.4091,
          "n": 22
        },
        {
          "delay": -1.6078,
          "n": 51
        },
        {
          "delay": 2.8571,
          "n": 112
        },
        {
          "delay": -1,
          "n": 5
        },
        {
          "delay": -8.375,
          "n": 24
        },
        {
          "delay": 15.875,
          "n": 8
        },
        {
          "delay": 15.6087,
          "n": 23
        },
        {
          "delay": 1.0189,
          "n": 106
        },
        {
          "delay": -5.8,
          "n": 5
        },
        {
          "delay": 6.4479,
          "n": 96
        },
        {
          "delay": 11,
          "n": 2
        },
        {
          "delay": 29.96,
          "n": 25
        },
        {
          "delay": 1.2,
          "n": 5
        },
        {
          "delay": 2.9149,
          "n": 94
        },
        {
          "delay": -10.6,
          "n": 5
        },
        {
          "delay": -0.7308,
          "n": 26
        },
        {
          "delay": 11.2812,
          "n": 96
        },
        {
          "delay": -5.8571,
          "n": 7
        },
        {
          "delay": -0.0435,
          "n": 23
        },
        {
          "delay": 4.7204,
          "n": 93
        },
        {
          "delay": -2.4286,
          "n": 7
        },
        {
          "delay": 21.1875,
          "n": 32
        },
        {
          "delay": 2.0947,
          "n": 95
        },
        {
          "delay": -13.8333,
          "n": 6
        },
        {
          "delay": 9.069,
          "n": 29
        },
        {
          "delay": 12.2083,
          "n": 96
        },
        {
          "delay": 9.75,
          "n": 16
        },
        {
          "delay": 5.3238,
          "n": 105
        },
        {
          "delay": 22.7241,
          "n": 29
        },
        {
          "delay": 1.5889,
          "n": 90
        },
        {
          "delay": -3.5714,
          "n": 21
        },
        {
          "delay": 4.084,
          "n": 131
        },
        {
          "delay": 1.6,
          "n": 5
        },
        {
          "delay": -1.3667,
          "n": 30
        },
        {
          "delay": -14,
          "n": 6
        },
        {
          "delay": 11.8889,
          "n": 36
        },
        {
          "delay": 1.9022,
          "n": 92
        },
        {
          "delay": 39,
          "n": 1
        },
        {
          "delay": -1.7353,
          "n": 34
        },
        {
          "delay": -0.551,
          "n": 98
        },
        {
          "delay": 31.4286,
          "n": 7
        },
        {
          "delay": 11.8889,
          "n": 27
        },
        {
          "delay": 4.944,
          "n": 125
        },
        {
          "delay": -13.1429,
          "n": 7
        },
        {
          "delay": 0.6579,
          "n": 38
        },
        {
          "delay": -6.2991,
          "n": 107
        },
        {
          "delay": -8.5231,
          "n": 65
        },
        {
          "delay": -2.2604,
          "n": 96
        },
        {
          "delay": 13.1429,
          "n": 28
        },
        {
          "delay": -3.35,
          "n": 40
        },
        {
          "delay": 0.7624,
          "n": 101
        },
        {
          "delay": -8.2,
          "n": 10
        },
        {
          "delay": 4.2917,
          "n": 24
        },
        {
          "delay": -9,
          "n": 39
        },
        {
          "delay": 6.2447,
          "n": 94
        },
        {
          "delay": -1,
          "n": 1
        },
        {
          "delay": 7.2162,
          "n": 37
        },
        {
          "delay": 8.6961,
          "n": 102
        },
        {
          "delay": 18.1111,
          "n": 9
        },
        {
          "delay": 10.9565,
          "n": 23
        },
        {
          "delay": 7.5408,
          "n": 98
        },
        {
          "delay": 9.8824,
          "n": 34
        },
        {
          "delay": -0.5,
          "n": 2
        },
        {
          "delay": -4.3208,
          "n": 106
        },
        {
          "delay": -4.5,
          "n": 6
        },
        {
          "delay": 16.5357,
          "n": 28
        },
        {
          "delay": 1.2198,
          "n": 91
        },
        {
          "delay": -3,
          "n": 6
        },
        {
          "delay": 15.3056,
          "n": 36
        },
        {
          "delay": -0.1376,
          "n": 109
        },
        {
          "delay": -0.9444,
          "n": 18
        },
        {
          "delay": -4.9386,
          "n": 114
        },
        {
          "delay": 24.963,
          "n": 27
        },
        {
          "delay": -2.0882,
          "n": 102
        },
        {
          "delay": 15.8,
          "n": 25
        },
        {
          "delay": -3.2333,
          "n": 90
        },
        {
          "delay": 27.7333,
          "n": 30
        },
        {
          "delay": 1.9127,
          "n": 126
        },
        {
          "delay": -1.625,
          "n": 24
        },
        {
          "delay": -7.28,
          "n": 50
        },
        {
          "delay": 9,
          "n": 96
        },
        {
          "delay": 6.7297,
          "n": 37
        },
        {
          "delay": -0.2292,
          "n": 48
        },
        {
          "delay": 9.982,
          "n": 111
        },
        {
          "delay": 27.1034,
          "n": 29
        },
        {
          "delay": -9.2414,
          "n": 58
        },
        {
          "delay": 2.8333,
          "n": 72
        },
        {
          "delay": 4.7778,
          "n": 27
        },
        {
          "delay": 0.4444,
          "n": 36
        },
        {
          "delay": 4.5567,
          "n": 97
        },
        {
          "delay": 5.6452,
          "n": 31
        },
        {
          "delay": 0.3095,
          "n": 42
        },
        {
          "delay": 9.8387,
          "n": 93
        },
        {
          "delay": -5.6087,
          "n": 23
        },
        {
          "delay": -4.1373,
          "n": 51
        },
        {
          "delay": 3.0619,
          "n": 97
        },
        {
          "delay": 7.9032,
          "n": 31
        },
        {
          "delay": 4.3895,
          "n": 95
        },
        {
          "delay": 23.7586,
          "n": 29
        },
        {
          "delay": -2.6531,
          "n": 49
        },
        {
          "delay": 0.4062,
          "n": 96
        },
        {
          "delay": 33,
          "n": 29
        },
        {
          "delay": 0.2609,
          "n": 92
        },
        {
          "delay": 2.4902,
          "n": 51
        },
        {
          "delay": 18.233,
          "n": 103
        },
        {
          "delay": 18.9375,
          "n": 32
        },
        {
          "delay": 0.4,
          "n": 50
        },
        {
          "delay": 1.2162,
          "n": 111
        },
        {
          "delay": 10.1667,
          "n": 30
        },
        {
          "delay": 1.1667,
          "n": 48
        },
        {
          "delay": 6.8132,
          "n": 91
        },
        {
          "delay": 18.2581,
          "n": 31
        },
        {
          "delay": 18.1471,
          "n": 34
        },
        {
          "delay": 5.1728,
          "n": 81
        },
        {
          "delay": 9.6,
          "n": 40
        },
        {
          "delay": -4.2667,
          "n": 45
        },
        {
          "delay": -1.2432,
          "n": 111
        },
        {
          "delay": 3.7333,
          "n": 30
        },
        {
          "delay": -13.7879,
          "n": 33
        },
        {
          "delay": 4.5364,
          "n": 110
        },
        {
          "delay": -4.1111,
          "n": 27
        },
        {
          "delay": 2.25,
          "n": 56
        },
        {
          "delay": 1.4587,
          "n": 109
        },
        {
          "delay": 12.1389,
          "n": 36
        },
        {
          "delay": 6.3804,
          "n": 92
        },
        {
          "delay": 2.4359,
          "n": 39
        },
        {
          "delay": 1.4327,
          "n": 104
        },
        {
          "delay": 8.4412,
          "n": 34
        },
        {
          "delay": -5.6032,
          "n": 63
        },
        {
          "delay": -5.6132,
          "n": 106
        },
        {
          "delay": 23.1944,
          "n": 36
        },
        {
          "delay": 2.5,
          "n": 44
        },
        {
          "delay": 3.2178,
          "n": 101
        },
        {
          "delay": 32.8333,
          "n": 18
        },
        {
          "delay": -11.6471,
          "n": 34
        },
        {
          "delay": 6.5843,
          "n": 89
        },
        {
          "delay": 9.381,
          "n": 21
        },
        {
          "delay": 11.625,
          "n": 32
        },
        {
          "delay": 5.4839,
          "n": 93
        },
        {
          "delay": 4.4231,
          "n": 26
        },
        {
          "delay": -0.8723,
          "n": 47
        },
        {
          "delay": 0.2247,
          "n": 89
        },
        {
          "delay": 7.8966,
          "n": 29
        },
        {
          "delay": -4.1017,
          "n": 59
        },
        {
          "delay": -0.3443,
          "n": 122
        },
        {
          "delay": 25.6765,
          "n": 34
        },
        {
          "delay": -9.6,
          "n": 55
        },
        {
          "delay": -2.9286,
          "n": 98
        },
        {
          "delay": 9.6452,
          "n": 31
        },
        {
          "delay": 17.1389,
          "n": 216
        },
        {
          "delay": -3.9524,
          "n": 42
        },
        {
          "delay": 1.8214,
          "n": 84
        },
        {
          "delay": -2.5926,
          "n": 27
        },
        {
          "delay": 3.125,
          "n": 48
        },
        {
          "delay": 7.0108,
          "n": 93
        },
        {
          "delay": 5,
          "n": 22
        },
        {
          "delay": -2.9545,
          "n": 44
        },
        {
          "delay": -0.5897,
          "n": 117
        },
        {
          "delay": 7.8947,
          "n": 38
        },
        {
          "delay": 2.9524,
          "n": 42
        },
        {
          "delay": 13.6111,
          "n": 90
        },
        {
          "delay": 6.1379,
          "n": 29
        },
        {
          "delay": -0.186,
          "n": 43
        },
        {
          "delay": -1.3905,
          "n": 105
        },
        {
          "delay": -2.0667,
          "n": 30
        },
        {
          "delay": 16.7297,
          "n": 37
        },
        {
          "delay": -8.4673,
          "n": 107
        },
        {
          "delay": 21.96,
          "n": 25
        },
        {
          "delay": 2.5304,
          "n": 115
        },
        {
          "delay": 5.2,
          "n": 20
        },
        {
          "delay": 8.275,
          "n": 40
        },
        {
          "delay": -0.5893,
          "n": 112
        },
        {
          "delay": 12.2,
          "n": 25
        },
        {
          "delay": 6.3962,
          "n": 106
        },
        {
          "delay": 15.9643,
          "n": 28
        },
        {
          "delay": -1.9904,
          "n": 104
        },
        {
          "delay": 5.5769,
          "n": 26
        },
        {
          "delay": -7.6818,
          "n": 44
        },
        {
          "delay": 6.4483,
          "n": 29
        },
        {
          "delay": 0.7273,
          "n": 44
        },
        {
          "delay": 4.6607,
          "n": 56
        },
        {
          "delay": -1.7,
          "n": 50
        },
        {
          "delay": 3.9783,
          "n": 46
        },
        {
          "delay": -4.1176,
          "n": 51
        },
        {
          "delay": 2.4286,
          "n": 56
        },
        {
          "delay": 4.7755,
          "n": 49
        },
        {
          "delay": -1.2593,
          "n": 54
        },
        {
          "delay": 1.5319,
          "n": 47
        },
        {
          "delay": 2.3158,
          "n": 19
        },
        {
          "delay": 4.6512,
          "n": 43
        },
        {
          "delay": -6.5814,
          "n": 43
        },
        {
          "delay": 9.7381,
          "n": 42
        },
        {
          "delay": 5.7647,
          "n": 17
        },
        {
          "delay": 4.3333,
          "n": 3
        },
        {
          "delay": 4.1132,
          "n": 53
        },
        {
          "delay": 10.3023,
          "n": 43
        },
        {
          "delay": -10.6667,
          "n": 54
        },
        {
          "delay": 1.4038,
          "n": 52
        },
        {
          "delay": -0.5714,
          "n": 49
        },
        {
          "delay": -5,
          "n": 61
        },
        {
          "delay": -7.0385,
          "n": 52
        },
        {
          "delay": -2,
          "n": 40
        },
        {
          "delay": -7.8718,
          "n": 39
        },
        {
          "delay": -8.322,
          "n": 59
        },
        {
          "delay": 9.7576,
          "n": 66
        },
        {
          "delay": -0.94,
          "n": 50
        },
        {
          "delay": -8.8696,
          "n": 46
        },
        {
          "delay": -3.7347,
          "n": 49
        },
        {
          "delay": 0.65,
          "n": 40
        },
        {
          "delay": -7.5645,
          "n": 62
        },
        {
          "delay": -5.25,
          "n": 40
        },
        {
          "delay": 7.125,
          "n": 56
        },
        {
          "delay": -8.25,
          "n": 24
        },
        {
          "delay": 1.6111,
          "n": 54
        },
        {
          "delay": -6.32,
          "n": 50
        },
        {
          "delay": 9,
          "n": 48
        },
        {
          "delay": -5.6923,
          "n": 52
        },
        {
          "delay": 7.3103,
          "n": 58
        },
        {
          "delay": 0.1667,
          "n": 60
        },
        {
          "delay": -2.26,
          "n": 50
        },
        {
          "delay": 3.8167,
          "n": 60
        },
        {
          "delay": -3.1458,
          "n": 48
        },
        {
          "delay": 2.55,
          "n": 40
        },
        {
          "delay": 0.871,
          "n": 62
        },
        {
          "delay": -6.4615,
          "n": 39
        },
        {
          "delay": 0.5641,
          "n": 39
        },
        {
          "delay": -5.8367,
          "n": 49
        },
        {
          "delay": -9.8261,
          "n": 69
        },
        {
          "delay": -2.5357,
          "n": 56
        },
        {
          "delay": 1.8043,
          "n": 46
        },
        {
          "delay": 0.6522,
          "n": 46
        },
        {
          "delay": -5.2549,
          "n": 51
        },
        {
          "delay": 0.3571,
          "n": 42
        },
        {
          "delay": 11.9067,
          "n": 225
        },
        {
          "delay": 3.7115,
          "n": 52
        },
        {
          "delay": 24.7143,
          "n": 14
        },
        {
          "delay": 15.2822,
          "n": 241
        },
        {
          "delay": 6.6667,
          "n": 3
        },
        {
          "delay": 3.3404,
          "n": 47
        },
        {
          "delay": 25,
          "n": 14
        },
        {
          "delay": 14.8185,
          "n": 270
        },
        {
          "delay": -6,
          "n": 1
        },
        {
          "delay": 7.6888,
          "n": 286
        },
        {
          "delay": 7.0926,
          "n": 54
        },
        {
          "delay": 7.9623,
          "n": 265
        },
        {
          "delay": 9.8182,
          "n": 11
        },
        {
          "delay": 19.0389,
          "n": 180
        },
        {
          "delay": 14.1481,
          "n": 81
        },
        {
          "delay": -22.6667,
          "n": 3
        },
        {
          "delay": -3.4884,
          "n": 43
        },
        {
          "delay": 7.8486,
          "n": 284
        },
        {
          "delay": 7.9167,
          "n": 12
        },
        {
          "delay": 20.0189,
          "n": 265
        },
        {
          "delay": 10.614,
          "n": 114
        },
        {
          "delay": -4.9111,
          "n": 45
        },
        {
          "delay": 8.4717,
          "n": 265
        },
        {
          "delay": 17.2941,
          "n": 17
        },
        {
          "delay": 21.5752,
          "n": 226
        },
        {
          "delay": -14,
          "n": 1
        },
        {
          "delay": 4.078,
          "n": 282
        },
        {
          "delay": 37.3,
          "n": 10
        },
        {
          "delay": -18.3333,
          "n": 9
        },
        {
          "delay": 12.2125,
          "n": 240
        },
        {
          "delay": 41.4,
          "n": 10
        },
        {
          "delay": 13.034,
          "n": 265
        },
        {
          "delay": 0.5714,
          "n": 7
        },
        {
          "delay": -4.2632,
          "n": 38
        },
        {
          "delay": 2.3571,
          "n": 42
        },
        {
          "delay": 8.9071,
          "n": 280
        },
        {
          "delay": 12.3333,
          "n": 18
        },
        {
          "delay": 12.336,
          "n": 247
        },
        {
          "delay": 3.3929,
          "n": 84
        },
        {
          "delay": 32.6667,
          "n": 3
        },
        {
          "delay": -0.225,
          "n": 40
        },
        {
          "delay": 15.25,
          "n": 8
        },
        {
          "delay": 4.1607,
          "n": 56
        },
        {
          "delay": 8.1661,
          "n": 289
        },
        {
          "delay": -5.2857,
          "n": 7
        },
        {
          "delay": 13.9711,
          "n": 277
        },
        {
          "delay": 4.3333,
          "n": 6
        },
        {
          "delay": 0.3992,
          "n": 238
        },
        {
          "delay": -14,
          "n": 1
        },
        {
          "delay": 6.1837,
          "n": 49
        },
        {
          "delay": 12.8944,
          "n": 322
        },
        {
          "delay": 26.8667,
          "n": 15
        },
        {
          "delay": 15.7931,
          "n": 232
        },
        {
          "delay": -4.6667,
          "n": 3
        },
        {
          "delay": 9.2449,
          "n": 98
        },
        {
          "delay": 7.7517,
          "n": 294
        },
        {
          "delay": 41.7333,
          "n": 15
        },
        {
          "delay": 14.8794,
          "n": 282
        },
        {
          "delay": -13,
          "n": 1
        },
        {
          "delay": 0.5061,
          "n": 247
        },
        {
          "delay": 11.1458,
          "n": 48
        },
        {
          "delay": -9.9286,
          "n": 14
        },
        {
          "delay": 22.9231,
          "n": 13
        },
        {
          "delay": 14.2684,
          "n": 272
        },
        {
          "delay": 8,
          "n": 2
        },
        {
          "delay": 16.2685,
          "n": 108
        },
        {
          "delay": 1.8,
          "n": 30
        },
        {
          "delay": -31.5,
          "n": 6
        },
        {
          "delay": 21.1333,
          "n": 15
        },
        {
          "delay": 11.2103,
          "n": 214
        },
        {
          "delay": -11.5,
          "n": 2
        },
        {
          "delay": 2.4947,
          "n": 281
        },
        {
          "delay": -2.5122,
          "n": 41
        },
        {
          "delay": -11.4,
          "n": 5
        },
        {
          "delay": 17.625,
          "n": 16
        },
        {
          "delay": 15.1502,
          "n": 273
        },
        {
          "delay": 9.7745,
          "n": 102
        },
        {
          "delay": -4.2381,
          "n": 42
        },
        {
          "delay": -17.3333,
          "n": 3
        },
        {
          "delay": 11.1818,
          "n": 11
        },
        {
          "delay": 15.6076,
          "n": 237
        },
        {
          "delay": 4,
          "n": 2
        },
        {
          "delay": 11.5169,
          "n": 89
        },
        {
          "delay": 1.8571,
          "n": 28
        },
        {
          "delay": 28.625,
          "n": 16
        },
        {
          "delay": 10.319,
          "n": 232
        },
        {
          "delay": 8,
          "n": 3
        },
        {
          "delay": 19.5125,
          "n": 80
        },
        {
          "delay": -13.1154,
          "n": 26
        },
        {
          "delay": 44.5,
          "n": 4
        },
        {
          "delay": 12.0423,
          "n": 284
        },
        {
          "delay": -5.4667,
          "n": 15
        },
        {
          "delay": 11.417,
          "n": 259
        },
        {
          "delay": -0.6765,
          "n": 68
        },
        {
          "delay": 6.5625,
          "n": 16
        },
        {
          "delay": -40.5,
          "n": 2
        },
        {
          "delay": 11.6338,
          "n": 284
        },
        {
          "delay": 15.2169,
          "n": 249
        },
        {
          "delay": -5.8529,
          "n": 34
        },
        {
          "delay": -3.2308,
          "n": 13
        },
        {
          "delay": -17,
          "n": 2
        },
        {
          "delay": 19.5385,
          "n": 13
        },
        {
          "delay": 18.5604,
          "n": 298
        },
        {
          "delay": 1.2321,
          "n": 237
        },
        {
          "delay": 6.4054,
          "n": 37
        },
        {
          "delay": -17.2,
          "n": 5
        },
        {
          "delay": 11.1255,
          "n": 263
        },
        {
          "delay": 24.6667,
          "n": 15
        },
        {
          "delay": 13.974,
          "n": 231
        },
        {
          "delay": 13.3222,
          "n": 90
        },
        {
          "delay": 4.6667,
          "n": 3
        },
        {
          "delay": 0.1739,
          "n": 46
        },
        {
          "delay": -5.9608,
          "n": 51
        },
        {
          "delay": -2.6,
          "n": 5
        },
        {
          "delay": 12.5929,
          "n": 280
        },
        {
          "delay": 15.4321,
          "n": 287
        },
        {
          "delay": 2.022,
          "n": 91
        },
        {
          "delay": -0.3922,
          "n": 51
        },
        {
          "delay": -5.4242,
          "n": 33
        },
        {
          "delay": 10.3566,
          "n": 258
        },
        {
          "delay": 13.2941,
          "n": 17
        },
        {
          "delay": 8.6014,
          "n": 276
        },
        {
          "delay": 88,
          "n": 1
        },
        {
          "delay": 9.4533,
          "n": 75
        },
        {
          "delay": 50.5714,
          "n": 7
        },
        {
          "delay": -2.2679,
          "n": 56
        },
        {
          "delay": 42.2222,
          "n": 27
        },
        {
          "delay": -2.8462,
          "n": 39
        },
        {
          "delay": 13.7143,
          "n": 14
        },
        {
          "delay": 14.8773,
          "n": 277
        },
        {
          "delay": -15.5,
          "n": 2
        },
        {
          "delay": 12.8298,
          "n": 94
        },
        {
          "delay": -4.2,
          "n": 5
        },
        {
          "delay": 37.8065,
          "n": 31
        },
        {
          "delay": -20.1429,
          "n": 7
        },
        {
          "delay": 11.8679,
          "n": 318
        },
        {
          "delay": 14.5094,
          "n": 320
        },
        {
          "delay": -16.5,
          "n": 2
        },
        {
          "delay": 16.83,
          "n": 100
        },
        {
          "delay": -14.125,
          "n": 8
        },
        {
          "delay": 7.8462,
          "n": 39
        },
        {
          "delay": 15.1429,
          "n": 28
        },
        {
          "delay": -17.2222,
          "n": 9
        },
        {
          "delay": 4.6423,
          "n": 274
        },
        {
          "delay": 12.1783,
          "n": 230
        },
        {
          "delay": 56,
          "n": 2
        },
        {
          "delay": 0.7368,
          "n": 114
        },
        {
          "delay": 0.1224,
          "n": 49
        },
        {
          "delay": 3.6429,
          "n": 28
        },
        {
          "delay": -2.878,
          "n": 41
        },
        {
          "delay": 8,
          "n": 6
        },
        {
          "delay": 5.5164,
          "n": 304
        },
        {
          "delay": -4,
          "n": 2
        },
        {
          "delay": 9.9558,
          "n": 226
        },
        {
          "delay": 0.3333,
          "n": 3
        },
        {
          "delay": 0.2581,
          "n": 31
        },
        {
          "delay": 0.4231,
          "n": 52
        },
        {
          "delay": -21,
          "n": 9
        },
        {
          "delay": 7.5751,
          "n": 273
        },
        {
          "delay": 14.3262,
          "n": 282
        },
        {
          "delay": -6,
          "n": 2
        },
        {
          "delay": 11.129,
          "n": 93
        },
        {
          "delay": 4.8571,
          "n": 28
        },
        {
          "delay": 1.6562,
          "n": 32
        },
        {
          "delay": -9,
          "n": 4
        },
        {
          "delay": 7.4126,
          "n": 269
        },
        {
          "delay": 13.5867,
          "n": 300
        },
        {
          "delay": 0,
          "n": 2
        },
        {
          "delay": 16.9583,
          "n": 24
        },
        {
          "delay": 5.973,
          "n": 37
        },
        {
          "delay": 9.0755,
          "n": 53
        },
        {
          "delay": -13,
          "n": 5
        },
        {
          "delay": 12.6637,
          "n": 333
        },
        {
          "delay": -1.4898,
          "n": 98
        },
        {
          "delay": 27.9565,
          "n": 23
        },
        {
          "delay": -2.2174,
          "n": 23
        },
        {
          "delay": 21.5,
          "n": 4
        },
        {
          "delay": 10.2175,
          "n": 285
        },
        {
          "delay": 4.8276,
          "n": 116
        },
        {
          "delay": 15.4118,
          "n": 34
        },
        {
          "delay": -8.7568,
          "n": 37
        },
        {
          "delay": -24.375,
          "n": 8
        },
        {
          "delay": 10.7241,
          "n": 290
        },
        {
          "delay": 6.5481,
          "n": 104
        },
        {
          "delay": 20.8,
          "n": 5
        },
        {
          "delay": 22.8857,
          "n": 35
        },
        {
          "delay": -17.6,
          "n": 5
        },
        {
          "delay": 11.116,
          "n": 250
        },
        {
          "delay": 13.9668,
          "n": 331
        },
        {
          "delay": -10.1667,
          "n": 6
        },
        {
          "delay": -18.6,
          "n": 10
        },
        {
          "delay": 11.3038,
          "n": 316
        },
        {
          "delay": -2.04,
          "n": 75
        },
        {
          "delay": 2.5,
          "n": 2
        },
        {
          "delay": -21.625,
          "n": 8
        },
        {
          "delay": 8.0532,
          "n": 94
        },
        {
          "delay": -7,
          "n": 5
        },
        {
          "delay": 0.9406,
          "n": 101
        },
        {
          "delay": 0.5741,
          "n": 108
        },
        {
          "delay": -28,
          "n": 2
        },
        {
          "delay": 7.7821,
          "n": 280
        },
        {
          "delay": 9.4457,
          "n": 350
        },
        {
          "delay": 8.2198,
          "n": 91
        },
        {
          "delay": 8.3333,
          "n": 6
        },
        {
          "delay": -1.3404,
          "n": 47
        },
        {
          "delay": -11,
          "n": 4
        },
        {
          "delay": 10.4,
          "n": 260
        },
        {
          "delay": 15.3755,
          "n": 253
        },
        {
          "delay": 6.0206,
          "n": 97
        },
        {
          "delay": 2.1333,
          "n": 60
        },
        {
          "delay": -22.5,
          "n": 4
        },
        {
          "delay": -17,
          "n": 1
        },
        {
          "delay": 9.1774,
          "n": 265
        },
        {
          "delay": 9.6632,
          "n": 95
        },
        {
          "delay": 4.8125,
          "n": 80
        },
        {
          "delay": 14.2286,
          "n": 35
        },
        {
          "delay": -15.3333,
          "n": 3
        },
        {
          "delay": 8.1851,
          "n": 281
        },
        {
          "delay": 10.3978,
          "n": 279
        },
        {
          "delay": 22.337,
          "n": 92
        },
        {
          "delay": -0.25,
          "n": 84
        },
        {
          "delay": -9.6,
          "n": 35
        },
        {
          "delay": -19.3333,
          "n": 3
        },
        {
          "delay": 19.1429,
          "n": 42
        },
        {
          "delay": 10.5755,
          "n": 106
        },
        {
          "delay": 5.7284,
          "n": 81
        },
        {
          "delay": -2.6522,
          "n": 69
        },
        {
          "delay": 11.5609,
          "n": 271
        },
        {
          "delay": 1.883,
          "n": 94
        },
        {
          "delay": -12.3333,
          "n": 3
        },
        {
          "delay": -1.3021,
          "n": 96
        },
        {
          "delay": -12.2941,
          "n": 34
        },
        {
          "delay": -1.1494,
          "n": 87
        },
        {
          "delay": 20.3636,
          "n": 11
        },
        {
          "delay": -0.0941,
          "n": 85
        },
        {
          "delay": -3.8667,
          "n": 45
        },
        {
          "delay": 9.7606,
          "n": 71
        },
        {
          "delay": 6,
          "n": 5
        },
        {
          "delay": -0.9487,
          "n": 39
        },
        {
          "delay": 2.6542,
          "n": 107
        },
        {
          "delay": 5.2239,
          "n": 67
        },
        {
          "delay": 6.2377,
          "n": 345
        },
        {
          "delay": 3.8333,
          "n": 6
        },
        {
          "delay": 14.3065,
          "n": 62
        },
        {
          "delay": -0.0217,
          "n": 46
        },
        {
          "delay": 13.7656,
          "n": 192
        },
        {
          "delay": 7.56,
          "n": 25
        },
        {
          "delay": -13.5,
          "n": 4
        },
        {
          "delay": 4.2683,
          "n": 82
        },
        {
          "delay": 12.9464,
          "n": 56
        },
        {
          "delay": 8.9634,
          "n": 246
        },
        {
          "delay": 3.8333,
          "n": 30
        },
        {
          "delay": 0.6038,
          "n": 53
        },
        {
          "delay": -7.3659,
          "n": 41
        },
        {
          "delay": 16.4706,
          "n": 34
        },
        {
          "delay": 1.8269,
          "n": 52
        },
        {
          "delay": 5.5306,
          "n": 49
        },
        {
          "delay": -30.1538,
          "n": 13
        },
        {
          "delay": 7.5197,
          "n": 229
        },
        {
          "delay": 5.061,
          "n": 82
        },
        {
          "delay": -1.0755,
          "n": 53
        },
        {
          "delay": 9.8716,
          "n": 148
        },
        {
          "delay": 10.5,
          "n": 58
        },
        {
          "delay": 3.7809,
          "n": 283
        },
        {
          "delay": 19.5455,
          "n": 33
        },
        {
          "delay": 17,
          "n": 2
        },
        {
          "delay": 2.2667,
          "n": 60
        },
        {
          "delay": -15.4694,
          "n": 49
        },
        {
          "delay": 3.6429,
          "n": 14
        },
        {
          "delay": -1.5769,
          "n": 26
        },
        {
          "delay": 16.625,
          "n": 8
        },
        {
          "delay": -13.0385,
          "n": 52
        },
        {
          "delay": -7.6429,
          "n": 28
        },
        {
          "delay": -19.75,
          "n": 16
        },
        {
          "delay": -7.3913,
          "n": 23
        },
        {
          "delay": -3.2,
          "n": 5
        },
        {
          "delay": -1.8269,
          "n": 52
        },
        {
          "delay": -7.2,
          "n": 30
        },
        {
          "delay": 51.4286,
          "n": 7
        },
        {
          "delay": 2.1429,
          "n": 14
        },
        {
          "delay": -1.431,
          "n": 58
        },
        {
          "delay": 31.3478,
          "n": 23
        },
        {
          "delay": -5.0556,
          "n": 36
        },
        {
          "delay": -12.0455,
          "n": 22
        },
        {
          "delay": 13.4286,
          "n": 7
        },
        {
          "delay": 8.3684,
          "n": 38
        },
        {
          "delay": 1.2034,
          "n": 59
        },
        {
          "delay": 0.5652,
          "n": 23
        },
        {
          "delay": -8,
          "n": 30
        },
        {
          "delay": -3,
          "n": 17
        },
        {
          "delay": 10.7362,
          "n": 307
        },
        {
          "delay": 47,
          "n": 4
        },
        {
          "delay": 15.0417,
          "n": 24
        },
        {
          "delay": 15.9057,
          "n": 53
        },
        {
          "delay": -1.5,
          "n": 22
        },
        {
          "delay": -6.3333,
          "n": 51
        },
        {
          "delay": -8.0556,
          "n": 18
        },
        {
          "delay": 1.4,
          "n": 5
        },
        {
          "delay": 11.0738,
          "n": 122
        },
        {
          "delay": 15,
          "n": 41
        },
        {
          "delay": 18.5,
          "n": 16
        },
        {
          "delay": -1.6071,
          "n": 56
        },
        {
          "delay": 6.5537,
          "n": 298
        },
        {
          "delay": 27,
          "n": 8
        },
        {
          "delay": 2.2958,
          "n": 240
        },
        {
          "delay": 4.4545,
          "n": 88
        },
        {
          "delay": 6.037,
          "n": 27
        },
        {
          "delay": -6.5116,
          "n": 43
        },
        {
          "delay": -1.2537,
          "n": 67
        },
        {
          "delay": 21.4333,
          "n": 30
        },
        {
          "delay": -3.8,
          "n": 10
        },
        {
          "delay": 1.444,
          "n": 232
        },
        {
          "delay": -4.5745,
          "n": 47
        },
        {
          "delay": -21.5,
          "n": 12
        },
        {
          "delay": 12.2943,
          "n": 299
        },
        {
          "delay": 18.8333,
          "n": 6
        },
        {
          "delay": 10.6804,
          "n": 97
        },
        {
          "delay": 9.2078,
          "n": 77
        },
        {
          "delay": 5.7778,
          "n": 36
        },
        {
          "delay": 0.875,
          "n": 40
        },
        {
          "delay": -30,
          "n": 1
        },
        {
          "delay": 0.4,
          "n": 10
        },
        {
          "delay": 1.305,
          "n": 259
        },
        {
          "delay": -3.0323,
          "n": 62
        },
        {
          "delay": 7.9474,
          "n": 38
        },
        {
          "delay": -14.8333,
          "n": 6
        },
        {
          "delay": 11.5934,
          "n": 305
        },
        {
          "delay": 8.9895,
          "n": 95
        },
        {
          "delay": 1.4321,
          "n": 81
        },
        {
          "delay": -1.2364,
          "n": 55
        },
        {
          "delay": -12.2857,
          "n": 7
        },
        {
          "delay": 9.6808,
          "n": 260
        },
        {
          "delay": 0.9588,
          "n": 97
        },
        {
          "delay": 1.4725,
          "n": 91
        },
        {
          "delay": -2.3784,
          "n": 37
        },
        {
          "delay": -53,
          "n": 1
        },
        {
          "delay": 5.9114,
          "n": 271
        },
        {
          "delay": 7.0435,
          "n": 69
        },
        {
          "delay": -10.5263,
          "n": 38
        },
        {
          "delay": 13.5367,
          "n": 300
        },
        {
          "delay": 12.8155,
          "n": 103
        },
        {
          "delay": 6.8333,
          "n": 84
        },
        {
          "delay": -20,
          "n": 2
        },
        {
          "delay": 10.9904,
          "n": 312
        },
        {
          "delay": 6.2558,
          "n": 86
        },
        {
          "delay": 6.6988,
          "n": 83
        },
        {
          "delay": -6.2857,
          "n": 7
        },
        {
          "delay": 8.6996,
          "n": 273
        },
        {
          "delay": 7.2982,
          "n": 114
        },
        {
          "delay": 4.8,
          "n": 60
        },
        {
          "delay": -5.3036,
          "n": 56
        },
        {
          "delay": -31,
          "n": 3
        },
        {
          "delay": 8.7148,
          "n": 284
        },
        {
          "delay": 7.8396,
          "n": 106
        },
        {
          "delay": 6.3372,
          "n": 86
        },
        {
          "delay": 10.8205,
          "n": 39
        },
        {
          "delay": -21.6667,
          "n": 3
        },
        {
          "delay": 12.0808,
          "n": 260
        },
        {
          "delay": 14.0323,
          "n": 93
        },
        {
          "delay": 1.4615,
          "n": 91
        },
        {
          "delay": 9.3529,
          "n": 34
        },
        {
          "delay": -7.875,
          "n": 8
        },
        {
          "delay": 7.35,
          "n": 260
        },
        {
          "delay": 9.211,
          "n": 109
        },
        {
          "delay": 4.7586,
          "n": 87
        },
        {
          "delay": -4.2951,
          "n": 61
        },
        {
          "delay": 15.0286,
          "n": 105
        },
        {
          "delay": -4.7073,
          "n": 41
        },
        {
          "delay": 7.75,
          "n": 40
        },
        {
          "delay": 4.8,
          "n": 40
        },
        {
          "delay": -23.8,
          "n": 5
        },
        {
          "delay": 9.8729,
          "n": 291
        },
        {
          "delay": 2.578,
          "n": 109
        },
        {
          "delay": -6.2174,
          "n": 23
        },
        {
          "delay": -3.6829,
          "n": 41
        },
        {
          "delay": 15,
          "n": 1
        },
        {
          "delay": 3.8732,
          "n": 205
        },
        {
          "delay": 12.4819,
          "n": 83
        },
        {
          "delay": 3.28,
          "n": 25
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": -0.1587,
          "n": 63
        },
        {
          "delay": -18.8,
          "n": 5
        },
        {
          "delay": 7.7295,
          "n": 281
        },
        {
          "delay": 11.2421,
          "n": 95
        },
        {
          "delay": 7.1667,
          "n": 6
        },
        {
          "delay": 5.9759,
          "n": 83
        },
        {
          "delay": 13.7255,
          "n": 51
        },
        {
          "delay": 10.6667,
          "n": 255
        },
        {
          "delay": 5.3837,
          "n": 86
        },
        {
          "delay": -10,
          "n": 12
        },
        {
          "delay": 1.3377,
          "n": 77
        },
        {
          "delay": -29.5,
          "n": 2
        },
        {
          "delay": -1.9796,
          "n": 49
        },
        {
          "delay": 3.419,
          "n": 105
        },
        {
          "delay": -5.2718,
          "n": 103
        },
        {
          "delay": -10.7143,
          "n": 35
        },
        {
          "delay": 4.5263,
          "n": 95
        },
        {
          "delay": -1.9211,
          "n": 38
        },
        {
          "delay": 8.6854,
          "n": 89
        },
        {
          "delay": -1.0566,
          "n": 53
        },
        {
          "delay": 4.3511,
          "n": 94
        },
        {
          "delay": -3.375,
          "n": 24
        },
        {
          "delay": -11.3333,
          "n": 3
        },
        {
          "delay": 18.4946,
          "n": 93
        },
        {
          "delay": 12.7451,
          "n": 51
        },
        {
          "delay": 14.617,
          "n": 47
        },
        {
          "delay": 22.6875,
          "n": 32
        },
        {
          "delay": 4.5,
          "n": 12
        },
        {
          "delay": 10.6429,
          "n": 14
        },
        {
          "delay": 15.8462,
          "n": 13
        },
        {
          "delay": 11.875,
          "n": 16
        },
        {
          "delay": -8.9231,
          "n": 13
        },
        {
          "delay": -5,
          "n": 9
        },
        {
          "delay": 0.0233,
          "n": 43
        },
        {
          "delay": 12.4722,
          "n": 108
        },
        {
          "delay": -11.0816,
          "n": 49
        },
        {
          "delay": -12.5,
          "n": 2
        },
        {
          "delay": 10.7824,
          "n": 262
        },
        {
          "delay": 9.9903,
          "n": 103
        },
        {
          "delay": -6.2683,
          "n": 41
        },
        {
          "delay": 14.6767,
          "n": 266
        },
        {
          "delay": 8.7931,
          "n": 87
        },
        {
          "delay": -6.9024,
          "n": 82
        },
        {
          "delay": -9.5,
          "n": 34
        },
        {
          "delay": -20,
          "n": 8
        },
        {
          "delay": 2.5965,
          "n": 57
        },
        {
          "delay": 14.7368,
          "n": 57
        },
        {
          "delay": 0.5366,
          "n": 41
        },
        {
          "delay": -0.3443,
          "n": 61
        },
        {
          "delay": -24,
          "n": 2
        },
        {
          "delay": 6.721,
          "n": 276
        },
        {
          "delay": -4.3103,
          "n": 58
        },
        {
          "delay": -4.5714,
          "n": 7
        },
        {
          "delay": 15.6071,
          "n": 308
        },
        {
          "delay": -0.8033,
          "n": 61
        },
        {
          "delay": 4.3,
          "n": 40
        },
        {
          "delay": -34.5,
          "n": 2
        },
        {
          "delay": 7.2908,
          "n": 306
        },
        {
          "delay": 7.6857,
          "n": 105
        },
        {
          "delay": -4.8182,
          "n": 44
        },
        {
          "delay": 50,
          "n": 2
        },
        {
          "delay": 7.9286,
          "n": 280
        },
        {
          "delay": 9.3485,
          "n": 66
        },
        {
          "delay": 11.6364,
          "n": 44
        },
        {
          "delay": 21.875,
          "n": 8
        },
        {
          "delay": 7.3322,
          "n": 292
        },
        {
          "delay": 264,
          "n": 1
        },
        {
          "delay": 8.3592,
          "n": 103
        },
        {
          "delay": 11.2765,
          "n": 264
        },
        {
          "delay": 4.3448,
          "n": 145
        },
        {
          "delay": 0.3061,
          "n": 49
        },
        {
          "delay": 61.5,
          "n": 2
        },
        {
          "delay": 7.8696,
          "n": 299
        },
        {
          "delay": 1.6842,
          "n": 171
        },
        {
          "delay": 6.4783,
          "n": 23
        },
        {
          "delay": -5.8974,
          "n": 39
        },
        {
          "delay": -24,
          "n": 4
        },
        {
          "delay": 12.1944,
          "n": 324
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": 5.0978,
          "n": 92
        },
        {
          "delay": -1.6304,
          "n": 46
        },
        {
          "delay": 7.6211,
          "n": 285
        },
        {
          "delay": 2.3571,
          "n": 56
        },
        {
          "delay": -35.5,
          "n": 4
        },
        {
          "delay": 9.983,
          "n": 294
        },
        {
          "delay": 2.2708,
          "n": 48
        },
        {
          "delay": 3.7451,
          "n": 51
        },
        {
          "delay": -30.5,
          "n": 2
        },
        {
          "delay": 12.6838,
          "n": 291
        },
        {
          "delay": 18.4419,
          "n": 86
        },
        {
          "delay": 2.25,
          "n": 48
        },
        {
          "delay": -31.3333,
          "n": 6
        },
        {
          "delay": 9.277,
          "n": 296
        },
        {
          "delay": -9,
          "n": 1
        },
        {
          "delay": 5.0459,
          "n": 109
        },
        {
          "delay": -13.2941,
          "n": 51
        },
        {
          "delay": 13.9516,
          "n": 310
        },
        {
          "delay": 45,
          "n": 1
        },
        {
          "delay": 5.795,
          "n": 200
        },
        {
          "delay": -9,
          "n": 4
        },
        {
          "delay": -2.8542,
          "n": 48
        },
        {
          "delay": -18.8,
          "n": 5
        },
        {
          "delay": -1.1572,
          "n": 229
        },
        {
          "delay": -0.4255,
          "n": 47
        },
        {
          "delay": -14,
          "n": 4
        },
        {
          "delay": 8.8165,
          "n": 267
        },
        {
          "delay": -3.2222,
          "n": 180
        },
        {
          "delay": -2.1897,
          "n": 58
        },
        {
          "delay": 9.9803,
          "n": 304
        },
        {
          "delay": -3.9055,
          "n": 127
        },
        {
          "delay": -0.3607,
          "n": 61
        },
        {
          "delay": 8.3648,
          "n": 307
        },
        {
          "delay": 1.8,
          "n": 40
        },
        {
          "delay": 1.0294,
          "n": 34
        },
        {
          "delay": -3.0238,
          "n": 42
        },
        {
          "delay": -3.6875,
          "n": 32
        },
        {
          "delay": -5.7692,
          "n": 39
        },
        {
          "delay": 22.6129,
          "n": 31
        },
        {
          "delay": -2.6571,
          "n": 35
        },
        {
          "delay": 5.8966,
          "n": 29
        },
        {
          "delay": 5.7381,
          "n": 42
        },
        {
          "delay": 18.8,
          "n": 20
        },
        {
          "delay": -0.0606,
          "n": 33
        },
        {
          "delay": 10.3488,
          "n": 43
        },
        {
          "delay": 7.9714,
          "n": 35
        },
        {
          "delay": 6.5161,
          "n": 31
        },
        {
          "delay": 2.3529,
          "n": 17
        },
        {
          "delay": -1.1,
          "n": 20
        },
        {
          "delay": 15.7812,
          "n": 32
        },
        {
          "delay": -0.0769,
          "n": 39
        },
        {
          "delay": 4.8519,
          "n": 27
        },
        {
          "delay": 2.8182,
          "n": 11
        },
        {
          "delay": -3.625,
          "n": 16
        },
        {
          "delay": 26.5455,
          "n": 11
        },
        {
          "delay": 16,
          "n": 16
        },
        {
          "delay": -0.6538,
          "n": 26
        },
        {
          "delay": -3.8,
          "n": 5
        },
        {
          "delay": 5.1429,
          "n": 7
        },
        {
          "delay": 5.8333,
          "n": 6
        },
        {
          "delay": -30,
          "n": 1
        },
        {
          "delay": 4.5,
          "n": 2
        },
        {
          "delay": 5.8824,
          "n": 17
        },
        {
          "delay": 21.7576,
          "n": 33
        },
        {
          "delay": 9.3214,
          "n": 28
        },
        {
          "delay": -10.4167,
          "n": 12
        },
        {
          "delay": -4.1667,
          "n": 12
        },
        {
          "delay": 2.5556,
          "n": 27
        },
        {
          "delay": 12.7317,
          "n": 41
        },
        {
          "delay": -8.3846,
          "n": 39
        },
        {
          "delay": 12,
          "n": 26
        },
        {
          "delay": 2.2812,
          "n": 32
        },
        {
          "delay": 0.88,
          "n": 25
        },
        {
          "delay": 7.7647,
          "n": 34
        },
        {
          "delay": 4.575,
          "n": 40
        },
        {
          "delay": 2.1724,
          "n": 29
        },
        {
          "delay": -13,
          "n": 1
        },
        {
          "delay": 7.6,
          "n": 5
        },
        {
          "delay": 9.125,
          "n": 40
        },
        {
          "delay": -7.9697,
          "n": 33
        },
        {
          "delay": 5.6585,
          "n": 41
        },
        {
          "delay": 23.8235,
          "n": 34
        },
        {
          "delay": -12.4762,
          "n": 21
        },
        {
          "delay": -7.3913,
          "n": 23
        },
        {
          "delay": -5.5938,
          "n": 32
        },
        {
          "delay": 25.6757,
          "n": 37
        },
        {
          "delay": -4.7778,
          "n": 27
        },
        {
          "delay": 3.3158,
          "n": 19
        },
        {
          "delay": 37,
          "n": 1
        },
        {
          "delay": -6.5,
          "n": 2
        },
        {
          "delay": -0.68,
          "n": 125
        },
        {
          "delay": -3.0196,
          "n": 102
        },
        {
          "delay": 1.8046,
          "n": 87
        },
        {
          "delay": -3.6731,
          "n": 104
        },
        {
          "delay": -8.0278,
          "n": 108
        },
        {
          "delay": 0.1316,
          "n": 114
        },
        {
          "delay": -2.1026,
          "n": 117
        },
        {
          "delay": -1.5,
          "n": 4
        },
        {
          "delay": -18,
          "n": 1
        },
        {
          "delay": -27,
          "n": 1
        },
        {
          "delay": -0.732,
          "n": 97
        },
        {
          "delay": 1.6709,
          "n": 79
        },
        {
          "delay": -2,
          "n": 70
        },
        {
          "delay": -0.6667,
          "n": 93
        },
        {
          "delay": -1.7561,
          "n": 82
        },
        {
          "delay": 1.3462,
          "n": 104
        },
        {
          "delay": -9.8472,
          "n": 72
        },
        {
          "delay": -2.5138,
          "n": 109
        },
        {
          "delay": 8.9208,
          "n": 101
        },
        {
          "delay": -5.699,
          "n": 103
        },
        {
          "delay": -2.0714,
          "n": 70
        },
        {
          "delay": -6.17,
          "n": 100
        },
        {
          "delay": -4.7157,
          "n": 102
        },
        {
          "delay": 11.4052,
          "n": 269
        },
        {
          "delay": 3.7315,
          "n": 257
        },
        {
          "delay": 11.7647,
          "n": 17
        },
        {
          "delay": 6.5587,
          "n": 179
        },
        {
          "delay": -11,
          "n": 2
        },
        {
          "delay": 5.4,
          "n": 5
        },
        {
          "delay": -1.7121,
          "n": 66
        },
        {
          "delay": 11.0533,
          "n": 225
        },
        {
          "delay": 8.5556,
          "n": 36
        },
        {
          "delay": 5,
          "n": 2
        },
        {
          "delay": -1,
          "n": 48
        },
        {
          "delay": -3.4167,
          "n": 48
        },
        {
          "delay": 2.9375,
          "n": 32
        },
        {
          "delay": 12.1439,
          "n": 271
        },
        {
          "delay": 13.8333,
          "n": 12
        },
        {
          "delay": 23.1429,
          "n": 7
        },
        {
          "delay": -4.35,
          "n": 40
        },
        {
          "delay": 11.4118,
          "n": 34
        },
        {
          "delay": 14.5306,
          "n": 49
        },
        {
          "delay": 10.9479,
          "n": 307
        },
        {
          "delay": 11.25,
          "n": 24
        },
        {
          "delay": 4.2857,
          "n": 7
        },
        {
          "delay": 1.4328,
          "n": 67
        },
        {
          "delay": -2.0333,
          "n": 30
        },
        {
          "delay": 9.9737,
          "n": 228
        },
        {
          "delay": 11.75,
          "n": 28
        },
        {
          "delay": 4.8,
          "n": 115
        },
        {
          "delay": 0.5,
          "n": 12
        },
        {
          "delay": 12.7852,
          "n": 256
        },
        {
          "delay": 4.4764,
          "n": 275
        },
        {
          "delay": 11.6667,
          "n": 9
        },
        {
          "delay": 3.4444,
          "n": 126
        },
        {
          "delay": -10.3333,
          "n": 6
        },
        {
          "delay": 6.9068,
          "n": 311
        },
        {
          "delay": 1.25,
          "n": 36
        },
        {
          "delay": 38.4211,
          "n": 19
        },
        {
          "delay": 0.25,
          "n": 4
        },
        {
          "delay": 21.7778,
          "n": 45
        },
        {
          "delay": 9.7326,
          "n": 288
        },
        {
          "delay": 7.5758,
          "n": 33
        },
        {
          "delay": 12.3529,
          "n": 17
        },
        {
          "delay": 1.1429,
          "n": 7
        },
        {
          "delay": 14.1429,
          "n": 28
        },
        {
          "delay": -1.7273,
          "n": 11
        },
        {
          "delay": 7.8738,
          "n": 301
        },
        {
          "delay": 4.2,
          "n": 5
        },
        {
          "delay": 5.2396,
          "n": 192
        },
        {
          "delay": -8,
          "n": 2
        },
        {
          "delay": 14.9,
          "n": 30
        },
        {
          "delay": 22.875,
          "n": 8
        },
        {
          "delay": 64.8,
          "n": 5
        },
        {
          "delay": 24.1818,
          "n": 22
        },
        {
          "delay": 2.6538,
          "n": 26
        },
        {
          "delay": 43.25,
          "n": 4
        },
        {
          "delay": 12.4545,
          "n": 22
        },
        {
          "delay": 14.4,
          "n": 175
        },
        {
          "delay": -5.1667,
          "n": 6
        },
        {
          "delay": 7.4,
          "n": 20
        },
        {
          "delay": -1.3929,
          "n": 56
        },
        {
          "delay": 9.6441,
          "n": 281
        },
        {
          "delay": 1.1724,
          "n": 29
        },
        {
          "delay": 7.0157,
          "n": 191
        },
        {
          "delay": -7.5,
          "n": 2
        },
        {
          "delay": 7.9355,
          "n": 31
        },
        {
          "delay": 4.1,
          "n": 20
        },
        {
          "delay": 13.3727,
          "n": 322
        },
        {
          "delay": 14.9444,
          "n": 18
        },
        {
          "delay": -6,
          "n": 2
        },
        {
          "delay": 11.7368,
          "n": 19
        },
        {
          "delay": 0.1667,
          "n": 12
        },
        {
          "delay": 2.5765,
          "n": 170
        },
        {
          "delay": 29.5,
          "n": 6
        },
        {
          "delay": 4.0455,
          "n": 22
        },
        {
          "delay": 0.75,
          "n": 24
        },
        {
          "delay": 7.7258,
          "n": 248
        },
        {
          "delay": 12.5294,
          "n": 34
        },
        {
          "delay": 12.8,
          "n": 210
        },
        {
          "delay": 2.5,
          "n": 6
        },
        {
          "delay": 2.3607,
          "n": 61
        },
        {
          "delay": 3.0952,
          "n": 21
        },
        {
          "delay": 3.6,
          "n": 5
        },
        {
          "delay": 3.6552,
          "n": 29
        },
        {
          "delay": 2.3621,
          "n": 58
        },
        {
          "delay": 24.6452,
          "n": 31
        },
        {
          "delay": 8.6667,
          "n": 3
        },
        {
          "delay": -1.7391,
          "n": 23
        },
        {
          "delay": 7.7455,
          "n": 55
        },
        {
          "delay": 10.3974,
          "n": 307
        },
        {
          "delay": 3.9302,
          "n": 43
        },
        {
          "delay": 3.1667,
          "n": 6
        },
        {
          "delay": 7.6522,
          "n": 23
        },
        {
          "delay": 18.3846,
          "n": 26
        },
        {
          "delay": -12.5,
          "n": 2
        },
        {
          "delay": 18.4211,
          "n": 38
        },
        {
          "delay": 12.6667,
          "n": 9
        },
        {
          "delay": 10.6136,
          "n": 44
        },
        {
          "delay": 10.0611,
          "n": 311
        },
        {
          "delay": 2.087,
          "n": 23
        },
        {
          "delay": 47.3333,
          "n": 3
        },
        {
          "delay": 5.3052,
          "n": 154
        },
        {
          "delay": 2.7297,
          "n": 37
        },
        {
          "delay": 37,
          "n": 1
        },
        {
          "delay": 12.2143,
          "n": 14
        },
        {
          "delay": -2,
          "n": 5
        },
        {
          "delay": 3.4062,
          "n": 128
        },
        {
          "delay": 1.0526,
          "n": 38
        },
        {
          "delay": 12.2553,
          "n": 47
        },
        {
          "delay": 11.5319,
          "n": 282
        },
        {
          "delay": 22.3043,
          "n": 23
        },
        {
          "delay": -10.3333,
          "n": 3
        },
        {
          "delay": -0.3932,
          "n": 117
        },
        {
          "delay": -5.5862,
          "n": 29
        },
        {
          "delay": -2.5,
          "n": 298
        },
        {
          "delay": 53,
          "n": 1
        },
        {
          "delay": 7.1788,
          "n": 274
        },
        {
          "delay": -3.2,
          "n": 20
        },
        {
          "delay": -8.4,
          "n": 5
        },
        {
          "delay": 1.432,
          "n": 125
        },
        {
          "delay": 8.8148,
          "n": 27
        },
        {
          "delay": -14,
          "n": 1
        },
        {
          "delay": 7.1103,
          "n": 272
        },
        {
          "delay": 0.5556,
          "n": 18
        },
        {
          "delay": 15.5,
          "n": 10
        },
        {
          "delay": 8.7444,
          "n": 133
        },
        {
          "delay": 10.3636,
          "n": 11
        },
        {
          "delay": 1,
          "n": 1
        },
        {
          "delay": 41.6429,
          "n": 14
        },
        {
          "delay": -10,
          "n": 7
        },
        {
          "delay": -0.9067,
          "n": 150
        },
        {
          "delay": -5,
          "n": 1
        },
        {
          "delay": -0.7308,
          "n": 52
        },
        {
          "delay": 6.3047,
          "n": 233
        },
        {
          "delay": 14.6512,
          "n": 43
        },
        {
          "delay": -4.2,
          "n": 5
        },
        {
          "delay": 7.5345,
          "n": 116
        },
        {
          "delay": 2.9062,
          "n": 32
        },
        {
          "delay": 54.5,
          "n": 2
        },
        {
          "delay": 20.5,
          "n": 26
        },
        {
          "delay": 2.2,
          "n": 5
        },
        {
          "delay": 9.6154,
          "n": 143
        },
        {
          "delay": 9.962,
          "n": 263
        },
        {
          "delay": 21,
          "n": 20
        },
        {
          "delay": 11.25,
          "n": 4
        },
        {
          "delay": 8.344,
          "n": 125
        },
        {
          "delay": 7.8444,
          "n": 45
        },
        {
          "delay": 4.8792,
          "n": 298
        },
        {
          "delay": 32.1304,
          "n": 23
        },
        {
          "delay": 6.752,
          "n": 125
        },
        {
          "delay": 43.5,
          "n": 6
        },
        {
          "delay": -0.5333,
          "n": 45
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 16.2258,
          "n": 31
        },
        {
          "delay": 12.2878,
          "n": 139
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": 7.1754,
          "n": 268
        },
        {
          "delay": 17.9474,
          "n": 19
        },
        {
          "delay": 58.4286,
          "n": 7
        },
        {
          "delay": 3.2818,
          "n": 110
        },
        {
          "delay": -0.625,
          "n": 24
        },
        {
          "delay": 136,
          "n": 1
        },
        {
          "delay": 5.5846,
          "n": 65
        },
        {
          "delay": 8.2474,
          "n": 291
        },
        {
          "delay": 7.4286,
          "n": 14
        },
        {
          "delay": 2.2222,
          "n": 9
        },
        {
          "delay": 9.2403,
          "n": 129
        },
        {
          "delay": 27.9143,
          "n": 35
        },
        {
          "delay": 10.8065,
          "n": 279
        },
        {
          "delay": 29.9375,
          "n": 16
        },
        {
          "delay": 20.5,
          "n": 2
        },
        {
          "delay": 6.8189,
          "n": 127
        },
        {
          "delay": 18.8966,
          "n": 29
        },
        {
          "delay": -2.6984,
          "n": 63
        },
        {
          "delay": 8.367,
          "n": 267
        },
        {
          "delay": 7.5,
          "n": 32
        },
        {
          "delay": 32.2,
          "n": 5
        },
        {
          "delay": 7.1119,
          "n": 143
        },
        {
          "delay": -3.4091,
          "n": 22
        },
        {
          "delay": 9.7453,
          "n": 267
        },
        {
          "delay": 12.7391,
          "n": 46
        },
        {
          "delay": -0.3403,
          "n": 144
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": -8.8462,
          "n": 26
        },
        {
          "delay": 10.6678,
          "n": 283
        },
        {
          "delay": 4.9333,
          "n": 30
        },
        {
          "delay": -5.3333,
          "n": 3
        },
        {
          "delay": -1.1972,
          "n": 142
        },
        {
          "delay": -2.375,
          "n": 16
        },
        {
          "delay": -4.25,
          "n": 24
        },
        {
          "delay": 10.4033,
          "n": 243
        },
        {
          "delay": 6.587,
          "n": 46
        },
        {
          "delay": -13.3333,
          "n": 3
        },
        {
          "delay": 3.3484,
          "n": 155
        },
        {
          "delay": 9.8148,
          "n": 27
        },
        {
          "delay": 1.9583,
          "n": 24
        },
        {
          "delay": 5.53,
          "n": 283
        },
        {
          "delay": 13.8621,
          "n": 29
        },
        {
          "delay": 21.6,
          "n": 5
        },
        {
          "delay": 10.2743,
          "n": 113
        },
        {
          "delay": 11.7857,
          "n": 28
        },
        {
          "delay": -0.963,
          "n": 54
        },
        {
          "delay": -14.6923,
          "n": 13
        },
        {
          "delay": 12.6172,
          "n": 256
        },
        {
          "delay": 2.5789,
          "n": 19
        },
        {
          "delay": -20.3333,
          "n": 3
        },
        {
          "delay": -1,
          "n": 132
        },
        {
          "delay": 10.8235,
          "n": 34
        },
        {
          "delay": 7.8559,
          "n": 229
        },
        {
          "delay": 7.9474,
          "n": 38
        },
        {
          "delay": -2,
          "n": 5
        },
        {
          "delay": 6,
          "n": 1
        },
        {
          "delay": 2.2303,
          "n": 152
        },
        {
          "delay": 9.4839,
          "n": 31
        },
        {
          "delay": 2.5,
          "n": 44
        },
        {
          "delay": 4.7586,
          "n": 58
        },
        {
          "delay": -0.4737,
          "n": 19
        },
        {
          "delay": 6.1119,
          "n": 143
        },
        {
          "delay": 15,
          "n": 10
        },
        {
          "delay": -2.5312,
          "n": 32
        },
        {
          "delay": 10.48,
          "n": 250
        },
        {
          "delay": 1.2692,
          "n": 26
        },
        {
          "delay": -11.4,
          "n": 5
        },
        {
          "delay": 11.1786,
          "n": 28
        },
        {
          "delay": 11.8284,
          "n": 268
        },
        {
          "delay": 3.5417,
          "n": 48
        },
        {
          "delay": 20,
          "n": 4
        },
        {
          "delay": 56,
          "n": 2
        },
        {
          "delay": 2.5833,
          "n": 24
        },
        {
          "delay": 3.7158,
          "n": 278
        },
        {
          "delay": 51,
          "n": 24
        },
        {
          "delay": 26.6667,
          "n": 3
        },
        {
          "delay": 2.2182,
          "n": 55
        },
        {
          "delay": 5.0039,
          "n": 257
        },
        {
          "delay": 28.5,
          "n": 2
        },
        {
          "delay": 15.1667,
          "n": 6
        },
        {
          "delay": -9.5,
          "n": 2
        },
        {
          "delay": -0.7308,
          "n": 52
        },
        {
          "delay": -13.6452,
          "n": 31
        },
        {
          "delay": 5,
          "n": 1
        },
        {
          "delay": 3.5,
          "n": 4
        },
        {
          "delay": -17,
          "n": 1
        },
        {
          "delay": -10.75,
          "n": 4
        },
        {
          "delay": -1.2121,
          "n": 66
        },
        {
          "delay": 5.7179,
          "n": 39
        },
        {
          "delay": 8.5194,
          "n": 258
        },
        {
          "delay": 7.9062,
          "n": 32
        },
        {
          "delay": 15,
          "n": 2
        },
        {
          "delay": 53,
          "n": 1
        },
        {
          "delay": 17.9508,
          "n": 61
        },
        {
          "delay": -1.5,
          "n": 28
        },
        {
          "delay": 7.2115,
          "n": 279
        },
        {
          "delay": 34.5263,
          "n": 19
        },
        {
          "delay": -3.25,
          "n": 4
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": 5.1731,
          "n": 52
        },
        {
          "delay": 3.7917,
          "n": 24
        },
        {
          "delay": 15.425,
          "n": 40
        },
        {
          "delay": -14.6667,
          "n": 3
        },
        {
          "delay": 4.3478,
          "n": 69
        },
        {
          "delay": 21.4348,
          "n": 23
        },
        {
          "delay": 7.5808,
          "n": 260
        },
        {
          "delay": 9.7931,
          "n": 29
        },
        {
          "delay": -5,
          "n": 7
        },
        {
          "delay": 7,
          "n": 1
        },
        {
          "delay": 0.0476,
          "n": 63
        },
        {
          "delay": 8.5625,
          "n": 32
        },
        {
          "delay": 4.7395,
          "n": 261
        },
        {
          "delay": 0.0909,
          "n": 11
        },
        {
          "delay": 75.3333,
          "n": 6
        },
        {
          "delay": 16.5,
          "n": 2
        },
        {
          "delay": -0.0526,
          "n": 76
        },
        {
          "delay": 8.6667,
          "n": 291
        },
        {
          "delay": -3.7273,
          "n": 11
        },
        {
          "delay": 13.4286,
          "n": 7
        },
        {
          "delay": 27,
          "n": 1
        },
        {
          "delay": -2.3871,
          "n": 62
        },
        {
          "delay": 0.4,
          "n": 40
        },
        {
          "delay": 12.3333,
          "n": 3
        },
        {
          "delay": 7.2,
          "n": 5
        },
        {
          "delay": 185,
          "n": 1
        },
        {
          "delay": 4.9429,
          "n": 70
        },
        {
          "delay": -5.4634,
          "n": 41
        },
        {
          "delay": 7.2446,
          "n": 278
        },
        {
          "delay": 19.0357,
          "n": 28
        },
        {
          "delay": 6,
          "n": 1
        },
        {
          "delay": 5.5,
          "n": 4
        },
        {
          "delay": 7.7222,
          "n": 72
        },
        {
          "delay": 10.4797,
          "n": 271
        },
        {
          "delay": 5.4118,
          "n": 34
        },
        {
          "delay": -0.6667,
          "n": 3
        },
        {
          "delay": -9.8,
          "n": 5
        },
        {
          "delay": 4.1127,
          "n": 71
        },
        {
          "delay": 5.0318,
          "n": 283
        },
        {
          "delay": 38.5,
          "n": 36
        },
        {
          "delay": -3.5,
          "n": 2
        },
        {
          "delay": 71,
          "n": 1
        },
        {
          "delay": 7.5152,
          "n": 66
        },
        {
          "delay": 0.6154,
          "n": 39
        },
        {
          "delay": 6.4737,
          "n": 285
        },
        {
          "delay": 23.7273,
          "n": 22
        },
        {
          "delay": 13.8,
          "n": 5
        },
        {
          "delay": 2.6667,
          "n": 3
        },
        {
          "delay": -1.8947,
          "n": 57
        },
        {
          "delay": 4.2692,
          "n": 78
        },
        {
          "delay": 5.6162,
          "n": 271
        },
        {
          "delay": 7.5758,
          "n": 33
        },
        {
          "delay": -0.6,
          "n": 5
        },
        {
          "delay": 2,
          "n": 3
        },
        {
          "delay": 16.5588,
          "n": 34
        },
        {
          "delay": 8.7,
          "n": 30
        },
        {
          "delay": 12.9487,
          "n": 39
        },
        {
          "delay": 3.7931,
          "n": 58
        },
        {
          "delay": 11.5926,
          "n": 54
        },
        {
          "delay": 6.225,
          "n": 40
        },
        {
          "delay": 6,
          "n": 1
        },
        {
          "delay": 25.3333,
          "n": 3
        },
        {
          "delay": 10.28,
          "n": 50
        },
        {
          "delay": -3.1489,
          "n": 47
        },
        {
          "delay": 10.1637,
          "n": 281
        },
        {
          "delay": 7.9412,
          "n": 17
        },
        {
          "delay": -17,
          "n": 1
        },
        {
          "delay": 3.2576,
          "n": 66
        },
        {
          "delay": 6.5536,
          "n": 56
        },
        {
          "delay": 14.126,
          "n": 254
        },
        {
          "delay": 33,
          "n": 5
        },
        {
          "delay": 34.6,
          "n": 5
        },
        {
          "delay": -0.9242,
          "n": 66
        },
        {
          "delay": 5.5541,
          "n": 74
        },
        {
          "delay": 5.6111,
          "n": 270
        },
        {
          "delay": 24.2,
          "n": 25
        },
        {
          "delay": -22,
          "n": 3
        },
        {
          "delay": 18.75,
          "n": 4
        },
        {
          "delay": 1.5294,
          "n": 51
        },
        {
          "delay": 3.3649,
          "n": 74
        },
        {
          "delay": -3.75,
          "n": 8
        },
        {
          "delay": 16.05,
          "n": 20
        },
        {
          "delay": -6.2449,
          "n": 49
        },
        {
          "delay": 0.5195,
          "n": 77
        },
        {
          "delay": 11.2934,
          "n": 242
        },
        {
          "delay": 174.6667,
          "n": 6
        },
        {
          "delay": 16.2727,
          "n": 11
        },
        {
          "delay": -0.1429,
          "n": 7
        },
        {
          "delay": -1.4677,
          "n": 62
        },
        {
          "delay": 17.3636,
          "n": 11
        },
        {
          "delay": 3.4746,
          "n": 59
        },
        {
          "delay": 8.8987,
          "n": 79
        },
        {
          "delay": 1.4,
          "n": 20
        },
        {
          "delay": 30.28,
          "n": 25
        },
        {
          "delay": 2.0833,
          "n": 12
        },
        {
          "delay": 5.625,
          "n": 16
        },
        {
          "delay": 0.3485,
          "n": 66
        },
        {
          "delay": 2.625,
          "n": 48
        },
        {
          "delay": 9.65,
          "n": 20
        },
        {
          "delay": 38.8889,
          "n": 18
        },
        {
          "delay": 13.4231,
          "n": 52
        },
        {
          "delay": -4.5294,
          "n": 68
        },
        {
          "delay": 18.8125,
          "n": 16
        },
        {
          "delay": -22,
          "n": 1
        },
        {
          "delay": 12.5294,
          "n": 17
        },
        {
          "delay": -0.0667,
          "n": 30
        },
        {
          "delay": -5.25,
          "n": 44
        },
        {
          "delay": 1.6667,
          "n": 33
        },
        {
          "delay": 0.7632,
          "n": 38
        },
        {
          "delay": 10.5714,
          "n": 28
        },
        {
          "delay": 0.8696,
          "n": 23
        },
        {
          "delay": 5.0278,
          "n": 36
        },
        {
          "delay": 1.3103,
          "n": 29
        },
        {
          "delay": -8.1579,
          "n": 19
        },
        {
          "delay": -7.2703,
          "n": 37
        },
        {
          "delay": -7.3056,
          "n": 36
        },
        {
          "delay": 0.8148,
          "n": 27
        },
        {
          "delay": -5.7833,
          "n": 60
        },
        {
          "delay": 0.75,
          "n": 8
        },
        {
          "delay": 7,
          "n": 2
        },
        {
          "delay": 2.7407,
          "n": 27
        },
        {
          "delay": 120,
          "n": 1
        },
        {
          "delay": -6.5758,
          "n": 33
        },
        {
          "delay": 5.0323,
          "n": 31
        },
        {
          "delay": 5.7619,
          "n": 42
        },
        {
          "delay": 2.7097,
          "n": 93
        },
        {
          "delay": 3.1905,
          "n": 21
        },
        {
          "delay": 12.7143,
          "n": 21
        },
        {
          "delay": -1.4815,
          "n": 27
        },
        {
          "delay": 40.32,
          "n": 25
        },
        {
          "delay": 22.1875,
          "n": 32
        },
        {
          "delay": 9.7627,
          "n": 59
        },
        {
          "delay": 0.9677,
          "n": 31
        },
        {
          "delay": 27.0526,
          "n": 19
        },
        {
          "delay": 3.0169,
          "n": 59
        },
        {
          "delay": 3.746,
          "n": 63
        },
        {
          "delay": -0.1364,
          "n": 22
        },
        {
          "delay": 20.1176,
          "n": 17
        },
        {
          "delay": -0.2466,
          "n": 73
        },
        {
          "delay": 7.16,
          "n": 50
        },
        {
          "delay": 20.9444,
          "n": 18
        },
        {
          "delay": 39.9375,
          "n": 16
        },
        {
          "delay": 3.4416,
          "n": 77
        },
        {
          "delay": -4,
          "n": 3
        },
        {
          "delay": 25.2632,
          "n": 19
        },
        {
          "delay": 5.9833,
          "n": 60
        },
        {
          "delay": 2.3607,
          "n": 61
        },
        {
          "delay": -7.6,
          "n": 5
        },
        {
          "delay": 18.8261,
          "n": 23
        },
        {
          "delay": 1.12,
          "n": 25
        },
        {
          "delay": 1.8846,
          "n": 78
        },
        {
          "delay": 10.7353,
          "n": 34
        },
        {
          "delay": -0.78,
          "n": 50
        },
        {
          "delay": -5.0909,
          "n": 11
        },
        {
          "delay": 3.5,
          "n": 12
        },
        {
          "delay": 2.8261,
          "n": 69
        },
        {
          "delay": 6.1071,
          "n": 28
        },
        {
          "delay": -1.0526,
          "n": 19
        },
        {
          "delay": 6.7241,
          "n": 58
        },
        {
          "delay": 3.0968,
          "n": 31
        },
        {
          "delay": -1.3617,
          "n": 47
        },
        {
          "delay": 14.0769,
          "n": 13
        },
        {
          "delay": 0.025,
          "n": 40
        },
        {
          "delay": 0.1493,
          "n": 67
        },
        {
          "delay": 15.8333,
          "n": 36
        },
        {
          "delay": 5.4545,
          "n": 22
        },
        {
          "delay": -3.4545,
          "n": 55
        },
        {
          "delay": 2.9444,
          "n": 72
        },
        {
          "delay": 0.1935,
          "n": 31
        },
        {
          "delay": 7,
          "n": 5
        },
        {
          "delay": 20.375,
          "n": 8
        },
        {
          "delay": -2.1613,
          "n": 31
        },
        {
          "delay": 5.6154,
          "n": 26
        },
        {
          "delay": 19.3333,
          "n": 18
        },
        {
          "delay": 33.2333,
          "n": 30
        },
        {
          "delay": 5,
          "n": 3
        },
        {
          "delay": -12.8667,
          "n": 15
        },
        {
          "delay": -8.7143,
          "n": 28
        },
        {
          "delay": 3.7245,
          "n": 98
        },
        {
          "delay": 0.301,
          "n": 103
        },
        {
          "delay": 6.2286,
          "n": 35
        },
        {
          "delay": 24.35,
          "n": 20
        },
        {
          "delay": 34.1429,
          "n": 7
        },
        {
          "delay": 18.6,
          "n": 35
        },
        {
          "delay": 1.0435,
          "n": 23
        },
        {
          "delay": 24.4,
          "n": 5
        },
        {
          "delay": -0.7727,
          "n": 44
        },
        {
          "delay": 19.8667,
          "n": 15
        },
        {
          "delay": 9.8889,
          "n": 81
        },
        {
          "delay": 13.4,
          "n": 30
        },
        {
          "delay": 5.6,
          "n": 5
        },
        {
          "delay": 5.3889,
          "n": 18
        },
        {
          "delay": -10,
          "n": 13
        },
        {
          "delay": 12.5333,
          "n": 15
        },
        {
          "delay": -6.6667,
          "n": 6
        },
        {
          "delay": -5.9851,
          "n": 67
        },
        {
          "delay": 8.6897,
          "n": 29
        },
        {
          "delay": 8.3548,
          "n": 62
        },
        {
          "delay": 22.2,
          "n": 20
        },
        {
          "delay": 8.8857,
          "n": 35
        },
        {
          "delay": 4.125,
          "n": 32
        },
        {
          "delay": 4.7937,
          "n": 63
        },
        {
          "delay": 6.48,
          "n": 25
        },
        {
          "delay": 9.0833,
          "n": 12
        },
        {
          "delay": 17.2593,
          "n": 27
        },
        {
          "delay": 14,
          "n": 12
        },
        {
          "delay": 18.8571,
          "n": 7
        },
        {
          "delay": 4,
          "n": 45
        },
        {
          "delay": 0,
          "n": 20
        },
        {
          "delay": -24,
          "n": 1
        },
        {
          "delay": -1.5,
          "n": 38
        },
        {
          "delay": 10.2941,
          "n": 17
        },
        {
          "delay": 0,
          "n": 2
        },
        {
          "delay": 5.1053,
          "n": 38
        },
        {
          "delay": 13.6579,
          "n": 38
        },
        {
          "delay": -5,
          "n": 2
        },
        {
          "delay": 11.1707,
          "n": 41
        },
        {
          "delay": 11.087,
          "n": 46
        },
        {
          "delay": 8.5806,
          "n": 31
        },
        {
          "delay": -3.7742,
          "n": 31
        },
        {
          "delay": 12.0714,
          "n": 14
        },
        {
          "delay": 21.7778,
          "n": 36
        },
        {
          "delay": -12.6667,
          "n": 3
        },
        {
          "delay": 22.75,
          "n": 8
        },
        {
          "delay": 0.4815,
          "n": 27
        },
        {
          "delay": -6.9412,
          "n": 17
        },
        {
          "delay": 7.25,
          "n": 12
        },
        {
          "delay": 11.3922,
          "n": 51
        },
        {
          "delay": 3.64,
          "n": 25
        },
        {
          "delay": 14.0476,
          "n": 21
        },
        {
          "delay": 11.5988,
          "n": 334
        },
        {
          "delay": 12.5,
          "n": 42
        },
        {
          "delay": -3.16,
          "n": 50
        },
        {
          "delay": 4.4091,
          "n": 22
        },
        {
          "delay": -26,
          "n": 1
        },
        {
          "delay": 4.6,
          "n": 60
        },
        {
          "delay": 48,
          "n": 1
        },
        {
          "delay": -2.7526,
          "n": 194
        },
        {
          "delay": 7.16,
          "n": 100
        },
        {
          "delay": 7.6486,
          "n": 276
        },
        {
          "delay": 6.7586,
          "n": 29
        },
        {
          "delay": -3.0258,
          "n": 194
        },
        {
          "delay": 9.2034,
          "n": 59
        },
        {
          "delay": 5.0741,
          "n": 27
        },
        {
          "delay": 5.2361,
          "n": 72
        },
        {
          "delay": -5.1515,
          "n": 198
        },
        {
          "delay": 5.2457,
          "n": 289
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 11.2727,
          "n": 22
        },
        {
          "delay": -7.0856,
          "n": 292
        },
        {
          "delay": -1.8906,
          "n": 64
        },
        {
          "delay": 14.5524,
          "n": 286
        },
        {
          "delay": 20.1739,
          "n": 23
        },
        {
          "delay": -9.2785,
          "n": 219
        },
        {
          "delay": 4.1604,
          "n": 106
        },
        {
          "delay": 7.7391,
          "n": 23
        },
        {
          "delay": -6.3547,
          "n": 234
        },
        {
          "delay": 0.5905,
          "n": 210
        },
        {
          "delay": 8.5126,
          "n": 238
        },
        {
          "delay": -11.875,
          "n": 16
        },
        {
          "delay": -0.3059,
          "n": 85
        },
        {
          "delay": 11.1256,
          "n": 207
        },
        {
          "delay": 8.7663,
          "n": 261
        },
        {
          "delay": 24.9615,
          "n": 26
        },
        {
          "delay": -4.6154,
          "n": 221
        },
        {
          "delay": 7.1,
          "n": 60
        },
        {
          "delay": 11.078,
          "n": 205
        },
        {
          "delay": -14,
          "n": 1
        },
        {
          "delay": 3.0345,
          "n": 29
        },
        {
          "delay": -5.0594,
          "n": 219
        },
        {
          "delay": -2.5,
          "n": 54
        },
        {
          "delay": 28.9524,
          "n": 21
        },
        {
          "delay": 6.29,
          "n": 462
        },
        {
          "delay": 8.3333,
          "n": 66
        },
        {
          "delay": -7.4276,
          "n": 290
        },
        {
          "delay": 10.8693,
          "n": 199
        },
        {
          "delay": 12.5425,
          "n": 247
        },
        {
          "delay": 19.5385,
          "n": 26
        },
        {
          "delay": -8.3231,
          "n": 195
        },
        {
          "delay": -1.4194,
          "n": 93
        },
        {
          "delay": 4.1733,
          "n": 225
        },
        {
          "delay": 6.8174,
          "n": 449
        },
        {
          "delay": 19.2381,
          "n": 21
        },
        {
          "delay": -6.7297,
          "n": 296
        },
        {
          "delay": 7.2712,
          "n": 59
        },
        {
          "delay": -3.0127,
          "n": 79
        },
        {
          "delay": 25.5789,
          "n": 19
        },
        {
          "delay": 1.2561,
          "n": 82
        },
        {
          "delay": 8.5306,
          "n": 245
        },
        {
          "delay": 9.1667,
          "n": 30
        },
        {
          "delay": 8.7738,
          "n": 84
        },
        {
          "delay": 8.325,
          "n": 200
        },
        {
          "delay": 15.4483,
          "n": 29
        },
        {
          "delay": 3.12,
          "n": 75
        },
        {
          "delay": 9.3679,
          "n": 212
        },
        {
          "delay": 35.25,
          "n": 32
        },
        {
          "delay": 3.443,
          "n": 228
        },
        {
          "delay": 10.7619,
          "n": 21
        },
        {
          "delay": -3.2778,
          "n": 270
        },
        {
          "delay": -1.2949,
          "n": 78
        },
        {
          "delay": 13.4693,
          "n": 179
        },
        {
          "delay": 7,
          "n": 22
        },
        {
          "delay": -7.1626,
          "n": 326
        },
        {
          "delay": 2.7405,
          "n": 158
        },
        {
          "delay": 3.2135,
          "n": 178
        },
        {
          "delay": 3.6774,
          "n": 31
        },
        {
          "delay": 0.994,
          "n": 167
        },
        {
          "delay": 6.5113,
          "n": 309
        },
        {
          "delay": 20.1,
          "n": 30
        },
        {
          "delay": 9.9331,
          "n": 314
        },
        {
          "delay": -7.254,
          "n": 315
        },
        {
          "delay": 5.6308,
          "n": 65
        },
        {
          "delay": 13.4605,
          "n": 152
        },
        {
          "delay": 4.9113,
          "n": 485
        },
        {
          "delay": -7.0481,
          "n": 312
        },
        {
          "delay": 8.9474,
          "n": 76
        },
        {
          "delay": 10.0234,
          "n": 171
        },
        {
          "delay": 6.4168,
          "n": 475
        },
        {
          "delay": 5.8276,
          "n": 29
        },
        {
          "delay": -5.3624,
          "n": 287
        },
        {
          "delay": -0.9385,
          "n": 65
        },
        {
          "delay": 2.2584,
          "n": 89
        },
        {
          "delay": 2.8462,
          "n": 195
        },
        {
          "delay": 9.402,
          "n": 199
        },
        {
          "delay": 17.037,
          "n": 27
        },
        {
          "delay": -0.0159,
          "n": 63
        },
        {
          "delay": 4.6728,
          "n": 544
        },
        {
          "delay": -3.6,
          "n": 20
        },
        {
          "delay": 11.1905,
          "n": 63
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": -4.7143,
          "n": 28
        },
        {
          "delay": 12.5625,
          "n": 32
        },
        {
          "delay": -9.6423,
          "n": 274
        },
        {
          "delay": 10.1923,
          "n": 26
        },
        {
          "delay": 6.4064,
          "n": 283
        },
        {
          "delay": 16.8889,
          "n": 27
        },
        {
          "delay": 10.75,
          "n": 204
        },
        {
          "delay": 1.2,
          "n": 165
        },
        {
          "delay": 17.08,
          "n": 25
        },
        {
          "delay": 2.4066,
          "n": 91
        },
        {
          "delay": -3.3333,
          "n": 12
        },
        {
          "delay": 27.4,
          "n": 25
        },
        {
          "delay": 6.7009,
          "n": 107
        },
        {
          "delay": 4.7524,
          "n": 105
        },
        {
          "delay": 7.2348,
          "n": 115
        },
        {
          "delay": 4.1154,
          "n": 104
        },
        {
          "delay": 6.7105,
          "n": 114
        },
        {
          "delay": 1.2719,
          "n": 114
        },
        {
          "delay": -2.6139,
          "n": 101
        },
        {
          "delay": 4.4273,
          "n": 110
        },
        {
          "delay": 0.7042,
          "n": 142
        },
        {
          "delay": 1.9474,
          "n": 95
        },
        {
          "delay": 10.4815,
          "n": 27
        },
        {
          "delay": 0.5,
          "n": 86
        },
        {
          "delay": 11.9583,
          "n": 24
        },
        {
          "delay": 3.5455,
          "n": 55
        },
        {
          "delay": -3.2,
          "n": 80
        },
        {
          "delay": 0.3115,
          "n": 122
        },
        {
          "delay": 8.3607,
          "n": 122
        },
        {
          "delay": 3.9286,
          "n": 28
        },
        {
          "delay": 2.5095,
          "n": 367
        },
        {
          "delay": 20.069,
          "n": 29
        },
        {
          "delay": 10.891,
          "n": 156
        },
        {
          "delay": 5.8571,
          "n": 28
        },
        {
          "delay": 2.8,
          "n": 30
        },
        {
          "delay": 3.451,
          "n": 153
        },
        {
          "delay": 13.3176,
          "n": 85
        },
        {
          "delay": 22.4,
          "n": 5
        },
        {
          "delay": 9.5,
          "n": 28
        },
        {
          "delay": 9.868,
          "n": 197
        },
        {
          "delay": 5.2358,
          "n": 318
        },
        {
          "delay": 9.4308,
          "n": 65
        },
        {
          "delay": 30,
          "n": 20
        },
        {
          "delay": 3.8148,
          "n": 135
        },
        {
          "delay": 7.6055,
          "n": 218
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 6.0769,
          "n": 26
        },
        {
          "delay": 5.2241,
          "n": 58
        },
        {
          "delay": 1.7604,
          "n": 192
        },
        {
          "delay": 16.8125,
          "n": 32
        },
        {
          "delay": 6.5758,
          "n": 66
        },
        {
          "delay": 5.0226,
          "n": 177
        },
        {
          "delay": -1.2222,
          "n": 18
        },
        {
          "delay": 0.1923,
          "n": 26
        },
        {
          "delay": 13.2965,
          "n": 172
        },
        {
          "delay": 2.4106,
          "n": 151
        },
        {
          "delay": 3.963,
          "n": 27
        },
        {
          "delay": 2.5652,
          "n": 23
        },
        {
          "delay": 8.2787,
          "n": 183
        },
        {
          "delay": 6.7042,
          "n": 311
        },
        {
          "delay": 3,
          "n": 1
        },
        {
          "delay": 3.7083,
          "n": 24
        },
        {
          "delay": 8.5227,
          "n": 132
        },
        {
          "delay": 20.9062,
          "n": 32
        },
        {
          "delay": 0.1193,
          "n": 176
        },
        {
          "delay": 13.0278,
          "n": 36
        },
        {
          "delay": 9.8756,
          "n": 201
        },
        {
          "delay": -5.6,
          "n": 20
        },
        {
          "delay": 1.8232,
          "n": 181
        },
        {
          "delay": 13.2105,
          "n": 19
        },
        {
          "delay": 5.8667,
          "n": 135
        },
        {
          "delay": -23,
          "n": 1
        },
        {
          "delay": 13.704,
          "n": 223
        },
        {
          "delay": 7.8214,
          "n": 28
        },
        {
          "delay": 5.911,
          "n": 146
        },
        {
          "delay": 10.7857,
          "n": 196
        },
        {
          "delay": 13.9062,
          "n": 32
        },
        {
          "delay": 9.9408,
          "n": 152
        },
        {
          "delay": 9.645,
          "n": 200
        },
        {
          "delay": 8.8333,
          "n": 24
        },
        {
          "delay": 4.0787,
          "n": 127
        },
        {
          "delay": 6.428,
          "n": 236
        },
        {
          "delay": 3.7083,
          "n": 24
        },
        {
          "delay": 3.5678,
          "n": 118
        },
        {
          "delay": -2.2603,
          "n": 73
        },
        {
          "delay": -1.0617,
          "n": 81
        },
        {
          "delay": 4.7831,
          "n": 83
        },
        {
          "delay": 5.3962,
          "n": 106
        },
        {
          "delay": 5.9451,
          "n": 91
        },
        {
          "delay": 4.5294,
          "n": 102
        },
        {
          "delay": 1.8991,
          "n": 109
        },
        {
          "delay": 4.9438,
          "n": 89
        },
        {
          "delay": -4.1032,
          "n": 126
        },
        {
          "delay": 2.21,
          "n": 219
        },
        {
          "delay": 8.6286,
          "n": 35
        },
        {
          "delay": 7,
          "n": 133
        },
        {
          "delay": 9.3138,
          "n": 188
        },
        {
          "delay": -4.2667,
          "n": 30
        },
        {
          "delay": 5.8696,
          "n": 138
        },
        {
          "delay": 5.25,
          "n": 32
        },
        {
          "delay": 6.5217,
          "n": 138
        },
        {
          "delay": -24,
          "n": 1
        },
        {
          "delay": 32.2174,
          "n": 23
        },
        {
          "delay": 4.3116,
          "n": 138
        },
        {
          "delay": 15.1081,
          "n": 37
        },
        {
          "delay": 12.6098,
          "n": 41
        },
        {
          "delay": 7.7188,
          "n": 32
        },
        {
          "delay": 12.186,
          "n": 43
        },
        {
          "delay": 25.3846,
          "n": 13
        },
        {
          "delay": 18.3018,
          "n": 169
        },
        {
          "delay": 14.3846,
          "n": 39
        },
        {
          "delay": 10.3071,
          "n": 127
        },
        {
          "delay": 3.2571,
          "n": 245
        },
        {
          "delay": -1.7241,
          "n": 29
        },
        {
          "delay": -5.3571,
          "n": 28
        },
        {
          "delay": -2,
          "n": 32
        },
        {
          "delay": -1.12,
          "n": 25
        },
        {
          "delay": 13.2093,
          "n": 43
        },
        {
          "delay": 9.7636,
          "n": 55
        },
        {
          "delay": 10.324,
          "n": 179
        },
        {
          "delay": 11.2433,
          "n": 300
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": 2.9259,
          "n": 27
        },
        {
          "delay": 5.4161,
          "n": 149
        },
        {
          "delay": -1.3333,
          "n": 12
        },
        {
          "delay": 7.7402,
          "n": 127
        },
        {
          "delay": 21.0833,
          "n": 36
        },
        {
          "delay": -1.9375,
          "n": 128
        },
        {
          "delay": 6.8067,
          "n": 119
        },
        {
          "delay": 1.9778,
          "n": 135
        },
        {
          "delay": 4.8257,
          "n": 109
        },
        {
          "delay": -8,
          "n": 15
        },
        {
          "delay": 69,
          "n": 1
        },
        {
          "delay": 5.9487,
          "n": 39
        },
        {
          "delay": 3.4826,
          "n": 201
        },
        {
          "delay": 6.485,
          "n": 266
        },
        {
          "delay": 11.1852,
          "n": 27
        },
        {
          "delay": 1.2119,
          "n": 118
        },
        {
          "delay": 8.5455,
          "n": 11
        },
        {
          "delay": 17.6923,
          "n": 26
        },
        {
          "delay": 3.985,
          "n": 133
        },
        {
          "delay": 5.5567,
          "n": 97
        },
        {
          "delay": 3.8889,
          "n": 117
        },
        {
          "delay": 6.8682,
          "n": 129
        },
        {
          "delay": 3.5981,
          "n": 107
        },
        {
          "delay": -2.9091,
          "n": 121
        },
        {
          "delay": -5.299,
          "n": 97
        },
        {
          "delay": 7.5133,
          "n": 113
        },
        {
          "delay": 6.4677,
          "n": 124
        },
        {
          "delay": -1.5046,
          "n": 109
        },
        {
          "delay": 4.075,
          "n": 120
        },
        {
          "delay": 4.1393,
          "n": 122
        },
        {
          "delay": 5.7807,
          "n": 114
        },
        {
          "delay": 1.0609,
          "n": 115
        },
        {
          "delay": 4.1417,
          "n": 120
        },
        {
          "delay": 7.984,
          "n": 125
        },
        {
          "delay": 6.6562,
          "n": 32
        },
        {
          "delay": 2.7727,
          "n": 132
        },
        {
          "delay": 10.1505,
          "n": 279
        },
        {
          "delay": -14.5714,
          "n": 14
        },
        {
          "delay": -24,
          "n": 1
        },
        {
          "delay": 8.6176,
          "n": 34
        },
        {
          "delay": 2.0143,
          "n": 140
        },
        {
          "delay": 16.7273,
          "n": 22
        },
        {
          "delay": 17.2143,
          "n": 28
        },
        {
          "delay": 5.4245,
          "n": 139
        },
        {
          "delay": 5.9744,
          "n": 273
        },
        {
          "delay": 15,
          "n": 32
        },
        {
          "delay": 0.8267,
          "n": 150
        },
        {
          "delay": 10.9667,
          "n": 30
        },
        {
          "delay": 5.227,
          "n": 163
        },
        {
          "delay": 4,
          "n": 1
        },
        {
          "delay": 19.8611,
          "n": 36
        },
        {
          "delay": 3.6471,
          "n": 34
        },
        {
          "delay": 4.2,
          "n": 45
        },
        {
          "delay": 1.8333,
          "n": 6
        },
        {
          "delay": 7.9643,
          "n": 28
        },
        {
          "delay": 4.5301,
          "n": 166
        },
        {
          "delay": 24,
          "n": 1
        },
        {
          "delay": 16.96,
          "n": 25
        },
        {
          "delay": 188,
          "n": 1
        },
        {
          "delay": 23.2,
          "n": 25
        },
        {
          "delay": 9.75,
          "n": 12
        },
        {
          "delay": 3.0273,
          "n": 110
        },
        {
          "delay": -0.5922,
          "n": 103
        },
        {
          "delay": 9.8966,
          "n": 29
        },
        {
          "delay": 6.6508,
          "n": 126
        },
        {
          "delay": 3.3934,
          "n": 122
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 13.5217,
          "n": 23
        },
        {
          "delay": 7.5357,
          "n": 28
        },
        {
          "delay": 9.6774,
          "n": 31
        },
        {
          "delay": 31,
          "n": 37
        },
        {
          "delay": 14.4667,
          "n": 30
        },
        {
          "delay": 8.25,
          "n": 24
        },
        {
          "delay": 10.3659,
          "n": 41
        },
        {
          "delay": 7.0909,
          "n": 11
        },
        {
          "delay": 4.5652,
          "n": 23
        },
        {
          "delay": 13.5667,
          "n": 30
        },
        {
          "delay": 31.8333,
          "n": 18
        },
        {
          "delay": -0.2946,
          "n": 112
        },
        {
          "delay": 8.7576,
          "n": 99
        },
        {
          "delay": -5,
          "n": 5
        },
        {
          "delay": 14.6111,
          "n": 18
        },
        {
          "delay": -13.3333,
          "n": 6
        },
        {
          "delay": 7.2917,
          "n": 24
        },
        {
          "delay": 8.0114,
          "n": 88
        },
        {
          "delay": 1.4607,
          "n": 89
        },
        {
          "delay": 4.3636,
          "n": 99
        },
        {
          "delay": -2.8889,
          "n": 108
        },
        {
          "delay": 0.6984,
          "n": 126
        },
        {
          "delay": 8.2903,
          "n": 279
        },
        {
          "delay": 7.5,
          "n": 6
        },
        {
          "delay": 1.4615,
          "n": 26
        },
        {
          "delay": -18,
          "n": 1
        },
        {
          "delay": 29.9474,
          "n": 38
        },
        {
          "delay": 11,
          "n": 10
        },
        {
          "delay": 23.1304,
          "n": 23
        },
        {
          "delay": -29,
          "n": 1
        },
        {
          "delay": -14.625,
          "n": 8
        },
        {
          "delay": 14.375,
          "n": 8
        },
        {
          "delay": -2.7692,
          "n": 13
        },
        {
          "delay": -24,
          "n": 1
        },
        {
          "delay": 3.28,
          "n": 25
        },
        {
          "delay": 8.6308,
          "n": 260
        },
        {
          "delay": 8.3571,
          "n": 14
        },
        {
          "delay": 11.64,
          "n": 25
        },
        {
          "delay": 137,
          "n": 1
        },
        {
          "delay": 32,
          "n": 1
        },
        {
          "delay": -0.4615,
          "n": 26
        },
        {
          "delay": 6.5,
          "n": 14
        },
        {
          "delay": -7,
          "n": 2
        },
        {
          "delay": 15.55,
          "n": 20
        },
        {
          "delay": 10.1176,
          "n": 17
        },
        {
          "delay": 14.7778,
          "n": 9
        },
        {
          "delay": 11.6333,
          "n": 30
        },
        {
          "delay": 6.05,
          "n": 140
        },
        {
          "delay": -7.1765,
          "n": 17
        },
        {
          "delay": 1.4286,
          "n": 35
        },
        {
          "delay": 5,
          "n": 30
        },
        {
          "delay": 0.6058,
          "n": 104
        },
        {
          "delay": 3.5089,
          "n": 112
        },
        {
          "delay": 7.2736,
          "n": 296
        },
        {
          "delay": 3.95,
          "n": 20
        },
        {
          "delay": 7.35,
          "n": 40
        },
        {
          "delay": 8.912,
          "n": 125
        },
        {
          "delay": 1.2321,
          "n": 112
        },
        {
          "delay": 2.3448,
          "n": 116
        },
        {
          "delay": -1.7981,
          "n": 104
        },
        {
          "delay": 3.0686,
          "n": 102
        },
        {
          "delay": -16,
          "n": 1
        },
        {
          "delay": 6.2353,
          "n": 34
        },
        {
          "delay": 27.9167,
          "n": 12
        },
        {
          "delay": 0.5,
          "n": 32
        },
        {
          "delay": -0.2727,
          "n": 11
        },
        {
          "delay": 26.7368,
          "n": 19
        },
        {
          "delay": 12,
          "n": 1
        },
        {
          "delay": 11.5556,
          "n": 9
        },
        {
          "delay": 13.16,
          "n": 25
        },
        {
          "delay": 11.287,
          "n": 331
        },
        {
          "delay": -6,
          "n": 2
        },
        {
          "delay": 9.9655,
          "n": 29
        },
        {
          "delay": 140,
          "n": 1
        },
        {
          "delay": 4.7742,
          "n": 31
        },
        {
          "delay": 21.7241,
          "n": 29
        },
        {
          "delay": 2.1,
          "n": 120
        },
        {
          "delay": -0.8929,
          "n": 28
        },
        {
          "delay": 4.7224,
          "n": 281
        },
        {
          "delay": 1.2647,
          "n": 34
        },
        {
          "delay": 4.3023,
          "n": 86
        },
        {
          "delay": 7.1681,
          "n": 238
        },
        {
          "delay": -16,
          "n": 1
        },
        {
          "delay": 7.2857,
          "n": 21
        },
        {
          "delay": 7.9455,
          "n": 110
        },
        {
          "delay": 6,
          "n": 1
        },
        {
          "delay": 21.8824,
          "n": 34
        },
        {
          "delay": 4.7831,
          "n": 295
        },
        {
          "delay": 10.8611,
          "n": 36
        },
        {
          "delay": 11.2759,
          "n": 29
        },
        {
          "delay": 46,
          "n": 1
        },
        {
          "delay": -3.0526,
          "n": 19
        },
        {
          "delay": -3.9048,
          "n": 21
        },
        {
          "delay": -13,
          "n": 1
        },
        {
          "delay": -22,
          "n": 1
        },
        {
          "delay": 65,
          "n": 1
        },
        {
          "delay": -11,
          "n": 1
        },
        {
          "delay": 62,
          "n": 1
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": -35,
          "n": 1
        },
        {
          "delay": -19.3333,
          "n": 3
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": -21.5,
          "n": 2
        },
        {
          "delay": 19,
          "n": 1
        },
        {
          "delay": -15,
          "n": 1
        },
        {
          "delay": 0,
          "n": 1
        },
        {
          "delay": -25,
          "n": 1
        },
        {
          "delay": 19.3462,
          "n": 52
        },
        {
          "delay": 13.9828,
          "n": 58
        },
        {
          "delay": 10,
          "n": 1
        },
        {
          "delay": -0.1522,
          "n": 46
        },
        {
          "delay": 1.6549,
          "n": 113
        },
        {
          "delay": -16,
          "n": 1
        },
        {
          "delay": 7.8451,
          "n": 71
        },
        {
          "delay": 5.7167,
          "n": 120
        },
        {
          "delay": 11.6604,
          "n": 53
        },
        {
          "delay": -6,
          "n": 1
        },
        {
          "delay": 13.2481,
          "n": 129
        },
        {
          "delay": -13.6667,
          "n": 3
        },
        {
          "delay": -1.8605,
          "n": 215
        },
        {
          "delay": 9.0825,
          "n": 194
        },
        {
          "delay": 3.211,
          "n": 109
        },
        {
          "delay": 4.1887,
          "n": 53
        },
        {
          "delay": 8.0506,
          "n": 237
        },
        {
          "delay": 16.1458,
          "n": 96
        },
        {
          "delay": -2.5508,
          "n": 118
        },
        {
          "delay": 10.3882,
          "n": 255
        },
        {
          "delay": -1.6084,
          "n": 143
        },
        {
          "delay": 1.5603,
          "n": 116
        },
        {
          "delay": -12,
          "n": 2
        },
        {
          "delay": 7.8149,
          "n": 281
        },
        {
          "delay": 10.9684,
          "n": 158
        },
        {
          "delay": 1.1869,
          "n": 107
        },
        {
          "delay": 8.9474,
          "n": 57
        },
        {
          "delay": -1.9402,
          "n": 117
        },
        {
          "delay": -22,
          "n": 1
        },
        {
          "delay": 8.3108,
          "n": 251
        },
        {
          "delay": -19,
          "n": 1
        },
        {
          "delay": 4.0826,
          "n": 121
        },
        {
          "delay": -4,
          "n": 1
        },
        {
          "delay": 8.2787,
          "n": 61
        },
        {
          "delay": 4.2672,
          "n": 131
        },
        {
          "delay": 14.6154,
          "n": 78
        },
        {
          "delay": 10.7381,
          "n": 126
        },
        {
          "delay": -14,
          "n": 1
        },
        {
          "delay": -2.2083,
          "n": 48
        },
        {
          "delay": 7.6897,
          "n": 116
        },
        {
          "delay": 7.5652,
          "n": 115
        },
        {
          "delay": 7.9189,
          "n": 37
        },
        {
          "delay": 5.1677,
          "n": 167
        },
        {
          "delay": 11,
          "n": 2
        },
        {
          "delay": 0.8718,
          "n": 117
        },
        {
          "delay": 6.8393,
          "n": 112
        },
        {
          "delay": -17,
          "n": 2
        },
        {
          "delay": 2.7541,
          "n": 61
        },
        {
          "delay": 6.3218,
          "n": 87
        },
        {
          "delay": 8,
          "n": 1
        },
        {
          "delay": 13.9727,
          "n": 110
        },
        {
          "delay": 2.8333,
          "n": 132
        },
        {
          "delay": 5.6475,
          "n": 122
        },
        {
          "delay": 1.5091,
          "n": 110
        },
        {
          "delay": -10.5,
          "n": 2
        },
        {
          "delay": 1.8671,
          "n": 158
        },
        {
          "delay": -0.312,
          "n": 125
        },
        {
          "delay": 11.0857,
          "n": 70
        },
        {
          "delay": 3.1522,
          "n": 138
        },
        {
          "delay": -16,
          "n": 1
        },
        {
          "delay": 7.4921,
          "n": 63
        },
        {
          "delay": 13.1429,
          "n": 7
        },
        {
          "delay": 8.7589,
          "n": 112
        },
        {
          "delay": 16.2266,
          "n": 203
        },
        {
          "delay": -10,
          "n": 1
        },
        {
          "delay": 17,
          "n": 37
        },
        {
          "delay": 16.9318,
          "n": 44
        },
        {
          "delay": -1.6894,
          "n": 132
        },
        {
          "delay": -20.3333,
          "n": 3
        },
        {
          "delay": 2.3846,
          "n": 39
        },
        {
          "delay": 5.5819,
          "n": 232
        },
        {
          "delay": 5.4043,
          "n": 94
        },
        {
          "delay": 0.7667,
          "n": 120
        },
        {
          "delay": 14.1951,
          "n": 82
        },
        {
          "delay": 7.9545,
          "n": 132
        },
        {
          "delay": 5.1,
          "n": 30
        },
        {
          "delay": 9.3514,
          "n": 37
        },
        {
          "delay": 7.437,
          "n": 135
        },
        {
          "delay": 75,
          "n": 1
        },
        {
          "delay": 26.5,
          "n": 2
        },
        {
          "delay": 1.2955,
          "n": 44
        },
        {
          "delay": 6.4189,
          "n": 74
        },
        {
          "delay": 7.6098,
          "n": 123
        },
        {
          "delay": 9.4891,
          "n": 184
        },
        {
          "delay": -2.5,
          "n": 2
        },
        {
          "delay": 0.2895,
          "n": 38
        },
        {
          "delay": 61.5,
          "n": 2
        },
        {
          "delay": -2.8947,
          "n": 38
        },
        {
          "delay": 1.8727,
          "n": 110
        },
        {
          "delay": 18.3913,
          "n": 184
        },
        {
          "delay": -18,
          "n": 1
        },
        {
          "delay": 5.5,
          "n": 52
        },
        {
          "delay": 42.5,
          "n": 2
        },
        {
          "delay": 12.5,
          "n": 20
        },
        {
          "delay": 19.5583,
          "n": 120
        },
        {
          "delay": 14.6053,
          "n": 190
        },
        {
          "delay": 8,
          "n": 2
        },
        {
          "delay": -13.5,
          "n": 14
        },
        {
          "delay": 5.656,
          "n": 125
        },
        {
          "delay": -27,
          "n": 1
        },
        {
          "delay": 9.4786,
          "n": 117
        },
        {
          "delay": 5.1739,
          "n": 115
        },
        {
          "delay": 19.9795,
          "n": 195
        },
        {
          "delay": 106.5,
          "n": 2
        },
        {
          "delay": -2.1207,
          "n": 58
        },
        {
          "delay": 16.5,
          "n": 2
        },
        {
          "delay": 10.9677,
          "n": 93
        },
        {
          "delay": 1.2692,
          "n": 104
        },
        {
          "delay": 17.1907,
          "n": 215
        },
        {
          "delay": 0.4375,
          "n": 32
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 12.1509,
          "n": 53
        },
        {
          "delay": 7.3761,
          "n": 109
        },
        {
          "delay": 7.7692,
          "n": 13
        },
        {
          "delay": -0.4,
          "n": 10
        },
        {
          "delay": -7.1,
          "n": 10
        },
        {
          "delay": 11.5263,
          "n": 19
        },
        {
          "delay": 1.1538,
          "n": 13
        },
        {
          "delay": -4.5455,
          "n": 11
        },
        {
          "delay": 1.4667,
          "n": 15
        },
        {
          "delay": -2,
          "n": 7
        },
        {
          "delay": 14.4398,
          "n": 166
        },
        {
          "delay": -26,
          "n": 1
        },
        {
          "delay": 1.7273,
          "n": 55
        },
        {
          "delay": 21.3,
          "n": 60
        },
        {
          "delay": 1.4238,
          "n": 151
        },
        {
          "delay": 16,
          "n": 16
        },
        {
          "delay": 1.7857,
          "n": 14
        },
        {
          "delay": -1.4667,
          "n": 15
        },
        {
          "delay": -7.7692,
          "n": 13
        },
        {
          "delay": -1.1818,
          "n": 11
        },
        {
          "delay": 35.7,
          "n": 10
        },
        {
          "delay": 4.7143,
          "n": 14
        },
        {
          "delay": 20.1538,
          "n": 13
        },
        {
          "delay": -4.1579,
          "n": 19
        },
        {
          "delay": -7.6667,
          "n": 9
        },
        {
          "delay": -23.5,
          "n": 2
        },
        {
          "delay": 0.4426,
          "n": 61
        },
        {
          "delay": -7.3333,
          "n": 3
        },
        {
          "delay": -3.1892,
          "n": 37
        },
        {
          "delay": 0.9429,
          "n": 105
        },
        {
          "delay": -9.8,
          "n": 5
        },
        {
          "delay": 9.5455,
          "n": 11
        },
        {
          "delay": -2.7857,
          "n": 14
        },
        {
          "delay": 2.75,
          "n": 4
        },
        {
          "delay": 2.7692,
          "n": 13
        },
        {
          "delay": 28.1538,
          "n": 13
        },
        {
          "delay": 8.5,
          "n": 8
        },
        {
          "delay": -4.4,
          "n": 10
        },
        {
          "delay": 13.6364,
          "n": 11
        },
        {
          "delay": 3.3846,
          "n": 13
        },
        {
          "delay": 23.4091,
          "n": 154
        },
        {
          "delay": 16.9318,
          "n": 44
        },
        {
          "delay": 8.2927,
          "n": 123
        },
        {
          "delay": 5.3759,
          "n": 133
        },
        {
          "delay": 17.9365,
          "n": 189
        },
        {
          "delay": 4.7679,
          "n": 56
        },
        {
          "delay": 8.4468,
          "n": 47
        },
        {
          "delay": 12.0076,
          "n": 131
        },
        {
          "delay": 18.7317,
          "n": 164
        },
        {
          "delay": -11,
          "n": 4
        },
        {
          "delay": 3.4483,
          "n": 58
        },
        {
          "delay": -0.0816,
          "n": 49
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": 10.8182,
          "n": 66
        },
        {
          "delay": 4.3566,
          "n": 129
        },
        {
          "delay": 20.1215,
          "n": 181
        },
        {
          "delay": 6,
          "n": 1
        },
        {
          "delay": -2.3137,
          "n": 51
        },
        {
          "delay": 9,
          "n": 1
        },
        {
          "delay": 9.6452,
          "n": 62
        },
        {
          "delay": 1.2547,
          "n": 106
        },
        {
          "delay": 7.0556,
          "n": 72
        },
        {
          "delay": 6.6903,
          "n": 155
        },
        {
          "delay": 16,
          "n": 1
        },
        {
          "delay": 8.4407,
          "n": 59
        },
        {
          "delay": 11.061,
          "n": 82
        },
        {
          "delay": 2.3441,
          "n": 93
        },
        {
          "delay": -5.6333,
          "n": 90
        },
        {
          "delay": -4,
          "n": 1
        },
        {
          "delay": 13,
          "n": 2
        },
        {
          "delay": -2.85,
          "n": 20
        },
        {
          "delay": 4.8598,
          "n": 107
        },
        {
          "delay": -8.1648,
          "n": 91
        },
        {
          "delay": 11.5,
          "n": 2
        },
        {
          "delay": 13.5,
          "n": 2
        },
        {
          "delay": 10.2857,
          "n": 70
        },
        {
          "delay": 3.902,
          "n": 102
        },
        {
          "delay": 11.6556,
          "n": 90
        },
        {
          "delay": -7.0645,
          "n": 31
        },
        {
          "delay": 4.7091,
          "n": 55
        },
        {
          "delay": 42,
          "n": 6
        },
        {
          "delay": 11.649,
          "n": 151
        },
        {
          "delay": 2.2252,
          "n": 111
        },
        {
          "delay": -8.8095,
          "n": 126
        },
        {
          "delay": 0.92,
          "n": 50
        },
        {
          "delay": 9.5,
          "n": 2
        },
        {
          "delay": 1.2931,
          "n": 58
        },
        {
          "delay": 8,
          "n": 1
        },
        {
          "delay": 8.1398,
          "n": 93
        },
        {
          "delay": 1.8812,
          "n": 101
        },
        {
          "delay": -3.4731,
          "n": 93
        },
        {
          "delay": 3.5818,
          "n": 55
        },
        {
          "delay": -2.9,
          "n": 60
        },
        {
          "delay": 18.4839,
          "n": 31
        },
        {
          "delay": -20,
          "n": 2
        },
        {
          "delay": 2.1042,
          "n": 96
        },
        {
          "delay": -8.8229,
          "n": 96
        },
        {
          "delay": 1.4035,
          "n": 57
        },
        {
          "delay": -15,
          "n": 1
        },
        {
          "delay": 21.9683,
          "n": 63
        },
        {
          "delay": 0.9091,
          "n": 143
        },
        {
          "delay": -2.8163,
          "n": 98
        },
        {
          "delay": -1.5294,
          "n": 51
        },
        {
          "delay": -20,
          "n": 1
        },
        {
          "delay": 1.5635,
          "n": 126
        },
        {
          "delay": -5.3611,
          "n": 72
        },
        {
          "delay": 25.0857,
          "n": 35
        },
        {
          "delay": 320,
          "n": 1
        },
        {
          "delay": 18.5111,
          "n": 90
        },
        {
          "delay": 5.5702,
          "n": 121
        },
        {
          "delay": -7.8099,
          "n": 121
        },
        {
          "delay": 4.8254,
          "n": 63
        },
        {
          "delay": -18,
          "n": 1
        },
        {
          "delay": 13.7188,
          "n": 64
        },
        {
          "delay": 4.518,
          "n": 139
        },
        {
          "delay": -1.67,
          "n": 100
        },
        {
          "delay": 35,
          "n": 1
        },
        {
          "delay": 15.7125,
          "n": 80
        },
        {
          "delay": 0.2072,
          "n": 111
        },
        {
          "delay": -8.0841,
          "n": 107
        },
        {
          "delay": 32.4,
          "n": 35
        },
        {
          "delay": 2.1887,
          "n": 53
        },
        {
          "delay": 6.3077,
          "n": 78
        },
        {
          "delay": 4.9836,
          "n": 122
        },
        {
          "delay": -11.0549,
          "n": 91
        },
        {
          "delay": 4.0851,
          "n": 47
        },
        {
          "delay": -0.6667,
          "n": 3
        },
        {
          "delay": 3.538,
          "n": 171
        },
        {
          "delay": 1.2617,
          "n": 107
        },
        {
          "delay": -9.8571,
          "n": 91
        },
        {
          "delay": 0.3636,
          "n": 66
        },
        {
          "delay": 12.8182,
          "n": 44
        },
        {
          "delay": 18.121,
          "n": 124
        },
        {
          "delay": 3.2177,
          "n": 124
        },
        {
          "delay": -9.0421,
          "n": 95
        },
        {
          "delay": 6.9839,
          "n": 62
        },
        {
          "delay": -1.8125,
          "n": 48
        },
        {
          "delay": 9.807,
          "n": 57
        },
        {
          "delay": 20.3469,
          "n": 49
        },
        {
          "delay": 14.8692,
          "n": 130
        },
        {
          "delay": 0.2667,
          "n": 30
        },
        {
          "delay": -2.875,
          "n": 56
        },
        {
          "delay": 17.6508,
          "n": 63
        },
        {
          "delay": 219,
          "n": 1
        },
        {
          "delay": 5.2414,
          "n": 116
        },
        {
          "delay": -8.6892,
          "n": 74
        },
        {
          "delay": 13.4815,
          "n": 54
        },
        {
          "delay": 10.6903,
          "n": 113
        },
        {
          "delay": -4.2617,
          "n": 107
        },
        {
          "delay": -9.7532,
          "n": 77
        },
        {
          "delay": 1.2041,
          "n": 49
        },
        {
          "delay": 15.02,
          "n": 50
        },
        {
          "delay": -0.5156,
          "n": 64
        },
        {
          "delay": -2.9683,
          "n": 126
        },
        {
          "delay": 0.5641,
          "n": 78
        },
        {
          "delay": 6.7959,
          "n": 49
        },
        {
          "delay": -2.6136,
          "n": 44
        },
        {
          "delay": -0.1515,
          "n": 33
        },
        {
          "delay": -3,
          "n": 2
        },
        {
          "delay": 3.4677,
          "n": 124
        },
        {
          "delay": -10.5632,
          "n": 87
        },
        {
          "delay": 19.3846,
          "n": 26
        },
        {
          "delay": 40,
          "n": 11
        },
        {
          "delay": 7.7934,
          "n": 121
        },
        {
          "delay": -11.4595,
          "n": 74
        },
        {
          "delay": 21.3958,
          "n": 48
        },
        {
          "delay": 10.8409,
          "n": 132
        },
        {
          "delay": -27,
          "n": 1
        },
        {
          "delay": 19.129,
          "n": 62
        },
        {
          "delay": 2.1872,
          "n": 187
        },
        {
          "delay": 6,
          "n": 40
        },
        {
          "delay": -7.0851,
          "n": 47
        },
        {
          "delay": 13.587,
          "n": 46
        },
        {
          "delay": -1.6667,
          "n": 3
        },
        {
          "delay": 9.5385,
          "n": 13
        },
        {
          "delay": 10,
          "n": 46
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": 2.4444,
          "n": 9
        },
        {
          "delay": -6.5,
          "n": 12
        },
        {
          "delay": -4.2308,
          "n": 13
        },
        {
          "delay": -5.5385,
          "n": 13
        },
        {
          "delay": 7.4528,
          "n": 53
        },
        {
          "delay": -3.5833,
          "n": 12
        },
        {
          "delay": 2.8,
          "n": 5
        },
        {
          "delay": -4.375,
          "n": 8
        },
        {
          "delay": -1.9,
          "n": 10
        },
        {
          "delay": 4.8571,
          "n": 14
        },
        {
          "delay": -9.2,
          "n": 5
        },
        {
          "delay": -0.8,
          "n": 10
        },
        {
          "delay": 16.0408,
          "n": 49
        },
        {
          "delay": 4.7143,
          "n": 7
        },
        {
          "delay": -5.2,
          "n": 5
        },
        {
          "delay": -0.6364,
          "n": 11
        },
        {
          "delay": -1.2,
          "n": 5
        },
        {
          "delay": -1.3333,
          "n": 3
        },
        {
          "delay": 22.5,
          "n": 8
        },
        {
          "delay": 16,
          "n": 3
        },
        {
          "delay": 45,
          "n": 1
        },
        {
          "delay": -4,
          "n": 1
        },
        {
          "delay": 27.5,
          "n": 2
        },
        {
          "delay": -5.5,
          "n": 2
        },
        {
          "delay": 11.6829,
          "n": 41
        },
        {
          "delay": 6.9375,
          "n": 32
        },
        {
          "delay": 13,
          "n": 1
        },
        {
          "delay": 30.0541,
          "n": 37
        },
        {
          "delay": 20.0408,
          "n": 49
        },
        {
          "delay": 4.5192,
          "n": 52
        },
        {
          "delay": 2.9792,
          "n": 48
        },
        {
          "delay": 15.9375,
          "n": 48
        },
        {
          "delay": 1.4,
          "n": 45
        },
        {
          "delay": 35.8049,
          "n": 41
        },
        {
          "delay": 2.1556,
          "n": 45
        },
        {
          "delay": 0.7288,
          "n": 59
        },
        {
          "delay": 8.3043,
          "n": 46
        },
        {
          "delay": 27.5439,
          "n": 57
        },
        {
          "delay": 8.7925,
          "n": 53
        },
        {
          "delay": 8.6667,
          "n": 3
        },
        {
          "delay": 2.1224,
          "n": 49
        },
        {
          "delay": 2.9737,
          "n": 38
        },
        {
          "delay": 84,
          "n": 1
        },
        {
          "delay": 11.3333,
          "n": 33
        },
        {
          "delay": 12.1538,
          "n": 39
        },
        {
          "delay": 1.4262,
          "n": 61
        },
        {
          "delay": 1.4909,
          "n": 55
        },
        {
          "delay": -1.8,
          "n": 60
        },
        {
          "delay": 6.575,
          "n": 120
        },
        {
          "delay": 0.2419,
          "n": 124
        },
        {
          "delay": 7.7209,
          "n": 86
        },
        {
          "delay": 6.4127,
          "n": 63
        },
        {
          "delay": 3.0935,
          "n": 139
        },
        {
          "delay": 4.648,
          "n": 125
        },
        {
          "delay": -4,
          "n": 49
        },
        {
          "delay": 4.375,
          "n": 48
        },
        {
          "delay": 13.3478,
          "n": 46
        },
        {
          "delay": 6.9459,
          "n": 185
        },
        {
          "delay": -3.4651,
          "n": 43
        },
        {
          "delay": 16.8571,
          "n": 42
        },
        {
          "delay": 7.3382,
          "n": 68
        },
        {
          "delay": 9.383,
          "n": 47
        },
        {
          "delay": 8.7963,
          "n": 54
        },
        {
          "delay": 15.1346,
          "n": 52
        },
        {
          "delay": 16,
          "n": 1
        },
        {
          "delay": 6.3621,
          "n": 58
        },
        {
          "delay": 2.087,
          "n": 46
        },
        {
          "delay": -2.1364,
          "n": 44
        },
        {
          "delay": 6.1087,
          "n": 46
        },
        {
          "delay": -2.8776,
          "n": 49
        },
        {
          "delay": -1.0351,
          "n": 57
        },
        {
          "delay": 20.0204,
          "n": 49
        },
        {
          "delay": 28.4375,
          "n": 48
        },
        {
          "delay": -0.4231,
          "n": 52
        },
        {
          "delay": 2.9861,
          "n": 72
        },
        {
          "delay": 11.913,
          "n": 46
        },
        {
          "delay": 16.12,
          "n": 50
        },
        {
          "delay": -3.431,
          "n": 58
        },
        {
          "delay": 10,
          "n": 39
        },
        {
          "delay": -5,
          "n": 50
        },
        {
          "delay": 1.0741,
          "n": 54
        },
        {
          "delay": 0.6333,
          "n": 60
        },
        {
          "delay": 9,
          "n": 67
        },
        {
          "delay": 7.0377,
          "n": 53
        },
        {
          "delay": 15.3636,
          "n": 55
        },
        {
          "delay": 3.9,
          "n": 40
        },
        {
          "delay": 17.8537,
          "n": 41
        },
        {
          "delay": 22,
          "n": 23
        },
        {
          "delay": -3.614,
          "n": 57
        },
        {
          "delay": 24.119,
          "n": 42
        },
        {
          "delay": -2.0732,
          "n": 41
        },
        {
          "delay": 21.381,
          "n": 42
        },
        {
          "delay": 23.8462,
          "n": 26
        },
        {
          "delay": 2.2889,
          "n": 45
        },
        {
          "delay": 14.1591,
          "n": 44
        },
        {
          "delay": 6.0488,
          "n": 41
        },
        {
          "delay": 14,
          "n": 55
        },
        {
          "delay": 17.3542,
          "n": 48
        },
        {
          "delay": 25.3448,
          "n": 29
        },
        {
          "delay": 18.5111,
          "n": 45
        },
        {
          "delay": -0.6508,
          "n": 63
        },
        {
          "delay": 14.4182,
          "n": 55
        },
        {
          "delay": -0.4737,
          "n": 38
        },
        {
          "delay": 10.963,
          "n": 54
        },
        {
          "delay": -0.9464,
          "n": 56
        },
        {
          "delay": 26.2069,
          "n": 29
        },
        {
          "delay": 11.2222,
          "n": 27
        },
        {
          "delay": 8.5082,
          "n": 61
        },
        {
          "delay": 0.4,
          "n": 30
        },
        {
          "delay": 4.9483,
          "n": 58
        },
        {
          "delay": 7.5,
          "n": 62
        },
        {
          "delay": 6.2683,
          "n": 41
        },
        {
          "delay": 8.697,
          "n": 33
        },
        {
          "delay": 16.5263,
          "n": 38
        },
        {
          "delay": 1.02,
          "n": 50
        },
        {
          "delay": 2.2857,
          "n": 56
        },
        {
          "delay": 0.871,
          "n": 31
        },
        {
          "delay": 15.5714,
          "n": 49
        },
        {
          "delay": 0.1549,
          "n": 71
        },
        {
          "delay": 14,
          "n": 41
        },
        {
          "delay": 2.2826,
          "n": 46
        },
        {
          "delay": 5.5405,
          "n": 37
        },
        {
          "delay": 17.8,
          "n": 25
        },
        {
          "delay": 12.1993,
          "n": 286
        },
        {
          "delay": 18.6923,
          "n": 104
        },
        {
          "delay": 6.6667,
          "n": 3
        },
        {
          "delay": 4.5882,
          "n": 34
        },
        {
          "delay": -5.8154,
          "n": 65
        },
        {
          "delay": 7.2857,
          "n": 14
        },
        {
          "delay": 6.8652,
          "n": 89
        },
        {
          "delay": 17.8214,
          "n": 28
        },
        {
          "delay": 5.4647,
          "n": 241
        },
        {
          "delay": -3,
          "n": 1
        },
        {
          "delay": 10.9211,
          "n": 76
        },
        {
          "delay": -11.1429,
          "n": 7
        },
        {
          "delay": 7.2222,
          "n": 45
        },
        {
          "delay": 10.84,
          "n": 25
        },
        {
          "delay": 10.5512,
          "n": 205
        },
        {
          "delay": -20.5,
          "n": 2
        },
        {
          "delay": -0.9391,
          "n": 115
        },
        {
          "delay": 7.3333,
          "n": 9
        },
        {
          "delay": 20.4211,
          "n": 19
        },
        {
          "delay": 33.4091,
          "n": 22
        },
        {
          "delay": 8.7479,
          "n": 238
        },
        {
          "delay": 16,
          "n": 1
        },
        {
          "delay": -4.04,
          "n": 75
        },
        {
          "delay": 2.7158,
          "n": 95
        },
        {
          "delay": 56.6667,
          "n": 3
        },
        {
          "delay": 28.1579,
          "n": 19
        },
        {
          "delay": 4.6009,
          "n": 218
        },
        {
          "delay": 24,
          "n": 1
        },
        {
          "delay": -3.451,
          "n": 102
        },
        {
          "delay": 1.4622,
          "n": 119
        },
        {
          "delay": -10.25,
          "n": 4
        },
        {
          "delay": 30.1429,
          "n": 7
        },
        {
          "delay": 4.7647,
          "n": 34
        },
        {
          "delay": 3.707,
          "n": 256
        },
        {
          "delay": 18.8333,
          "n": 36
        },
        {
          "delay": 15,
          "n": 2
        },
        {
          "delay": 4.5521,
          "n": 96
        },
        {
          "delay": 3.6957,
          "n": 115
        },
        {
          "delay": 17.875,
          "n": 8
        },
        {
          "delay": 15.931,
          "n": 29
        },
        {
          "delay": 10.4333,
          "n": 30
        },
        {
          "delay": 9.1081,
          "n": 259
        },
        {
          "delay": -11,
          "n": 1
        },
        {
          "delay": 7.4464,
          "n": 112
        },
        {
          "delay": 14.1905,
          "n": 63
        },
        {
          "delay": -3.1429,
          "n": 7
        },
        {
          "delay": 26.3333,
          "n": 18
        },
        {
          "delay": 91.5,
          "n": 2
        },
        {
          "delay": 5.8214,
          "n": 28
        },
        {
          "delay": 8.3797,
          "n": 237
        },
        {
          "delay": 0.303,
          "n": 99
        },
        {
          "delay": 1.3939,
          "n": 99
        },
        {
          "delay": 17.2,
          "n": 5
        },
        {
          "delay": 38.5238,
          "n": 21
        },
        {
          "delay": 12.087,
          "n": 23
        },
        {
          "delay": 3.4722,
          "n": 252
        },
        {
          "delay": 0.4945,
          "n": 91
        },
        {
          "delay": 3.8913,
          "n": 92
        },
        {
          "delay": 17.2659,
          "n": 173
        },
        {
          "delay": 18.4,
          "n": 5
        },
        {
          "delay": 18.2222,
          "n": 9
        },
        {
          "delay": 3.3171,
          "n": 41
        },
        {
          "delay": 4.6736,
          "n": 239
        },
        {
          "delay": 13.2286,
          "n": 35
        },
        {
          "delay": 21.2111,
          "n": 90
        },
        {
          "delay": 2.8701,
          "n": 77
        },
        {
          "delay": -14,
          "n": 1
        },
        {
          "delay": 33,
          "n": 6
        },
        {
          "delay": 38.5,
          "n": 2
        },
        {
          "delay": 20.5,
          "n": 34
        },
        {
          "delay": 11.035,
          "n": 200
        },
        {
          "delay": 294,
          "n": 1
        },
        {
          "delay": 8.0366,
          "n": 82
        },
        {
          "delay": 0.8795,
          "n": 83
        },
        {
          "delay": -23,
          "n": 3
        },
        {
          "delay": 8.1584,
          "n": 101
        },
        {
          "delay": 7.1642,
          "n": 67
        },
        {
          "delay": 11,
          "n": 2
        },
        {
          "delay": -1.8889,
          "n": 9
        },
        {
          "delay": 22,
          "n": 31
        },
        {
          "delay": 9.0085,
          "n": 234
        },
        {
          "delay": 10.2644,
          "n": 87
        },
        {
          "delay": 17.0921,
          "n": 76
        },
        {
          "delay": 48,
          "n": 1
        },
        {
          "delay": -20,
          "n": 1
        },
        {
          "delay": 12.375,
          "n": 8
        },
        {
          "delay": 35.875,
          "n": 16
        },
        {
          "delay": 11.0714,
          "n": 28
        },
        {
          "delay": 15.0471,
          "n": 255
        },
        {
          "delay": 6.1948,
          "n": 77
        },
        {
          "delay": 6.75,
          "n": 108
        },
        {
          "delay": 34,
          "n": 2
        },
        {
          "delay": 39.4,
          "n": 5
        },
        {
          "delay": 12.9677,
          "n": 31
        },
        {
          "delay": 12.608,
          "n": 250
        },
        {
          "delay": 30.5161,
          "n": 31
        },
        {
          "delay": 5.1698,
          "n": 106
        },
        {
          "delay": -2.3548,
          "n": 93
        },
        {
          "delay": -34,
          "n": 2
        },
        {
          "delay": 9.6,
          "n": 5
        },
        {
          "delay": 21.32,
          "n": 25
        },
        {
          "delay": 7.8485,
          "n": 231
        },
        {
          "delay": 6.7468,
          "n": 79
        },
        {
          "delay": 1.4271,
          "n": 96
        },
        {
          "delay": -18,
          "n": 1
        },
        {
          "delay": 1.7143,
          "n": 7
        },
        {
          "delay": 3.8298,
          "n": 47
        },
        {
          "delay": 3.6,
          "n": 270
        },
        {
          "delay": 2.8367,
          "n": 98
        },
        {
          "delay": -0.8298,
          "n": 94
        },
        {
          "delay": 72.6,
          "n": 5
        },
        {
          "delay": -3.3333,
          "n": 3
        },
        {
          "delay": 14.2121,
          "n": 33
        },
        {
          "delay": 12.1044,
          "n": 249
        },
        {
          "delay": 2.8028,
          "n": 71
        },
        {
          "delay": 46,
          "n": 1
        },
        {
          "delay": -1.3093,
          "n": 97
        },
        {
          "delay": 4.6364,
          "n": 11
        },
        {
          "delay": 2.7556,
          "n": 45
        },
        {
          "delay": 3.7429,
          "n": 35
        },
        {
          "delay": 8.2342,
          "n": 222
        },
        {
          "delay": 22.0488,
          "n": 41
        },
        {
          "delay": 4.9902,
          "n": 102
        },
        {
          "delay": 6.6606,
          "n": 109
        },
        {
          "delay": -1,
          "n": 3
        },
        {
          "delay": 85,
          "n": 5
        },
        {
          "delay": 6.7222,
          "n": 18
        },
        {
          "delay": 4.794,
          "n": 267
        },
        {
          "delay": 16.625,
          "n": 24
        },
        {
          "delay": 9.8533,
          "n": 75
        },
        {
          "delay": 5.1078,
          "n": 102
        },
        {
          "delay": 8.8,
          "n": 5
        },
        {
          "delay": 28.6,
          "n": 5
        },
        {
          "delay": 2.6667,
          "n": 33
        },
        {
          "delay": 9.6452,
          "n": 248
        },
        {
          "delay": 14.8571,
          "n": 42
        },
        {
          "delay": 12.1875,
          "n": 96
        },
        {
          "delay": 41,
          "n": 1
        },
        {
          "delay": -9.8,
          "n": 5
        },
        {
          "delay": 4.4857,
          "n": 35
        },
        {
          "delay": 4.0039,
          "n": 255
        },
        {
          "delay": 8.6818,
          "n": 44
        },
        {
          "delay": 1.9915,
          "n": 117
        },
        {
          "delay": 276,
          "n": 1
        },
        {
          "delay": 14.1667,
          "n": 12
        },
        {
          "delay": 3.5312,
          "n": 32
        },
        {
          "delay": 15.9091,
          "n": 33
        },
        {
          "delay": 8.6895,
          "n": 306
        },
        {
          "delay": 33.3333,
          "n": 36
        },
        {
          "delay": -0.4679,
          "n": 109
        },
        {
          "delay": 51.6667,
          "n": 3
        },
        {
          "delay": 43.0833,
          "n": 12
        },
        {
          "delay": 4.9245,
          "n": 53
        },
        {
          "delay": 0.2857,
          "n": 35
        },
        {
          "delay": 3.3,
          "n": 240
        },
        {
          "delay": 19.4167,
          "n": 24
        },
        {
          "delay": 4.6639,
          "n": 122
        },
        {
          "delay": 3.5455,
          "n": 11
        },
        {
          "delay": 12.1282,
          "n": 39
        },
        {
          "delay": 5.4528,
          "n": 254
        },
        {
          "delay": 18.4231,
          "n": 52
        },
        {
          "delay": 9.1667,
          "n": 84
        },
        {
          "delay": 6.4444,
          "n": 9
        },
        {
          "delay": 3.8276,
          "n": 29
        },
        {
          "delay": 9.8333,
          "n": 30
        },
        {
          "delay": 4.4771,
          "n": 262
        },
        {
          "delay": 4.0714,
          "n": 28
        },
        {
          "delay": 9,
          "n": 103
        },
        {
          "delay": -1,
          "n": 3
        },
        {
          "delay": -17.2,
          "n": 5
        },
        {
          "delay": 1.8,
          "n": 30
        },
        {
          "delay": 6.7473,
          "n": 273
        },
        {
          "delay": 20.0732,
          "n": 41
        },
        {
          "delay": 19.061,
          "n": 82
        },
        {
          "delay": 22.375,
          "n": 8
        },
        {
          "delay": 9.3182,
          "n": 44
        },
        {
          "delay": 5.0593,
          "n": 236
        },
        {
          "delay": 21.5,
          "n": 46
        },
        {
          "delay": 5.1489,
          "n": 94
        },
        {
          "delay": 201,
          "n": 1
        },
        {
          "delay": -28,
          "n": 1
        },
        {
          "delay": 1.6667,
          "n": 12
        },
        {
          "delay": 25.5758,
          "n": 33
        },
        {
          "delay": -5.4762,
          "n": 21
        },
        {
          "delay": 7.3411,
          "n": 258
        },
        {
          "delay": 4.6087,
          "n": 23
        },
        {
          "delay": 17.6019,
          "n": 108
        },
        {
          "delay": -8,
          "n": 1
        },
        {
          "delay": -12.5,
          "n": 4
        },
        {
          "delay": 6.8,
          "n": 30
        },
        {
          "delay": 5.9019,
          "n": 214
        },
        {
          "delay": 23.5714,
          "n": 28
        },
        {
          "delay": 14.8451,
          "n": 71
        },
        {
          "delay": 30,
          "n": 2
        },
        {
          "delay": 9.6176,
          "n": 34
        },
        {
          "delay": 13.3099,
          "n": 242
        },
        {
          "delay": 11.5053,
          "n": 95
        },
        {
          "delay": -6.4,
          "n": 10
        },
        {
          "delay": 11.7045,
          "n": 44
        },
        {
          "delay": 18.3824,
          "n": 34
        },
        {
          "delay": 9.9917,
          "n": 241
        },
        {
          "delay": 20.9333,
          "n": 30
        },
        {
          "delay": 2.7778,
          "n": 144
        },
        {
          "delay": 17,
          "n": 1
        },
        {
          "delay": -7.2857,
          "n": 7
        },
        {
          "delay": 4.125,
          "n": 24
        },
        {
          "delay": 37.2778,
          "n": 18
        },
        {
          "delay": 6.0082,
          "n": 243
        },
        {
          "delay": 22.0303,
          "n": 33
        },
        {
          "delay": 1.1596,
          "n": 94
        },
        {
          "delay": 60,
          "n": 1
        },
        {
          "delay": 22.8889,
          "n": 9
        },
        {
          "delay": 12.9583,
          "n": 24
        },
        {
          "delay": 9.4231,
          "n": 26
        },
        {
          "delay": 4.5915,
          "n": 235
        },
        {
          "delay": 16.525,
          "n": 40
        },
        {
          "delay": 6.4304,
          "n": 79
        },
        {
          "delay": 35.5714,
          "n": 7
        },
        {
          "delay": 6.9259,
          "n": 27
        },
        {
          "delay": 7.0925,
          "n": 227
        },
        {
          "delay": 9.0575,
          "n": 87
        },
        {
          "delay": 2.131,
          "n": 84
        },
        {
          "delay": 31.2857,
          "n": 7
        },
        {
          "delay": -7.2,
          "n": 5
        },
        {
          "delay": 12.9062,
          "n": 32
        },
        {
          "delay": 4.4054,
          "n": 222
        },
        {
          "delay": 10.913,
          "n": 23
        },
        {
          "delay": 5.6301,
          "n": 73
        },
        {
          "delay": 5.697,
          "n": 33
        },
        {
          "delay": 6.61,
          "n": 259
        },
        {
          "delay": 22.7895,
          "n": 38
        },
        {
          "delay": 3.7742,
          "n": 93
        },
        {
          "delay": 87,
          "n": 1
        },
        {
          "delay": 0.1786,
          "n": 28
        },
        {
          "delay": 14.069,
          "n": 232
        },
        {
          "delay": 7.4324,
          "n": 37
        },
        {
          "delay": 4.7363,
          "n": 91
        },
        {
          "delay": 0.5,
          "n": 6
        },
        {
          "delay": 7.68,
          "n": 25
        },
        {
          "delay": 17.4524,
          "n": 42
        },
        {
          "delay": 15.2976,
          "n": 84
        },
        {
          "delay": 26.1,
          "n": 10
        },
        {
          "delay": 15.8,
          "n": 5
        },
        {
          "delay": 20.0645,
          "n": 31
        },
        {
          "delay": 1.3333,
          "n": 27
        },
        {
          "delay": 2.2658,
          "n": 79
        },
        {
          "delay": -1,
          "n": 1
        },
        {
          "delay": 9.6667,
          "n": 18
        },
        {
          "delay": 6.2022,
          "n": 89
        },
        {
          "delay": -19,
          "n": 1
        },
        {
          "delay": -13,
          "n": 1
        },
        {
          "delay": 27.0952,
          "n": 21
        },
        {
          "delay": -6,
          "n": 1
        },
        {
          "delay": -0.0357,
          "n": 28
        },
        {
          "delay": 41.15,
          "n": 20
        },
        {
          "delay": 0.3623,
          "n": 69
        },
        {
          "delay": -11.1818,
          "n": 11
        },
        {
          "delay": 38.3095,
          "n": 42
        },
        {
          "delay": 7.4444,
          "n": 27
        },
        {
          "delay": 26.4848,
          "n": 33
        },
        {
          "delay": 19.322,
          "n": 59
        },
        {
          "delay": 8,
          "n": 1
        },
        {
          "delay": 8,
          "n": 4
        },
        {
          "delay": 8.3571,
          "n": 28
        },
        {
          "delay": 12.1111,
          "n": 27
        },
        {
          "delay": 8.7,
          "n": 100
        },
        {
          "delay": 20,
          "n": 3
        },
        {
          "delay": 1.3108,
          "n": 222
        },
        {
          "delay": -2.1786,
          "n": 28
        },
        {
          "delay": 14.4054,
          "n": 37
        },
        {
          "delay": 15.0732,
          "n": 82
        },
        {
          "delay": -13,
          "n": 1
        },
        {
          "delay": -2.4596,
          "n": 285
        },
        {
          "delay": 4.2917,
          "n": 24
        },
        {
          "delay": 16.6667,
          "n": 36
        },
        {
          "delay": 3.4382,
          "n": 89
        },
        {
          "delay": 1.5222,
          "n": 270
        },
        {
          "delay": -6,
          "n": 32
        },
        {
          "delay": 5.7297,
          "n": 37
        },
        {
          "delay": 4,
          "n": 76
        },
        {
          "delay": 0.6163,
          "n": 258
        },
        {
          "delay": 2.7941,
          "n": 34
        },
        {
          "delay": 1.1739,
          "n": 23
        },
        {
          "delay": 11.8036,
          "n": 56
        },
        {
          "delay": 65,
          "n": 2
        },
        {
          "delay": 1.0172,
          "n": 232
        },
        {
          "delay": 14.5676,
          "n": 37
        },
        {
          "delay": 31.1852,
          "n": 27
        },
        {
          "delay": -3.8929,
          "n": 84
        },
        {
          "delay": -0.3162,
          "n": 234
        },
        {
          "delay": 4.4194,
          "n": 31
        },
        {
          "delay": 16.1923,
          "n": 26
        },
        {
          "delay": 6.0286,
          "n": 70
        },
        {
          "delay": 2.2521,
          "n": 242
        },
        {
          "delay": 10.04,
          "n": 25
        },
        {
          "delay": 6.975,
          "n": 40
        },
        {
          "delay": 5.9104,
          "n": 67
        },
        {
          "delay": 54.75,
          "n": 4
        },
        {
          "delay": -0.1705,
          "n": 264
        },
        {
          "delay": 7.7,
          "n": 20
        },
        {
          "delay": 22.7143,
          "n": 28
        },
        {
          "delay": -3.7882,
          "n": 85
        },
        {
          "delay": 4,
          "n": 2
        },
        {
          "delay": -3.5089,
          "n": 281
        },
        {
          "delay": 5.6774,
          "n": 31
        },
        {
          "delay": 8.56,
          "n": 25
        },
        {
          "delay": -4.7412,
          "n": 85
        },
        {
          "delay": -30,
          "n": 1
        },
        {
          "delay": 13.3333,
          "n": 3
        },
        {
          "delay": -0.3495,
          "n": 309
        },
        {
          "delay": 9.1111,
          "n": 27
        },
        {
          "delay": 18.1034,
          "n": 29
        },
        {
          "delay": 3.425,
          "n": 80
        },
        {
          "delay": -1.1688,
          "n": 237
        },
        {
          "delay": -2.3226,
          "n": 31
        },
        {
          "delay": 18.325,
          "n": 40
        },
        {
          "delay": 0.5571,
          "n": 70
        },
        {
          "delay": -3,
          "n": 1
        },
        {
          "delay": -0.8,
          "n": 225
        },
        {
          "delay": 18.7692,
          "n": 39
        },
        {
          "delay": 47.6471,
          "n": 34
        },
        {
          "delay": 4.5385,
          "n": 65
        },
        {
          "delay": 0,
          "n": 1
        },
        {
          "delay": 38.25,
          "n": 4
        },
        {
          "delay": -4.2027,
          "n": 222
        },
        {
          "delay": 6.8108,
          "n": 37
        },
        {
          "delay": 10.6786,
          "n": 28
        },
        {
          "delay": 3.2987,
          "n": 77
        },
        {
          "delay": -6,
          "n": 1
        },
        {
          "delay": -2.8737,
          "n": 285
        },
        {
          "delay": 11,
          "n": 24
        },
        {
          "delay": 11.5714,
          "n": 35
        },
        {
          "delay": 4.4412,
          "n": 102
        },
        {
          "delay": 31,
          "n": 3
        },
        {
          "delay": -1.3283,
          "n": 198
        },
        {
          "delay": 1.1429,
          "n": 28
        },
        {
          "delay": 25.9286,
          "n": 28
        },
        {
          "delay": 7.5059,
          "n": 85
        },
        {
          "delay": 15.3333,
          "n": 3
        },
        {
          "delay": 1.0236,
          "n": 212
        },
        {
          "delay": 5.125,
          "n": 24
        },
        {
          "delay": 33.1154,
          "n": 26
        },
        {
          "delay": 17.4737,
          "n": 57
        },
        {
          "delay": 39,
          "n": 3
        },
        {
          "delay": 10.9615,
          "n": 26
        },
        {
          "delay": 22.6,
          "n": 35
        },
        {
          "delay": 9.2169,
          "n": 83
        },
        {
          "delay": 38,
          "n": 3
        },
        {
          "delay": -5.2965,
          "n": 226
        },
        {
          "delay": 3.7812,
          "n": 32
        },
        {
          "delay": 11.3625,
          "n": 80
        },
        {
          "delay": -7,
          "n": 1
        },
        {
          "delay": 5.25,
          "n": 24
        },
        {
          "delay": 11.697,
          "n": 33
        },
        {
          "delay": 9.6273,
          "n": 110
        },
        {
          "delay": 50.6,
          "n": 5
        },
        {
          "delay": -2.8539,
          "n": 219
        },
        {
          "delay": 8.3333,
          "n": 39
        },
        {
          "delay": 20.2222,
          "n": 36
        },
        {
          "delay": 0.5714,
          "n": 70
        },
        {
          "delay": -14.5,
          "n": 2
        },
        {
          "delay": 17.0741,
          "n": 27
        },
        {
          "delay": 13.6098,
          "n": 41
        },
        {
          "delay": 8.7051,
          "n": 78
        },
        {
          "delay": 72.5,
          "n": 2
        },
        {
          "delay": -0.3394,
          "n": 218
        },
        {
          "delay": 15.1724,
          "n": 29
        },
        {
          "delay": 23.1944,
          "n": 36
        },
        {
          "delay": 4.1236,
          "n": 89
        },
        {
          "delay": 5.0435,
          "n": 23
        },
        {
          "delay": 15.7632,
          "n": 38
        },
        {
          "delay": 9.0562,
          "n": 89
        },
        {
          "delay": -2.5459,
          "n": 207
        },
        {
          "delay": 9.1786,
          "n": 28
        },
        {
          "delay": 19.5556,
          "n": 27
        },
        {
          "delay": 15.05,
          "n": 100
        },
        {
          "delay": -4.3333,
          "n": 18
        },
        {
          "delay": 36.8824,
          "n": 34
        },
        {
          "delay": 5.1619,
          "n": 105
        },
        {
          "delay": 14.375,
          "n": 32
        },
        {
          "delay": 24.5,
          "n": 28
        },
        {
          "delay": 7.9888,
          "n": 89
        },
        {
          "delay": 15.3333,
          "n": 33
        },
        {
          "delay": 0.0889,
          "n": 90
        },
        {
          "delay": 21.8438,
          "n": 32
        },
        {
          "delay": 10.7978,
          "n": 89
        },
        {
          "delay": 6.7237,
          "n": 76
        },
        {
          "delay": 6.7059,
          "n": 34
        },
        {
          "delay": -8.1566,
          "n": 83
        },
        {
          "delay": 8.6087,
          "n": 23
        },
        {
          "delay": 10.7238,
          "n": 105
        },
        {
          "delay": 16.5333,
          "n": 90
        },
        {
          "delay": 9.119,
          "n": 84
        },
        {
          "delay": -6.2911,
          "n": 79
        },
        {
          "delay": 11.3846,
          "n": 65
        },
        {
          "delay": -0.1538,
          "n": 78
        },
        {
          "delay": 107,
          "n": 1
        },
        {
          "delay": 16.2241,
          "n": 58
        },
        {
          "delay": -1.536,
          "n": 125
        },
        {
          "delay": 35.1915,
          "n": 47
        },
        {
          "delay": 2.8675,
          "n": 83
        },
        {
          "delay": 14.3182,
          "n": 44
        },
        {
          "delay": -1.931,
          "n": 87
        },
        {
          "delay": 11.2174,
          "n": 23
        },
        {
          "delay": 8.9885,
          "n": 87
        },
        {
          "delay": 28.4062,
          "n": 32
        },
        {
          "delay": 17.8866,
          "n": 97
        },
        {
          "delay": 4.2281,
          "n": 57
        },
        {
          "delay": 15.0385,
          "n": 26
        },
        {
          "delay": 0.254,
          "n": 63
        },
        {
          "delay": 0.125,
          "n": 24
        },
        {
          "delay": 5.5833,
          "n": 72
        },
        {
          "delay": 37.3846,
          "n": 26
        },
        {
          "delay": -3.2909,
          "n": 55
        },
        {
          "delay": 44.3429,
          "n": 35
        },
        {
          "delay": 9.4717,
          "n": 53
        },
        {
          "delay": 28.1935,
          "n": 62
        },
        {
          "delay": 11.0341,
          "n": 88
        },
        {
          "delay": 16.3857,
          "n": 70
        },
        {
          "delay": 12.4286,
          "n": 56
        },
        {
          "delay": 15.68,
          "n": 25
        },
        {
          "delay": 7.337,
          "n": 92
        },
        {
          "delay": 17.7838,
          "n": 37
        },
        {
          "delay": -6.6491,
          "n": 57
        },
        {
          "delay": 10.4043,
          "n": 47
        },
        {
          "delay": 16.9811,
          "n": 53
        },
        {
          "delay": 31.4839,
          "n": 31
        },
        {
          "delay": 5.0328,
          "n": 61
        },
        {
          "delay": 26.4706,
          "n": 17
        },
        {
          "delay": 1.9298,
          "n": 57
        },
        {
          "delay": 6.5385,
          "n": 26
        },
        {
          "delay": 0.5248,
          "n": 101
        },
        {
          "delay": 16.3023,
          "n": 43
        },
        {
          "delay": 4.9032,
          "n": 62
        },
        {
          "delay": 29.96,
          "n": 25
        },
        {
          "delay": 16.3947,
          "n": 76
        },
        {
          "delay": 14.3115,
          "n": 61
        },
        {
          "delay": 9.2353,
          "n": 238
        }
      ]
    },
    "encoding": {
      "x": {
        "field": "n",
        "type": "quantitative"
      },
      "y": {
        "field": "delay",
        "type": "quantitative"
      }
    },
    "mark": {
      "filled": true,
      "opacity": 0.1,
      "type": "point"
    }
  },
  "embed_options": {
    "defaultStyle": true,
    "renderer": "canvas"
  }
},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Not surprisingly, there is much greater variation in the average delay when there are few flights. The shape of this plot is very characteristic: whenever you plot a mean (or other summary) vs. group size, you'll see that the variation decreases as the sample size increases.

When looking at this sort of plot, it's often useful to filter out the groups with the smallest numbers of observations, so you can see more of the pattern and less of the extreme variation in the smallest groups. This is what the following code does, as well as showing you a handy pattern for simple data frame manipulations only needed for a chart. 


```python
chart = (alt.Chart(delays.query("n > 25"))
    .encode(
      x = 'n',
      y = 'delay'
    )
    .mark_point(
      filled = True, 
      opacity = 1/10))

chart.save("screenshots/altair_delays.png")
```

<img src="screenshots/altair_delays.png" width="70%" style="display: block; margin: auto auto auto 0;" />

There's another common variation of this type of pattern. Let's look at how the average performance of batters in baseball is related to the number of times they're at bat. Here I use data from the __Lahman__ package to compute the batting average (number of hits / number of attempts) of every major league baseball player.

When I plot the skill of the batter (measured by the batting average, `ba`) against the number of opportunities to hit the ball (measured by at bat, `ab`), you see two patterns:

1.  As above, the variation in our aggregate decreases as we get more
    data points.

2.  There's a positive correlation between skill (`ba`) and opportunities to
    hit the ball (`ab`). This is because teams control who gets to play,
    and obviously they'll pick their best players.


```python
# settings for Altair to handle large data
alt.data_transformers.enable('json')
#> DataTransformerRegistry.enable('json')
batting_url = "https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/batting/batting.csv"
batting = pd.read_csv(batting_url)

batters = (batting
    .groupby('playerID')
    .agg(
      ab = ("AB", "sum"),
      h = ("H", "sum")
      )
    .assign(ba = lambda x: x.h/x.ab))

chart = (alt.Chart(batters.query('ab > 100'))
    .encode(
      x = 'ab',
      y = 'ba'
      )
    .mark_point())

chart.save("screenshots/altair_batters.png")
```

<img src="screenshots/altair_batters.png" width="70%" style="display: block; margin: auto auto auto 0;" />

This also has important implications for ranking. If you naively sort on `desc(ba)`, the people with the best batting averages are clearly lucky, not skilled:


```python
batters.sort_values('ba', ascending = False).head(10)
#>            ab  h   ba
#> playerID             
#> egeco01     1  1  1.0
#> simspe01    1  1  1.0
#> paciojo01   3  3  1.0
#> bruneju01   1  1  1.0
#> liddeda01   1  1  1.0
#> garcimi02   1  1  1.0
#> meehabi01   1  1  1.0
#> rodried01   1  1  1.0
#> hopkimi01   2  2  1.0
#> gallaja01   1  1  1.0
```

You can find a good explanation of this problem at <http://varianceexplained.org/r/empirical_bayes_baseball/> and <http://www.evanmiller.org/how-not-to-sort-by-average-rating.html>.

### Useful summary functions {#summarise-funs}

Just using means, counts, and sum can get you a long way, but NumPy, SciPy, and Pandas provide many other useful summary functions (remember we are using the SciPy stats submodule):

*   Measures of location: we've used `np.mean()`, but `np.median()` is also
    useful. The mean is the sum divided by the length; the median is a value
    where 50% of `x` is above it, and 50% is below it.

    It's sometimes useful to combine aggregation with logical subsetting.
    We haven't talked about this sort of subsetting yet, but you'll learn more
    about it in [subsetting].

    
    ```python
    (not_cancelled
    .groupby(['year', 'month', 'day'])
    .agg(
      avg_delay1 = ('arr_delay', np.mean),
      avg_delay2 = ('arr_delay', lambda x: np.mean(x[x > 0]))
      ))
    #>                 avg_delay1  avg_delay2
    #> year month day                        
    #> 2013 1     1     12.651023   32.481562
    #>            2     12.692888   32.029907
    #>            3      5.733333   27.660870
    #>            4     -1.932819   28.309764
    #>            5     -1.525802   22.558824
    #> ...                    ...         ...
    #>      12    27    -0.148803   29.046832
    #>            28    -3.259533   25.607692
    #>            29    18.763825   47.256356
    #>            30    10.057712   31.243802
    #>            31     6.212121   24.455959
    #> 
    #> [365 rows x 2 columns]
    ```

*   Measures of spread: `np.sd()`, `stats.iqr()`, `stats.median_absolute_deviation()`. 
    The root mean squared deviation, or standard deviation `np.sd()`, is the standard 
    measure of spread. The interquartile range `stats.iqr()` and median absolute deviation
    `stats.median_absolute_deviation()` are robust equivalents that may be more useful if
    you have outliers.

    
    ```python
    # Why is distance to some destinations more variable than to others?
    (not_cancelled
    .groupby(['dest'])
    .agg(distance_sd = ('distance', np.std))
    .sort_values('distance_sd', ascending = False))
    #>       distance_sd
    #> dest             
    #> EGE     10.542765
    #> SAN     10.350094
    #> SFO     10.216017
    #> HNL     10.004197
    #> SEA      9.977993
    #> ...           ...
    #> BZN      0.000000
    #> BUR      0.000000
    #> PSE      0.000000
    #> ABQ      0.000000
    #> LEX           NaN
    #> 
    #> [104 rows x 1 columns]
    ```

*   Measures of rank: `np.min()`, `np.quantile()`, `np.max()`. Quantiles
    are a generalisation of the median. For example, `np.quantile(x, 0.25)`
    will find a value of `x` that is greater than 25% of the values,
    and less than the remaining 75%.

    
    ```python
    # When do the first and last flights leave each day?
    (not_cancelled
      .groupby(['year', 'month', 'day'])
      .agg(
        first = ('dep_time', np.min),
        last = ('dep_time', np.max)
        ))
    #>                 first    last
    #> year month day               
    #> 2013 1     1    517.0  2356.0
    #>            2     42.0  2354.0
    #>            3     32.0  2349.0
    #>            4     25.0  2358.0
    #>            5     14.0  2357.0
    #> ...               ...     ...
    #>      12    27     2.0  2351.0
    #>            28     7.0  2358.0
    #>            29     3.0  2400.0
    #>            30     1.0  2356.0
    #>            31    13.0  2356.0
    #> 
    #> [365 rows x 2 columns]
    ```

*   Measures of position: `first()`, `nth()`, `last()`. These work
    similarly to `x[1]`, `x[2]`, and `x[size(x)]` but let you set a default
    value if that position does not exist (i.e. you're trying to get the 3rd
    element from a group that only has two elements). For example, we can
    find the first and last departure for each day:

    
    ```python
    # using first and last
    (not_cancelled
      .groupby(['year', 'month','day'])
      .agg(
        first_dep = ('dep_time', 'first'),
        last_dep  = ('dep_time', 'last')
        ))
    #>                 first_dep  last_dep
    #> year month day                     
    #> 2013 1     1        517.0    2356.0
    #>            2         42.0    2354.0
    #>            3         32.0    2349.0
    #>            4         25.0    2358.0
    #>            5         14.0    2357.0
    #> ...                   ...       ...
    #>      12    27         2.0    2351.0
    #>            28         7.0    2358.0
    #>            29         3.0    2400.0
    #>            30         1.0    2356.0
    #>            31        13.0    2356.0
    #> 
    #> [365 rows x 2 columns]
    ```

    
    ```python
    # using position
    (not_cancelled
      .groupby(['year', 'month','day'])
      .agg(
        first_dep = ('dep_time', lambda x: list(x)[0]),
        last_dep = ('dep_time', lambda x: list(x)[-1])
        ))
    #>                 first_dep  last_dep
    #> year month day                     
    #> 2013 1     1        517.0    2356.0
    #>            2         42.0    2354.0
    #>            3         32.0    2349.0
    #>            4         25.0    2358.0
    #>            5         14.0    2357.0
    #> ...                   ...       ...
    #>      12    27         2.0    2351.0
    #>            28         7.0    2358.0
    #>            29         3.0    2400.0
    #>            30         1.0    2356.0
    #>            31        13.0    2356.0
    #> 
    #> [365 rows x 2 columns]
    ```
  
    <!-- These functions are complementary to filtering on ranks. Filtering gives -->
    <!-- you all variables, with each observation in a separate row: -->

    <!-- ```{python} -->
    <!-- not_cancelled['f'] = not_cancelled.assign( -->
    <!--         r = lambda x: (x. -->
    <!--                         groupby(['year', 'month','day']). -->
    <!--                         dep_time.agg('rank', method = 'min')) -->
    <!--     ).groupby(['year', 'month','day']).r.transform( -->
    <!--         lambda x: (x == np.min(x)) | (x == np.max(x)) -->
    <!--     ) -->

    <!-- not_cancelled.query('f == True').drop(columns = 'f') -->

    <!-- # The pandas way to do this -->
    <!-- df['min_c'] = df.groupby('A')['C'].transform('min') -->
    <!-- df['max_c'] = df.groupby('A')['C'].transform('max') -->

    <!-- df.query(' (C == min_c) or (C == max_c) ').filter(['A', 'B', 'C']) -->
    <!-- ``` -->

*   Counts: You've seen `size()`, which takes no arguments, and returns the
    size of the current group. To count the number of non-missing values, use
    `isnull().sum()`. To count the number of unique (distinct) values, use
    `nunique()`.

    
    ```python
    # Which destinations have the most carriers?
    (flights
      .groupby('dest')
      .agg(
        carriers_unique = ('carrier', 'nunique'),
        carriers_count = ('carrier', 'size'),
        missing_time = ('dep_time', lambda x: x.isnull().sum())
        ))
    #>       carriers_unique  carriers_count  missing_time
    #> dest                                               
    #> ABQ                 1             254           0.0
    #> ACK                 1             265           0.0
    #> ALB                 1             439          20.0
    #> ANC                 1               8           0.0
    #> ATL                 7           17215         317.0
    #> ...               ...             ...           ...
    #> TPA                 7            7466          59.0
    #> TUL                 1             315          16.0
    #> TVC                 2             101           5.0
    #> TYS                 2             631          52.0
    #> XNA                 2            1036          25.0
    #> 
    #> [105 rows x 3 columns]
    ```

    Counts are useful and pandas provides a simple helper if all you want is
    a count:

    
    ```python
    not_cancelled['dest'].value_counts()
    #> ATL    16837
    #> ORD    16566
    #> LAX    16026
    #> BOS    15022
    #> MCO    13967
    #>        ...  
    #> MTJ       14
    #> HDN       14
    #> SBN       10
    #> ANC        8
    #> LEX        1
    #> Name: dest, Length: 104, dtype: int64
    ```

*   Counts and proportions of logical values: `sum(x > 10)`, `mean(y == 0)`.
    When used with numeric functions, `TRUE` is converted to 1 and `FALSE` to 0.
    This makes `sum()` and `mean()` very useful: `sum(x)` gives the number of
    `TRUE`s in `x`, and `mean(x)` gives the proportion.

    
    ```python
    # How many flights left before 5am? (these usually indicate delayed
    # flights from the previous day)
    (not_cancelled
      .groupby(['year', 'month','day'])
      .agg(n_early = ('dep_time', lambda x: np.sum(x < 500))))
    
    # What proportion of flights are delayed by more than an hour?
    #>                 n_early
    #> year month day         
    #> 2013 1     1        0.0
    #>            2        3.0
    #>            3        4.0
    #>            4        3.0
    #>            5        3.0
    #> ...                 ...
    #>      12    27       7.0
    #>            28       2.0
    #>            29       3.0
    #>            30       6.0
    #>            31       4.0
    #> 
    #> [365 rows x 1 columns]
    (not_cancelled
      .groupby(['year', 'month','day'])
      .agg(hour_prop = ('arr_delay', lambda x: np.sum(x > 60))))
    #>                 hour_prop
    #> year month day           
    #> 2013 1     1         60.0
    #>            2         79.0
    #>            3         51.0
    #>            4         36.0
    #>            5         25.0
    #> ...                   ...
    #>      12    27        51.0
    #>            28        31.0
    #>            29       129.0
    #>            30        69.0
    #>            31        33.0
    #> 
    #> [365 rows x 1 columns]
    ```

### Grouping by multiple variables

Be careful when progressively rolling up summaries: it's OK for sums and counts, but you need to think about weighting means and variances, and it's not possible to do it exactly for rank-based statistics like the median. In other words, the sum of groupwise sums is the overall sum, but the median of groupwise medians is not the overall median.

### Ungrouping (reseting the index)

If you need to remove grouping and MultiIndex use `reset.index()`. This is a rough equivalent to `ungroup()` in R but it is not the same thing. Notice the column names are no longer in multiple levels.


```python
dat = (not_cancelled
        .groupby(['year', 'month','day'])
        .agg(hour_prop = ('arr_delay', lambda x: np.sum(x > 60))))

dat.head()
#>                 hour_prop
#> year month day           
#> 2013 1     1         60.0
#>            2         79.0
#>            3         51.0
#>            4         36.0
#>            5         25.0
dat.reset_index().head()
#>    year  month  day  hour_prop
#> 0  2013      1    1       60.0
#> 1  2013      1    2       79.0
#> 2  2013      1    3       51.0
#> 3  2013      1    4       36.0
#> 4  2013      1    5       25.0
```

### Exercises

1.  Brainstorm at least 5 different ways to assess the typical delay
    characteristics of a group of flights. Consider the following scenarios:

    * A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of
      the time.

    * A flight is always 10 minutes late.

    * A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of
      the time.

    * 99% of the time a flight is on time. 1% of the time it's 2 hours late.

    Which is more important: arrival delay or departure delay?

1.  Our definition of cancelled flights (`is.na(dep_delay) | is.na(arr_delay)`)
    is slightly suboptimal. Why? Which is the most important column?

1.  Look at the number of cancelled flights per day. Is there a pattern?
    Is the proportion of cancelled flights related to the average delay?

1.  Which carrier has the worst delays? Challenge: can you disentangle the
    effects of bad airports vs. bad carriers? Why/why not? (Hint: think about
    `flights.groupby(['carrier', 'dest']).agg(n = ('dep_time', 'size'))`)

## Grouped transforms (and filters)

Grouping is most useful in conjunction with `.agg()`, but you can also do convenient operations with `.transform()`.  This is a difference in pandas as compared to dplyr.  Once you create a `.groupby()` object you cannot use `.assign()` and the best equivalent is `.transform()`. Following pandas [groupby guide](https://pandas.pydata.org/pandas-docs/stable/user_guide/groupby.html) on 'split-apply-combine', we would assign our transfomred variables to our data frame and then perform filters on the full data frame.

*   Find the worst members of each group:

    
    ```python
    flights_sml['ranks'] = (flights_sml
                            .groupby(['year', 'month','day']).arr_delay
                            .rank(ascending = False))
                            
    #> /usr/local/bin/python3:3: SettingWithCopyWarning: 
    #> A value is trying to be set on a copy of a slice from a DataFrame.
    #> Try using .loc[row_indexer,col_indexer] = value instead
    #> 
    #> See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
    flights_sml.query('ranks < 10').drop(columns = 'ranks')
    #>         year  month  day  dep_delay  arr_delay  air_time  distance
    #> 151     2013      1    1      853.0      851.0      41.0       184
    #> 649     2013      1    1      290.0      338.0     213.0      1134
    #> 673     2013      1    1      260.0      263.0      46.0       266
    #> 729     2013      1    1      157.0      174.0      60.0       213
    #> 746     2013      1    1      216.0      222.0     121.0       708
    #> ...      ...    ...  ...        ...        ...       ...       ...
    #> 336579  2013      9   30      158.0      121.0      95.0       765
    #> 336668  2013      9   30      182.0      174.0      95.0       708
    #> 336724  2013      9   30      158.0      136.0      91.0       746
    #> 336757  2013      9   30      194.0      194.0      50.0       301
    #> 336763  2013      9   30      154.0      130.0     123.0       944
    #> 
    #> [3306 rows x 7 columns]
    ```

*   Find all groups bigger than a threshold:

    
    ```python
    popular_dests = flights
    popular_dests['n'] = popular_dests.groupby('dest').arr_delay.transform('size')
    popular_dests = flights.query('n > 365').drop(columns = 'n')
    popular_dests
    #>         year  month  day  ...  hour  minute                 time_hour
    #> 0       2013      1    1  ...     5      15 2013-01-01 10:00:00+00:00
    #> 1       2013      1    1  ...     5      29 2013-01-01 10:00:00+00:00
    #> 2       2013      1    1  ...     5      40 2013-01-01 10:00:00+00:00
    #> 3       2013      1    1  ...     5      45 2013-01-01 10:00:00+00:00
    #> 4       2013      1    1  ...     6       0 2013-01-01 11:00:00+00:00
    #> ...      ...    ...  ...  ...   ...     ...                       ...
    #> 336771  2013      9   30  ...    14      55 2013-09-30 18:00:00+00:00
    #> 336772  2013      9   30  ...    22       0 2013-10-01 02:00:00+00:00
    #> 336773  2013      9   30  ...    12      10 2013-09-30 16:00:00+00:00
    #> 336774  2013      9   30  ...    11      59 2013-09-30 15:00:00+00:00
    #> 336775  2013      9   30  ...     8      40 2013-09-30 12:00:00+00:00
    #> 
    #> [332577 rows x 19 columns]
    ```

*   Standardise to compute per group metrics:

    
    ```python
    (popular_dests
      .query('arr_delay > 0')
      .assign(
        prop_delay = lambda x: x.arr_delay / x.groupby('dest').arr_delay.transform('sum')
        )
      .filter(['year', 'month', 'day', 'dest', 'arr_delay', 'prop_delay']))
    #>         year  month  day dest  arr_delay  prop_delay
    #> 0       2013      1    1  IAH       11.0    0.000111
    #> 1       2013      1    1  IAH       20.0    0.000201
    #> 2       2013      1    1  MIA       33.0    0.000235
    #> 5       2013      1    1  ORD       12.0    0.000042
    #> 6       2013      1    1  FLL       19.0    0.000094
    #> ...      ...    ...  ...  ...        ...         ...
    #> 336759  2013      9   30  BNA        7.0    0.000057
    #> 336760  2013      9   30  STL       57.0    0.000717
    #> 336762  2013      9   30  SFO       42.0    0.000204
    #> 336763  2013      9   30  MCO      130.0    0.000631
    #> 336768  2013      9   30  BOS        1.0    0.000005
    #> 
    #> [131106 rows x 6 columns]
    ```

### Exercises

1.  Which plane (`tailnum`) has the worst on-time record?

1.  What time of day should you fly if you want to avoid delays as much
    as possible?

1.  For each destination, compute the total minutes of delay. For each
    flight, compute the proportion of the total delay for its destination.

1.  Delays are typically temporally correlated: even once the problem that
    caused the initial delay has been resolved, later flights are delayed
    to allow earlier flights to leave. Explore how the delay
    of a flight is related to the delay of the immediately preceding flight.

1.  Look at each destination. Can you find flights that are suspiciously
    fast? (i.e. flights that represent a potential data entry error). Compute
    the air time of a flight relative to the shortest flight to that destination.
    Which flights were most delayed in the air?

1.  Find all destinations that are flown by at least two carriers. Use that
    information to rank the carriers.

1.  For each plane, count the number of flights before the first delay
    of greater than 1 hour.
