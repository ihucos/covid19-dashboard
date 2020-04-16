import subprocess
import jinja2

data = subprocess.check_output(["jsonnet", "graphs.jsonnet"]).decode()

with open("build/bootstrap.min.css") as f:
    bootstrap_css = f.read()

with open("build/Chart.min.js") as f:
    chart_js = f.read()

with open("index.html.jinja2") as file_:
    template = jinja2.Template(file_.read())
index_html = template.render(
    data=data, bootstrap_css=bootstrap_css, chart_js=chart_js
)
with open("docs/index.html", "w") as out:
    out.write(index_html)
