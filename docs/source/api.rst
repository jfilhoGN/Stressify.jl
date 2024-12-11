.. _api:

API Reference
=============

This section provides detailed documentation of the Stressify.jl API.

Functions
---------

.. function:: options(; vus::Int=1, format::String="default", ramp_duration::Union{Float64, Nothing}=nothing, max_vus::Union{Int, Nothing}=nothing, iterations::Union{Int, Nothing}=nothing, duration::Union{Float64, Nothing}=nothing, noDebug::Bool=false)
   
   Determine the test configuration options, such as the number of virtual users (VUs), format, ramp duration, maximum VUs, iterations, and duration.
   
   :param vus: The number of virtual users to simulate.
   :param format: The format of the test execution "vus-ramping".
   :param ramp_duration: The duration of the ramp-up period.
   :param max_vus: The maximum number of virtual users to simulate.
   :param iterations: The number of iterations to run. Don`t use with format "vus-ramping".
   :param duration: The duration of the test in seconds.
   :param noDebug: Disable debug mode.

.. function:: run_test(requests::Vararg{NamedTuple}

   Run a performance test using the specified configuration.

   :param requests: A list of named tuples representing the test configuration.


Support HTTP methods
--------------------

.. function:: http_get(endpoint::String; headers::Dict)

   Send an HTTP GET request to the specified endpoint.

   :param endpoint: The API endpoint to test.
   :param headers: A dictionary of headers to include in the request.
   :returns: A dictionary containing the test results.

.. function:: http_post(endpoint::String; payload::String, headers::Dict)
   
      Send an HTTP POST request to the specified endpoint.
   
      :param endpoint: The API endpoint to test.
      :param payload: The JSON payload to send with the request.
      :param headers: A dictionary of headers to include in the request.
      :returns: A dictionary containing the test results.

.. function:: http_put(endpoint::String; payload::String, headers::Dict)
      
      Send an HTTP PUT request to the specified endpoint.
      
      :param endpoint: The API endpoint to test.
      :param payload: The JSON payload to send with the request.
      :param headers: A dictionary of headers to include in the request.
      :returns: A dictionary containing the test results.

.. function:: http_delete(endpoint::String; headers::Dict)
         
      Send an HTTP DELETE request to the specified endpoint.
   
      :param endpoint: The API endpoint to test.
      :param headers: A dictionary of headers to include in the request.
      :returns: A dictionary containing the test results.

.. function:: http_patch(endpoint::String; payload::String, headers::Dict)
            
      Send an HTTP PATCH request to the specified endpoint.
   
      :param endpoint: The API endpoint to test.
      :param payload: The JSON payload to send with the request.
      :param headers: A dictionary of headers to include in the request.
      :returns: A dictionary containing the test results.


Report Generation
-----------------

.. function:: generate_report(results::Dict)

   Generate a detailed report from test results.

   :param results: The results dictionary from a test run.
   :returns: A JSON string representing the report.

.. function:: save_results_to_json(results::Dict, filepath::String)
   
   Save the test results to a JSON file.

   :param results: The results dictionary from a test run.
   :param filepath: The path to the output file.

Data Utils
----------

.. function:: random_csv_row(file_path::String)
   
   Get a random row from a CSV file.

   :param file_path: The path to the CSV file.
   :returns: A dictionary representing a row from the CSV file.

.. function:: random_json_row(file_path::String)
      
   Get a random row from a JSON file.

   :param file_path: The path to the JSON file.
   :returns: A dictionary representing a row from the JSON file.