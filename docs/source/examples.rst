Examples
========

This page provides a detailed overview of the examples included in the **Stressify.jl** project. The examples demonstrate how to use the tool to test and analyze the performance of APIs with various configurations.
The examples are designed to be easy to understand and modify, making them ideal for beginners and experienced users alike, and the examples you can find in the `examples` directory of the project `Stressify`_ repository.

.. _Stressify: https://github.com/jfilhoGN/Stressify.jl/tree/main/examples
.. _Documentation: https://stressifyjl.readthedocs.io/en/latest/

Available Examples
-------------------

1. **FirstTest.jl**
   - **Description**: A basic example showcasing a simple performance test configuration.
   
  **Key Features**:
  
   - Loads API endpoints.
   - Monitors basic performance metrics.
  
  **How to Run**:
    Execute the following command:
    ```
    julia examples/firstTest.jl
    ```
  **Purpose**: Ideal for beginners to understand the basic structure of a performance test.

2. **SecondTest.jl**
   - **Description**: A basic example showcasing how to use iterations and number os VUs.
   
  **Key Features**:
  
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Uses iterations and VUs.
  
  **How to Run**:
    Execute the following command:
    ```
    julia examples/secondTest.jl
    ```
  **Purpose**: Ideal for beginners to understand the basic structure of a performance test and used VUs and iterations. 

3. **ThirdTest.jl**
   - **Description**: Example to use duration in seconds instead of iterations. The code will execute until the duration time.
   
  **Key Features**:
  
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Uses durations and VUs.
  
  **How to Run**:
    Execute the following command:
    ```
    julia examples/thirdTest.jl
    ```
  **Purpose**: Ideal for beginners to understand the basic structure of a performance test and used VUs and duration time of the test. 

4. **FourthTest.jl**
   - **Description**: Example to use many endpoints in the test. Ideal to create scenarios of the test. In Stressify the methods accepted is GET, POST, PUT, DELETE, PATCH.
   
  **Key Features**:
   
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Uses durations and VUs.
   - Uses many endpoints.
   - Uses many methods.
  
  **How to Run**:
    Execute the following command:
    ```
    julia examples/fourthTest.jl
    ```
  **Purpose**: Ideal for beginners to understand the basic structure of a performance test and how to use many methods inside the Stressify. 

5. **FifthTest.jl**
   - **Description**: Example to use the Stressify function to get values in a CSV file. Ideal to execute many requests with many different values
   
  **Key Features**:
  
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Used to get values from a CSV file.
   
  **How to Run**:
    Execute the following command:
    ```
    julia examples/fifthTest.jl
    ```
  **Purpose**: Ideal for understanding how to use the Stressify function to get values from a CSV file and execute many requests with different values. 

6. **SixtyhTest.jl**
   - **Description**: Example to use the Stressify function to get values in a JSON file. Ideal to execute many requests with many different values
   
  **Key Features**:
   
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Used to get values from a JSON file.
  
  **How to Run**:
    Execute the following command:
    ```
    julia examples/sixthTest.jl
    ```
   
   **Purpose**: Ideal for understanding how to use the Stressify function to get values from a JSON file and execute many requests with different values. 

7. **SeventhTest.jl**
   - **Description**: Example to use the Stressify function to checked the return from the endpoint wich you are testing. Check view the return from the endpoint.
   
  **Key Features**:
   
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Check the return from the endpoint.
  
  **How to Run**:
    Execute the following command:
    ```
    julia examples/seventhTest.jl
    ```
  
  **Purpose**: Ideal for API testing and check the return from endpoint are you testing.

8. **EightTest.jl**
   - **Description**: Example of how to use Stressify to create tests that require a ramp-up of virtual users for a certain period of time.
   
  **Key Features**:
   
   - Loads API endpoints.
   - Monitors basic performance metrics.
   - Ramp-up of virtual users from a certain period of time.
   
  **How to Run**:
    Execute the following command:
    ```
    julia examples/eightTest.jl
    ```
  
  **Purpose**: Ideal for API testing and check the return from endpoint are you testing.


How to run the examples? 
------------------------

To run any of the examples, follow these steps:

1. Clone the **Stressify.jl** repository from GitHub.
2. Navigate to the `examples` directory.
3. Run the desired example using the Julia command-line interface.
4. ```julia examples/FirstTest.jl```
5. Monitor the output for test results and performance metrics.
6. Analyze the generated reports to gain insights into the API performance.

Customizing Examples
--------------------

Each example is designed to be easily modified to suit your specific testing needs. Refer to the **API Documentation** for details on available methods, configurations, and metrics.

Feedback and Contributions
---------------------------

We welcome feedback and contributions! If you have ideas for new examples or improvements to the existing ones, feel free to:

- Open an issue in the repository.
- Submit a pull request with your changes.

For further details, visit the `Documentation`_.

