using Pkg: Pkg
Pkg.activate(".")
Pkg.instantiate()
using Stressify

"""
Execute in CLI
export INFLUXDB_TOKEN="your_token"
julia examples/twelfthTest.jl --output=influxdb --influxdb-url="http://localhost:8086" --influxdb-bucket="xxxxx" --influxdb-org="xxxxxx"
"""
#execute for the one VU for one iteration
Stressify.options(
	vus = 1,
	format = "vus-ramping",
	ramp_duration = 5.0,
	max_vus = 10,
	iterations = nothing,
	duration = 10.0,
)

results = Stressify.run_test(
	Stressify.http_get("https://httpbin.org/get"),
)