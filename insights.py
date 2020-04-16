import datetime

import yaml
import pandas as pd
import jinja2
from statsmodels.tsa.seasonal import seasonal_decompose

insights = {}
def export(func):
    def inner():
        val = func()
        return val
    insights[func.__name__] = inner
    return inner


df = pd.read_csv("build/rki.csv", index_col="date", parse_dates=True)
hopkins = pd.read_csv("build/hopkins.csv", index_col="country")


@export
def gender():
    return df.groupby("gender").sum()["deaths"].rename().to_dict()


@export
def deaths():
    return df[["infections", "deaths"]].sum().to_dict()


@export
def deaths_by_age():
    df["age_group"] = df["age_group"].map(
        {
            "A00-A04": "0-34",
            "A05-A14": "0-34",
            "A15-A34": "0-34",
            "A35-A59": "35-59",
            "A60-A79": "60-79",
            "A80+": "80+",
        }
    )

    return df.groupby("age_group").sum()["deaths"].to_dict()


@export
def new_cases():

    sum = df.groupby("date")["infections"].sum()
    sum_deaths = df.groupby("date")["deaths"].sum()

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
    res = (
        df.groupby("state")
        .agg("sum")
        .sort_values("deaths", ascending=False)["deaths"]
        .to_dict()
    )
    return {
        "labels": list(res.keys()),
        "deaths": [float(i) for i in res.values()],
    }


@export
def countries():
    ranked_hopkins = hopkins.copy()
    ranked_hopkins["total"] = (
        hopkins["active"] + hopkins["deaths"] + hopkins["recovered"]
    )
    top = ranked_hopkins.sort_values("total", ascending=False)[:10]

    return {
        "labels": top.index.tolist(),
        "active": top.active.tolist(),
        "recovered": top.recovered.tolist(),
        "deaths": top.deaths.tolist(),
    }
