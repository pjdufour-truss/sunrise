# Sunrise

Continuous Integration / Continuous Deployment Workshop by Truss Works.

## Usage

Install prerequisite command line programs.

```shell
make prereqs
```

Start Docker cluster.

```shell
make up
```

Stop Docker cluster.

```shell
make down
```

### Configuration

Add configuration to deployed environment

```shell
aws-vault exec $AWS_PROFILE -- chamber write "sunrise-prod" "app_debug" "false"
```

### Tests

Run End-To-End JavaScript tests.

```shell
make e2e_tests
```

Run unit tests.

```shell
make unit_tests
```

Run unit tests against a deployed environment

```shell
aws-vault exec $AWS_PROFILE -- chamber exec "sunrise-prod" -- make unit_tests
```

Run server tests.

```shell
make server_tests
```

### Deployment

Plan

```shell
aws-vault exec $AWS_PROFILE -- terraform plan
```

Apply

```shell
aws-vault exec $AWS_PROFILE -- terraform apply
```
