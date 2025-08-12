# project-template-aws

This template can be used to initialize a new project using `provider-aws`. By
default it comes with an `XStorageBucket` XRD and a matching composition
function which creates an S3 bucket. It also creates the corresponding unit and
e2e tests.

## Usage

To use this template, run the following command:

```shell
up project init -t upbound/project-template-aws-s3 --language=kcl <project-name>
```

This template supports the following languages:

- `kcl`
- `go`
- `python`
- `go-templating`

