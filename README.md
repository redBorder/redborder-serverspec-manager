## redborder-serverspec-manager
Infrastructure integration testing for a redborder manager machine. The idea is to run the tests in a machine that is the validator local machine, so the target machine is affected by the tests.

## Installation
First, clone this repository on your workstation. Then install the gemes by executing this:
```ssh
bundle install
```
Sometimes you need to make sure that you share your public ssh key to target machine:
```
ssh-copy-id root@<target_ip>
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
* IS_CLUSTER: Boolean to indicate if the target machine is a cluster.
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
