local data = import 'build/graphdata.jsonnet';

local colors = ['#2aa198', '#95e1f4'];
local color_green = '#859900';
local color_red = '#cb4b16';
local color_blue = '#268bd2';
local color_orange = 'orange';
local legend = { position: 'bottom', labels: { usePointStyle: 'true' }, align: 'start' };
local legend_reversed = { position: 'bottom', labels: { usePointStyle: 'true' }, align: 'start', 'reverse': true};

{
  new_cases: {
    type: 'line',
    data: {
      labels: data.new_cases.labels,
      datasets: [
        {
          data: data.new_cases.deaths,
          label: 'Übermittelte Todesfälle',
          showLine: true,
          backgroundColor: color_red,
          borderColor: color_red,
          pointBackgroundColor: color_red,
        },
        {
          data: data.new_cases.trend,
          label: 'Tendenz Bestätigte Neuinfektionen',
          pointRadius: 0,
          backgroundColor: 'transparent',
          borderColor: color_orange,
          borderWidth: 5,
          pointBackgroundColor: color_orange,
          borderDash: [
            12,
            5,
          ],
        },
        {
          data: data.new_cases.raw,
          label: 'Übermittelte Bestätigte Neuinfektionen',
          showLine: true,
          backgroundColor: '#eee',
          borderColor: '#ddd',
          pointBackgroundColor: '#ddd',
        },
      ],
    },
    options: {
      legend: legend,
      scales: {
        yAxes: [
          {
            ticks: {
            },
          },
        ],
      },
    },
  },
  deaths: {
    type: 'pie',
    data: {
      labels: [
        'Gesamt Infiziert',
        'Todesfall',
      ],
      datasets: [
        {
          backgroundColor: [color_orange, color_red],
          borderWidth: 0,
          data: [
            data.deaths.infections,
            data.deaths.deaths,
          ],
        },
      ],
    },
    options: {
      legend: legend,
    },
  },
  gender: {
    type: 'pie',
    data: {
      labels: [
        'Todesfall Frau',
        'Todesfall Mann',
      ],
      datasets: [
        {
          backgroundColor: [
            color_red,
            'white',
          ],
          borderColor: color_red,
          data: [
            data.gender.F,
            data.gender.M,
          ],
        },
      ],
    },
    options: {
      legend: legend,
    },
  },
  deaths_by_age: {
    type: 'bar',
    data: {
      labels: [
        'bis 34 Jahre',
        '35 bis 59 Jahre',
        '60 bis 79 Jahre',
        'Über 80 Jahre',
      ],
      datasets: [
        {
          backgroundColor: color_red,
          borderWidth: 0,
          label: 'Todesfall',
          data: [
            data.deaths_by_age['0-34'],
            data.deaths_by_age['35-59'],
            data.deaths_by_age['60-79'],
            data.deaths_by_age['80+'],
          ],
        },
      ],
    },
    options: {
      legend: {display: false},
      scales: {
        xAxes: [
          {
            gridLines: {
              display: false,
            },
          },
        ],
        yAxes: [
          {

            scaleLabel: {
              display: true,
              labelString: 'Todesfälle',
            },
          },
        ],
      },
    },
  },
  states: {
    type: 'bar',
    data: {
      labels: data.states.labels,
      datasets: [
        {
          data: data.states.deaths,
          label: 'Todesfall',
          backgroundColor: color_red,
          borderWidth: 0,
        },
      ],
    },
    options: {
      legend: {display: false},
      scales: {
        xAxes: [
          {
            gridLines: {
              display: false,
            },
          },
        ],
        yAxes: [
          {

            scaleLabel: {
              display: true,
              labelString: 'Todesfälle',
            },
          },
        ],
      },
    },
  },
  countries: {
    type: 'bar',
    data: {
      labels: data.countries.labels,
      datasets: [
        {
          data: data.countries.recovered,
          label: 'Wieder Gesund',
          backgroundColor: color_green,
          borderWidth: 0,
        },
        {
          data: data.countries.active,
          label: 'Gerade Infiziert',
          backgroundColor: color_orange,
          borderWidth: 0,
        },
        {
          data: data.countries.deaths,
          label: 'Todesfall',
          backgroundColor: color_red,
          borderWidth: 0,
        },
      ],
    },
    options: {
      tooltips: {
          mode: 'index'
      },
      legend: legend,
      scales: {
        xAxes: [
          {
            gridLines: {
              display: false,
            },
            stacked: true,
          },
        ],
        yAxes: [
          {
            gridLines: {
              display: false,
            },
            stacked: true,
          },
        ],
      },
    },
  },
  age_gender: {
    type: 'bar',
    data: {
      labels: data.age_gender.labels,
      datasets: [
        {
          data: data.age_gender.male,
          label: 'Male',
          backgroundColor: 'blue',
        },
        {
          data: data.age_gender.female,
          label: 'Female',
          backgroundColor: 'magenta',
        },
      ],
    },
    options: {
      responsive: true,
      tooltips: {
        mode: 'index',
        intersect: true,
      },
    },
  },

  deaths_all_countries: {
    type: 'horizontalBar',
    data: {
        labels: data.deaths_all_countries.labels,
        datasets: [{
            backgroundColor: data.deaths_all_countries.countries[country].color,
            hoverBackgroundColor: self.backgroundColor,

            borderColor: 'white',
            borderWidth: 1,

            //pointRadius: 8,
            label: country,
            //pointBackgroundColor: self.borderColor,
            //borderColor: data.deaths_all_countries.countries[country].color,
            data: data.deaths_all_countries.countries[country].values,
            order: data.deaths_all_countries.countries[country].order,
        } for country in std.objectFields(data.deaths_all_countries.countries)]
    },
    options: {
      tooltips: {mode: 'nearest'},
      legend: {display: false},
      scales: {
        yAxes: [{
            ticks: {
                reverse: true
            },
            stacked: true,
            gridLines: {
              //display: false,
            },
            scaleLabel: {
              display: true,
              labelString: 'Kalenderwoche',
           },
        }],
        xAxes: [{
            stacked: true,
            gridLines: {
              //display: false,
            },
            scaleLabel: {
              display: true,
              labelString: 'Todesfälle',
           },
        }]
      }
    }
  },

  stock_germany: {
    type: 'line',
    data: {
      labels: data.stock_germany.labels,
      datasets: [
        {
          data: data.stock_germany.value,
          label: 'DAX',
          backgroundColor: color_blue,
          pointBackgroundColor: "rgba(0,0,0,0)",
        },
      ],
    },
    options: {
      scales: {
          yAxes: [{
              ticks: {
                  beginAtZero: true
              }
          }]
      },
      legend: {display: false},
    },
  },

  website_hits: {
    type: 'bar',
    data: {
      labels: data.website_hits.labels,
      datasets: [
        {
          data: data.website_hits.value,
          label: 'Seitenaufrufe',
          backgroundColor: color_blue,
          pointBackgroundColor: "rgba(0,0,0,0)",
        },
      ],
    },
    options: {
      scales: {
          yAxes: [{
              ticks: {
                  beginAtZero: true,
                  stepSize: 1,
              }
          }]
      },
      legend: {display: false},
    },
  },
}
