Article: Stressify.jl Performance Testing
=========================================

Introduction
------------

For about two years now, I've been working as a QA Specialist at Grupo Casas Bahia, focusing exclusively on Performance Testing to ensure that the company's applications are ready to handle a high volume of users without compromising usability.

Throughout my journey (including my time at other companies as a QA), I've worked with various performance testing tools like JMeter, Gatling, Locust, and K6, always noticing the pros and cons of each. As we know, in software development, there's no silver bullet; each tool fits better according to the needs of a specific project or company.

After spending some time with K6, I started to participate more actively in the Grafana K6 community (I recommend everyone who masters a particular tool to do this), because not only do you continue to learn from interesting questions, but you also help other professionals with your experience.

In this community, I began to notice that one of the major points professionals, whether QAs or from other areas, were looking for was ways to generate data from test execution, moving beyond standard results like throughput requests, response time, error requests to statistical data like mean, median, P(90), P(95), standard deviation, etc. This led me to the idea: how can I create a performance testing tool that, besides being performant in its execution, can provide more statistical insights for the professional, as well as offering the freedom to generate new metrics through its language? Thus, Stressify.jl was born, which is the subject of today's text.

Julia Programming Language
----------------------------

After the introduction, I thought to explain why the Julia programming language?

I first encountered the Julia language in 2016 during a scientific initiation at the Federal Technological University of Paraná, where our aim was to mitigate the use of open-source tools for numerical and scientific calculations, and during the initiation, I realized how powerful the language is.

Julia was created by Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and Alan Edelman, and was publicly released in 2012. The main goal of Julia is to combine the ease of use of languages like Python and R with the performance of low-level languages like C and Fortran. It is particularly popular in the scientific community due to its ability to handle large volumes of data and complex calculations efficiently.

**Main Features:**
- **Performance:** Julia is compiled just-in-time (JIT), which means code is compiled at runtime, allowing performance close to statically compiled languages.
- **Ease of Use:**Julia's syntax is clear and expressive, making it accessible for programmers of different experience levels.
- **Parallelism and Concurrency:** Julia has native support for parallel and concurrent programming, facilitating the use of multiple CPU cores or even GPUs.
- **Dynamic Type System:** Despite being dynamic, Julia allows optional type declarations, which can enhance performance when necessary.
- **Package Ecosystem:** Julia has a robust package manager called Pkg, with a wide variety of packages for various applications, especially in data science, statistics, and machine learning.

Now that I've introduced a bit more about the Julia programming language and why it's used, I'll show you how to use the Stressify.jl tool.

How to Use Stressify.jl?
-------------------------

The first point I want to bring to you is that the tool's focus is on being easy to install, develop with, execute, and generate reports.

Installation
------------

As mentioned in the Julia language section about the package ecosystem, Julia has an active and democratic community, facilitating package creation and use. Thus, for Stressify, here's what you need:
Install the Julia language Julia: The documentation is very clear, and the language is available for all operating systems, from Linux to Windows; the link above includes how to download and install.
After installing Julia, create a folder where you'll add your test scripts, and in the terminal, type the command julia, and you'll access the language's interpreter part, your terminal will look like this:

.. code-block:: bash

    julia> 

Inside the Julia REPL, type using Pkg and then Pkg.add("Stressify") wait a few minutes, and the tool will be installed.
Now let's develop the scripts!

Using Docker
------------

If you're familiar with Docker and have it installed on your machine, it's even simpler; just run the command `docker pull jfilhogn/stressify:latest`` to download the official Stressify tool image. Once downloaded, within the directory where you developed the scripts (which will be explained in the next topic), run the command `docker run --rm jfilhogn/stressify:latest yourscript.jl`, and you'll be running your test!

Creating the Scripts
--------------------

For this text, I'll present a basic script for understanding, breaking down each part of the code by topics. First, we'll import the library.

.. code-block:: julia

    using Stressify 

After importing the library, we'll declare the options, which are the settings we want for the test, like the number of VUs, how many iterations it will perform, or if it will run by duration. For this example, we'll use iterations.

.. code-block:: julia

    using Stressify

    Stressify.options(
        vus = 5,
        iterations = 10,
        duration = nothing
    )

In the code above, we set our test to run with 5 simultaneous users, and each VU will iterate through the requests 10 times, so the endpoint being stressed will receive a total of 50 requests.

After setting the options, let's make the calls; here's the following part of the code:

.. code-block:: julia

    using Stressify

    Stressify.options(
        vus = 5,
        iterations = 10,
        duration = nothing
    )

    results = Stressify.run_test(
        Stressify.http_get("https://httpbin.org/get"),
        Stressify.http_post("https://httpbin.org/post"; payload="{\"key\": \"value\"}", headers=Dict("Content-Type" => "application/json")),
    )

We declare a variable results which will receive a dictionary with all the results and metrics that the test will bring back; to get this information, we use the run_test function which takes the requests to be made inside it, in this example, one GET and one POST request. Your first script is ready!

To run the test, just type in the terminal the command julia yourscript.jl, and the output will be something very close to this:

.. code-block:: bash

    ================== Stressify ==================
        VUs                    :          5
        Total Iterations       :         50
        Success Rate (%)       :      100.0
        Error Rate (%)         :        0.0
        Requests per Second    :       8.79
        Transactions per Second:       8.79
        Number of Errors       :          0

    ---------- Time Metrics (s) ----------
        Minimum Time           :     0.1744
        Maximum Time           :     1.5394
        Average Time           :     0.4666
        Median                 :      0.394
        P90                    :     0.8338
        P95                    :     0.9099
        P99                    :     1.5394
        Standard Deviation     :     0.2872

    ---------- Time Details ----------
        All Times (s)          : 1.3297, 0.3898, 0.5772, 0.5987, 0.5519, 0.3595, 0.1788, 0.3945, 0.1823, 0.3955, 0.8338, 0.8836, 0.1757, 0.7192, 0.5078, 0.3386, 0.6884, 0.3439, 0.1789, 0.3843, 1.5394, 0.3353, 0.1744, 0.4752, 0.2206, 0.3373, 0.6098, 0.3367, 0.1763, 0.7549, 0.9099, 0.389, 0.1791, 0.3985, 0.4764, 0.3511, 0.1815, 0.5019, 0.1785, 0.3935, 0.9097, 0.3951, 0.1823, 0.3905, 0.5544, 0.6412, 0.3959, 0.354, 0.1812, 0.3958
    ==========================================================

    ---------- Check Results ----------

Here comes the key point of the tool, the transparency of all results we had during execution, bringing data on minimum, maximum, average time, median, P90, P95, P99, and Standard Deviation. Finally, it provides a detailed list of all times generated, and if your code has response checks, you'll see those results as well!

You might wonder, isn't this result similar to other testing tools? However, the big differentiator of Stressify is using the Julia language and having built-in statistical tools; suppose you want to know the variance of these requests, you just need to add these three lines of code:

.. code-block:: julia
    
    using Statistics
    variance = var(results["all_times"])
    println("Variance: ", variance)

So, the main focus of the tool is to leverage all that Julia has to offer for generating performance metrics.

The idea of today's text was to kickstart how to use the Stressify tool. I am working daily to bring more improvements to you; those mapped for future versions are detailed in the next topic.

For the Future!
----------------

- **Request Funnel:** One of the main points of performance testing is to ensure the test mimics what happens in real life, and the request funnel is crucial, necessary to ensure endpoint X receives the correct percentage of requests compared to request Y.
- **Live Dashboard:** Julia has excellent tools focused on dashboards and graphical views; for future versions, I'll introduce a format where, from execution, you can see a graphical view of the test execution with a report.
- **GPU Use:** The language has GPU integration, and in this sense, nothing more interesting than using GPU VUs for each request.

And more innovations on the way!

That's it, folks, this first article I bring about this novelty, and I await your comments on how you've used it. Finally, if you liked the article, give it a Star on GitHub; it helps a lot in discerning the tool within Julia packages.