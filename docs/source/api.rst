.. _api:

API Reference
=============

This section provides detailed documentation of the Stressify.jl API.

Functions
---------

.. function:: run_test(endpoint::String; payload::String, method::String, headers::Dict)

   Run a performance test against the specified API.

   :param endpoint: The API endpoint to test.
   :param payload: The JSON payload to send with the request.
   :param method: The HTTP method (e.g., "GET", "POST").
   :param headers: A dictionary of headers to include in the request.
   :returns: A dictionary containing the test results.

.. function:: generate_report(results::Dict)

   Generate a detailed report from test results.

   :param results: The results dictionary from a test run.
   :returns: A JSON string representing the report.
