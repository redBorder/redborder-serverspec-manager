## redborder-serverspec-manager
Infrastructure integration testing for redborder-manager

## Installation
On your workstation, execute the following command in your terminal:
```ssh
bundle install
```

## Running Tests
To run all tests, use the following command:
```
rake spec
```

Optional parameters:
* TARGET_HOST: Machine where the tests will run via SSH.
* LOGIN_USERNAME: Username for SSH connection to the test machine.
* LOGIN_PASSWORD: Password for SSH connection to the test machine.
* -j 10 -m: To run tests in pararell
Example with optional parameters:
```
TARGET_HOST="10.1.209.50" LOGIN_USERNAME="root" LOGIN_PASSWORD="redborder" rake spec
```

To run a specific test type, use the following command:
```
rake spec:configuration
```

List of Available Rake Tasks:
To view the list of available Rake tasks, use the following command:
```
rake -T
```

## Developing tests

On creating a new test, is important to follow the Rakefile structure as the directory structure.

Directory structure:

└── spec/
    ├── spec_helper.rb
    │
    ├── services/
    │   ├── ... > PUT YOUR TESTS HERE
    │
    ├── configuration/
    │   ├── ... > OR HERE
    │
    └── helpers/
        ├── ...         
