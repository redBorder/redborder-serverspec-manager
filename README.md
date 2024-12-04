## redborder-serverspec-manager

Infrastructure integration testing for a redborder manager machine. The idea is to run the tests in a machine that is the validator local machine, so the target machine is affected by the tests.

## Installation

First, clone this repository on your workstation. Then install the gemes by executing this:

```cmd
bundle install
```

Sometimes you need to make sure that you share your public ssh key to target machine:

```cmd
ssh-copy-id root@<target_ip>
```

## Running Tests

To run all tests, use the following command:

```cmd
rake spec
```

Optional parameters:

- **TARGET_HOST**: Machine where the tests will run via SSH.
- **LOGIN_USERNAME**: Username for SSH connection to the test machine.
- **LOGIN_PASSWORD**: Password for SSH connection to the test machine.
- **IS_CLUSTER**: Boolean to indicate if the target machine is a cluster.
- **-j 10 -m**: To run tests in pararell
  Example with optional parameters:

```cmd
IS_CLUSTER="false" TARGET_HOST="10.1.209.50" LOGIN_USERNAME="root" LOGIN_PASSWORD="redborder" rake spec
```

To run a specific test type, use the following command:

```cmd
rake spec:configuration
```

To run a specific test in a spec file, better use tags:

```cmd
rspec --tag tag_name
```

To run a specific script test, use the following command:

```cmd
rspec spec/services/cgroup_spec.rb
```

List of Available Rake Tasks:

```cmd
rake -T
```

## Developing tests

When creating a new test, it is important to follow the directory structure outlined in the Rakefile. This structure helps maintain organization and clarity within the test suite.

Directory structure:

```conf
spec/
├── spec_helper.rb
├── services/
│   ├── ...  # Place your service-related tests here
├── configuration/
│   ├── ...  # Place your configuration-related tests here
├── modules/
│   ├── monitor/
│   ├── ...  # Place your module-related tests here
└── helpers/
    ├── ...  # Place your helper-related tests here
```