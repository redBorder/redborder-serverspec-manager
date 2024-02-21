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

To run a specific test in a spec file, better use tags:
```
rspec --tag tag_name
To run a specific script test, use the following command:
```
rspec spec/services/cgroup_spec.rb 
```

List of Available Rake Tasks:
To view the list of available Rake tasks, use the following command:
```
rake -T
```

## Developing tests

On creating a new test, is important to follow the Rakefile structure as the directory structure.

Directory structure:
```
└── spec/
    ├── spec_helper.rb
    │
    ├── services/
    │   ├── ... > PUT YOUR TESTS HERE
    │
    ├── configuration/
    │   ├── ... > OR HERE
    │
    ├── modules/
    │   ├── monitor
    |       ├── ... > OR HERE
    │
    └── helpers/
        ├── ...         
```

Tag a describe to run by specific command ie:
```
describe ("Any test for this"), :tagname do
```
