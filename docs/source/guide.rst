.. _guide:

.. _Stressify: https://github.com/jfilhoGN/Stressify.jl/tree/main/examples
.. _Documentation: https://stressifyjl.readthedocs.io/en/latest/
.. _Community: https://app.gitter.im/#/room/#stressify:gitter.im
.. _X(Twitter): https://x.com/Stressifyjl

User Guide
==========

Welcome to the **Stressify.jl** User Guide. This document will walk you through the basic steps of using Stressify for performance testing.

Stressify Performance Testing was created to facilitate the implementation of various types of performance tests and to be an Open Source project with the objective of mitigating the use by both the engineering team, QAOPs and Infrastructure.

Its simple format was designed so that tests can be created in minutes and with the possibility of adding them to continuous testing pipelines.

Finally, using the Julia language, it was also created to facilitate the creation of customized metrics. In our project, the following metrics are mapped:

- **Iterations**: Total number of requests executed.
- **Success Rate**: Percentage of successful requests.
- **Error Rate**: Percentage of failed requests.
- **Response Times**: Min, Max, Mean, Std, Median, P90, P95, P99.
- **RPS**: Requests per second.
- **TPS**: Transactions per second.

However, with Julia's vast mathematical and statistical library, it facilitates the creation of new metrics from the execution return, with a dictionary with all response times.

Installation
================

To install Stressify, you can use the following command:

.. code-block:: bash

    $ julia -e 'using Pkg; Pkg.add("Stressify")'


Quick Start
===========
To start using Stressify, you can use the following code:

.. code-block:: julia

    using Stressify

    # Defined the options for the test, in this case we are using 5 VUs, 10 iterations and no duration
    Stressify.options(
        vus = 5,
        iterations = 10,
        duration = nothing
    )

    # After defining the options, we can run the test using the following code
    results = Stressify.run_test(
        Stressify.http_get("https://httpbin.org/get"),
        Stressify.http_post("https://httpbin.org/post"; payload="{\"key\": \"value\"}", headers=Dict("Content-Type" => "application/json")),
        Stressify.http_put("https://httpbin.org/put"; payload="{\"update\": \"data\"}", headers=Dict("Content-Type" => "application/json")),
        Stressify.http_patch("https://httpbin.org/patch"; payload="{\"patch\": \"data\"}", headers=Dict("Content-Type" => "application/json")),
        Stressify.http_delete("https://httpbin.org/delete")
    )


The code above will run a test with 5 VUs, 10 iterations and no duration. The test will execute 10 iterations of each request, totaling 50 iterations.

The output will be a dictionary with the following structure:

.. code-block:: bash
    
    ================== Stressify ==================
    VUs                    :          5
    Iterações Totais       :         50
    Taxa de Sucesso (%)    :      100.0
    Taxa de Erros (%)      :        0.0
    Requisições por Segundo:      10.55
    Transações por Segundo :      10.55
    Número de Erros        :          0
    ---------- Métricas de Tempo (s) ----------
    Tempo Mínimo           :     0.1609
    Tempo Máximo           :     1.2139
    Tempo Médio            :     0.4026
    Mediana                :     0.3717
    P90                    :     0.7145
    P95                    :      0.793
    P99                    :     1.2139
    Desvio Padrão          :     0.2173
    ---------- Detalhamento de Tempos ----------
    Todos os Tempos (s)    : 1.2139, 0.3449, 0.552, 0.3514, 0.2351, 0.1809, 0.3881, 0.3949, 0.3975, 0.1811, 0.7704, 0.6761, 0.3609, 0.3747, 0.1741, 0.2778, 0.3338, 0.45, 0.3367, 0.1683, 0.8838, 0.3846, 0.3703, 0.5831, 0.1645, 0.4906, 0.3726, 0.3708, 0.3667, 0.1713, 0.793, 0.388, 0.5088, 0.3749, 0.172, 0.1714, 0.3786, 0.3254, 0.369, 0.1609, 0.793, 0.5632, 0.3333, 0.3912, 0.1777, 0.1844, 0.4023, 0.4266, 0.7145, 0.1788
    ==========================================================
    ---------- Resultados dos Checks ----------


Important Links
-------------------

In this links you can find more information about Stressify, enter in our community, it's a pleasure to have you with us.

- `Stressify`_
- `Documentation`_
- `Community`_
- `X(Twitter)`_
