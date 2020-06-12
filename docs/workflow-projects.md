# Workflow: projects

One day you will need to quit Python, go do something else and return to your analysis the next day. One day you will be working on multiple analyses simultaneously that all use Python and you want to keep them separate. One day you will need to bring data from the outside world into Python and send numerical results and figures from Python back out into the world. To handle these real life situations, you need to make two decisions:

1.  What about your analysis is "real", i.e. what will you save as your 
    lasting record of what happened?

1.  Where does your analysis "live"?

## What is real?

As a beginning Python user, it's OK to consider your environment (i.e. the objects listed in the variables pane) "real". However, in the long run, you'll be much better off if you consider your Python scripts as "real". 

With your Python scripts (and your data files), you can recreate the environment. It's much harder to recreate your Python scripts from your environment! You'll either have to retype a lot of code from memory (making mistakes all the way) or you'll have to carefully mine your Python history. There's nothing worse than discovering three months after the fact that you've only stored the results of an important calculation in your workspace, not the calculation itself in your code. 

## Where does your analysis live?

VS Code's interactive Python has a powerful notion of the __working directory__. This is where Python looks for files that you ask it to load, and where it will put any files that you ask it to save. The interactive console will default the working directory to the location of your `.py` script.

And you can print this out in Python code by running `os.getcwd()`:


```python
import os
os.getcwd()
#> '/Users/hathawayj/git/byuidatascience/python4ds'
```

As a beginning Python user, it's OK to let your home directory, documents directory, or any other weird directory on your computer be Python's working directory. But you're six chapters into this book, and you're no longer a rank beginner. Very soon now you should evolve to organising your analytical projects into directories and, when working on a project, setting Python's working directory to the associated directory.

__I do not recommend it__, but you can also set the working directory from within Python:


```python
os.chdir("/path/to/my/CoolProject")
```

But you should never do this because there's a better way; a way that also puts you on the path to managing your Python data science work like an expert.

## Paths and directories

Paths and directories are a little complicated because there are two basic styles of paths: Mac/Linux and Windows. There are three chief ways in which they differ:

1.  The most important difference is how you separate the components of the
    path. Mac and Linux uses slashes (e.g. `plots/diamonds.pdf`) and Windows
    uses backslashes (e.g. `plots\diamonds.pdf`). Python can work with either type
    (no matter what platform you're currently using), but unfortunately, 
    backslashes mean something special to Python, and to get a single backslash 
    in the path, you need to type two backslashes! That makes life frustrating, 
    so I recommend always using the Linux/Mac style with forward slashes.

1.  Absolute paths (i.e. paths that point to the same place regardless of 
    your working directory) look different. In Windows they start with a drive
    letter (e.g. `C:`) or two backslashes (e.g. `\\servername`) and in
    Mac/Linux they start with a slash "/" (e.g. `/users/hadley`). You should
    __never__ use absolute paths in your scripts, because they hinder sharing: 
    no one else will have exactly the same directory configuration as you.

1.  The last minor difference is the place that `~` points to. `~` is a
    convenient shortcut to your home directory. Windows doesn't really have 
    the notion of a home directory, so it instead points to your documents
    directory.

## VS Code workspaces

<!-- https://code.visualstudio.com/docs/python/data-science-tutorial -->

Python experts keep all the files associated with a project together --- input data, R scripts, analytical results, figures. This is such a wise and common practice that VS Code has built-in support for this via __workspaces__.

Let's make a workspace for you to use while you're working through the rest of this book. Click File > Open and select a newly created folder for your work. New Project, then:

Name your folder `python4ds` and think carefully about which _subdirectory_ you put the folder in. If you don't store it somewhere sensible, it will be hard to find it in the future!

Once this process is complete, you'll get a new VS Code workspace just for this book. Under the Welcome screen select 'New File' and save the file, calling it "diamonds.py". Upon saving the file as a Python file VS Code will make sure your workspace is setup to work with Python with a few prompts.

Check that the "home" directory of your workspace is the current working directory:


```python
import os
os.getcwd()
#> '/Users/hathawayj/Downloads/python4ds'
```

Whenever you refer to a file with a relative path it will look for it here. 

Now enter the following commands in the script editor, and save the file, calling it "diamonds.py". Next, run the complete script which will save a PNG, CSV, and JSON file into your project directory. Don't worry about the details, you'll learn them later in the book.


```python
import pandas as pd 
import altair as alt 

alt.data_transformers.enable('json')

url_path = "https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/diamonds/diamonds.csv"

diamonds = pd.read_csv(url_path)

chart = (alt.Chart(diamonds).
    mark_circle().
    encode(
        x = alt.X("carat", bin=True),
        y = alt.Y("price", bin=True),
        size = "count()"
    )
    )
    
chart.save("diamonds.png")

diamonds.to_csv("diamonds.csv")

```

Inspect the folder associated with your project --- notice the `.vscode` folder. Double-click that folder to see the default workspace settings for your project. You can [read more about VS code workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces) to understand the other available options. 

In your favorite OS-specific way, search your computer for `diamonds.png` and you will find the PNG (no surprise) but _also the script that created it_ (`diamonds.py`). This is huge win! One day you will want to remake a figure or just understand where it came from. If you rigorously save figures to files __with Python code__ and never with the mouse or the clipboard, you will be able to reproduce old work with ease!

## Summary

In summary, VS Code workspaces give you a solid workflow that will serve you well in the future:

* Create an workspace for each data analysis project. 

* Keep data files there; we'll talk about loading them into Python in 
  [data import].

* Keep scripts there; edit them, run them in bits or as a whole.

* Save your outputs (plots and cleaned data) there.

* Only ever use relative paths, not absolute paths.

Everything you need is in one place, and cleanly separated from all the other projects that you are working on.
