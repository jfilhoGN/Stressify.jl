<div align="center">
  <img src="./img/stressify.png" alt="Julia Performance Testing Logo" width="300px">
</div>

<div align="center">

| Code Coverage | Documentation | Community | Social |
|---------------|---------------|-----------|--------|
| [![codecov](https://codecov.io/gh/jfilhoGN/Stressify.jl/graph/badge.svg?token=JMUM3ITLXK)](https://codecov.io/gh/jfilhoGN/Stressify.jl) | [![Documentation Status](https://readthedocs.org/projects/stressifyjl/badge/?version=latest)](https://stressifyjl.readthedocs.io/en/latest/) | [![Gitter](https://img.shields.io/gitter/room/DAVFoundation/DAV-Contributors.svg?style=flat-square)](https://app.gitter.im/#/room/#stressify:gitter.im) | [![X Badge](https://img.shields.io/badge/follow-%40Stressify-blue?style=flat-square&logo=x)](https://x.com/Stressifyjl) |

</div>


# Stressify Performance Test

**Stressify Performance Test** is a performance testing tool written in Julia, inspired by tools like K6. Its primary focus is on collecting, analyzing, and generating customizable metrics to help developers gain deeper insights into the performance of APIs under various load conditions. With Stressify, you can easily track performance indicators and extend the tool to create new metrics tailored to your needs.

## 🚀 Features

- **Highly Configurable**: Adjust virtual users (VUs), ramp-up phases, iterations, and durations to suit your needs.
- **Multiple HTTP Methods**: Supports GET, POST, PUT, PATCH, and DELETE requests.
- **Custom Checks**: Validate API responses with user-defined conditions for flexible testing.
- **Detailed Metrics**: Includes success rates, error rates, percentile response times (P90, P95, P99), RPS, and TPS.

---

## 📦 Installation

### Prerequisites

Ensure you have [Julia](https://julialang.org/downloads/) installed on your system.

### Steps

1. In Julia REPL:
```bash
using Pkg
Pkg.add("Stressify")
```
After installation in your code:

```julia
using Stressify

#execute for the one VU for one iteration
Stressify.options(
    vus = 1,           
    iterations = 1,    
    duration = nothing  
)

results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
)

```
---

## 📦 Using Stressify with Docker

To run Stressify without installing anything locally, use Docker:

```bash
docker pull jfilhogn/stressify:latest
docker run --rm jfilhogn/stressify:latest script.jl
```

Running the docker image this way will execute the script you want to run, making it easier to execute. In the directory `./docker` you can find the Dockerfile and the script.jl file that is used to run the image as example.

## 🛠 Usage

### Example Test Script

Here's an example demonstrating how to use **Stressify** for performance testing:

```julia
using Stressify

# Configure test options
Stressify.options(
    vus = 5,                     # Number of Virtual Users
    format = "vus-ramping",      # Ramp-up mode
    ramp_duration = 10.0,        # Ramp-up duration (seconds)
    max_vus = 15,                # Maximum Virtual Users
    duration = 60.0              # Test duration (seconds)
)

# Run the test
results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get")  # Target API endpoint
)
```

---

## 📊 Metrics

After a test completes, you'll get detailed performance metrics, including:

- **Iterations**: Total number of requests executed.
- **Success Rate**: Percentage of successful requests.
- **Error Rate**: Percentage of failed requests.
- **Response Times**: Min, Max, Mean, Std, Median, P90, P95, P99.
- **RPS**: Requests per second.
- **TPS**: Transactions per second.

These results are available in the terminal.

---

## 🤝 Contributing

Contributions are welcome! To get started:

1. Fork this repository.
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature-name
   ```
3. Make your changes and test them.
4. Commit your changes:
   ```bash
   git commit -m "Description of your changes"
   ```
5. Push the branch and create a pull request.

For major changes, please open an issue first to discuss your proposal or enter in our community in this link [Community](https://app.gitter.im/#/room/#stressify:gitter.im) , you will be welcome.

---

## 📝 License

This project is licensed under the MIT License.

---

Happy Testing! 🚀
