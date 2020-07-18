import altair as alt
import pandas as pd
import numpy as np
alt.data_transformers.enable('json')


diamonds = pd.read_csv("https://github.com/byuidatascience/data4python4ds/raw/master/data-raw/diamonds/diamonds.csv")

smaller = diamonds.query('carat <= 2.5')

chart = (alt.Chart(smaller).
    encode(alt.X('carat'), alt.Y('count()')).
    mark_line())

chart.save('markdown/diamonds_25.png')
