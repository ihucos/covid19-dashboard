import datetime

import yaml
import pandas as pd
import jinja2
from statsmodels.tsa.seasonal import seasonal_decompose
import urllib.request
import re
import hashlib
import random

insights = {}


def export(func):
    def inner():
        val = func()
        if isinstance(val, pd.DataFrame):
            return {
                'index': val.index.tolist(),
                **{k: val[k].tolist() for k in val.columns}}
        return val

    insights[func.__name__] = inner
    return inner


rki = pd.read_csv("build/rki.csv", index_col="date", parse_dates=True)
rki_age = pd.read_csv("build/rki_age.csv", index_col="age")
hopkins = pd.read_csv("build/hopkins.csv", index_col="country")
hopkins_series_deaths = pd.read_csv("build/hopkins_series_deaths.csv", index_col="country", parse_dates=['date'])


@export
def gender():
    return rki.groupby("gender").sum()["deaths"].rename().to_dict()


@export
def deaths():
    return rki[["infections", "deaths"]].sum().to_dict()


@export
def deaths_by_age():
    rki["age_group"] = rki["age_group"].map({
        "A00-A04": "0-34",
        "A05-A14": "0-34",
        "A15-A34": "0-34",
        "A35-A59": "35-59",
        "A60-A79": "60-79",
        "A80+": "80+",
    })

    return rki.groupby("age_group").sum()["deaths"].to_dict()


@export
def new_cases():

    sum = rki.groupby("date")["infections"].sum()
    sum_deaths = rki.groupby("date")["deaths"].sum()

    trend = seasonal_decompose(sum, period=7).trend

    trend[:"2020-03-15"] = trend[:"2020-03-15"].fillna(0)
    trend = trend.dropna()

    # because only data that is about 7 days ago is ok because of "Meldeverzug"
    seven_days_ago = datetime.date.today() - datetime.timedelta(days=7)

    # add a brise of rolling average to it

    trend = trend[:seven_days_ago]

    smooth_trend = trend.rolling(3).mean().fillna(0)

    return {
        "labels": list(str(i.date()) for i in sum.index),
        "raw": [float(i) for i in sum.values],
        "deaths": sum_deaths.tolist(),
        "trend": [float(i) for i in smooth_trend.values],
    }


@export
def states():
    res = (rki.groupby("state").agg("sum").sort_values(
        "deaths", ascending=False)["deaths"].to_dict())
    return {
        "labels": list(res.keys()),
        "deaths": [float(i) for i in res.values()],
    }


@export
def countries():
    ranked_hopkins = hopkins.copy()
    ranked_hopkins["total"] = (
        hopkins["active"] + hopkins["deaths"] + hopkins["recovered"])
    top = ranked_hopkins.sort_values("total", ascending=False)[:10]

    return {
        "labels": top.index.tolist(),
        "active": top.active.tolist(),
        "recovered": top.recovered.tolist(),
        "deaths": top.deaths.tolist(),
    }


@export
def world_stat():
    return hopkins.sum().to_dict()


@export
def age_gender():
    smooth_male = rki_age.male.rolling(3, min_periods=1).mean()
    smooth_female = rki_age.female.rolling(3, min_periods=1).mean()
    return {
        "labels": rki_age.index.tolist(),
        "female": smooth_female.tolist(),
        "male": smooth_male.tolist(),
    }


def to_color(string):
    rand = random.Random()
    rand.seed(string)

    hue = rand.randint(0, 360)
    saturation = rand.randint(0, 100)
    lightness = rand.randint(35, 80)
    return f'hsl({hue}, {saturation}%, {lightness}%)'


@export
def deaths_all_countries():
    num_show_in_graphs = 100000
    rest_label = "Restliche Länder"

    df = hopkins_series_deaths.copy()

    df = df.sort_values(['country', 'date'])

    # undo the accumulative sum - we want reported cases per date
    df.value = df.value - df.groupby('country').value.shift(1, fill_value=0)

    # in Iceland there was one bogus entry with 4 deaths that we intent to
    # ignore with this line
    df.value = df.value.clip(0)

    # group by week
    df.date = df.date.dt.week

    # the last week is not complete
    df = df[df.date != df.date.max()]

    df = df.groupby(["country", "date"]).sum().reset_index().set_index('country')

    # how many countries to sho in the graph

    by_biggest = df.groupby('country').value.sum().sort_values(ascending=False)
    by_biggest.name = 'sum'
    top = by_biggest[:num_show_in_graphs]
    bottom = by_biggest[num_show_in_graphs:]


    merged_top = df.merge(top, left_index=True, right_index=True)
    merged_bottom = df.merge(bottom, left_index=True, right_index=True)
    rest_countries = merged_bottom.groupby(['date']).sum().reset_index()
    rest_countries.index = len(rest_countries.index) * [rest_label]
    rest_countries.index.name = 'country'
    chart = pd.concat([merged_top.reset_index(), rest_countries.reset_index()]).set_index('country')

    vals_by_country = {}
    for country in chart.index.unique():
        values = [float(i) for i in chart.value[chart.index == country].to_list()]
        vals_by_country[country] = {
            'values': values,
            'order': values[-1] if country != rest_label else 0,
            'color': to_color(country),
        }
    return {
        'labels': [f'KW {i}' for i in chart.date.unique()],
        'countries': vals_by_country
    }


@export
def stock_germany():
    df = pd.read_csv("build/stock_germany.csv")
    return {
        'labels': df.Date.to_list(),
        'value': df.Close.to_list()
    }

@export
def website_hits():
    df = pd.read_csv("build/website_hits.csv")
    return {
        'labels': df.date.to_list(),
        'value': df.views.to_list()
    }

@export
def destatis_consumer():
    return open('build/destatis_consumer.txt').readlines()

@export
def destatis_unemployment():
    return open('build/destatis_unemployment.txt').readlines()
