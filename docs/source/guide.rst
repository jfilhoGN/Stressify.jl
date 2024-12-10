.. _guide:

.. _Stressify: https://github.com/jfilhoGN/Stressify.jl/tree/main/examples
.. _Documentation: https://stressifyjl.readthedocs.io/en/latest/
.. _Community: https://app.gitter.im/#/room/#stressify:gitter.im

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

Important Links
-------------------

In this links you can find more information about Stressify, enter in our community, it's a pleasure to have you with us.

- `Stressify`_
- `Documentation`_
- `Community`_
