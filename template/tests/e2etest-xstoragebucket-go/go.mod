module github.com/upbound/project-template-aws-s3/tests/e2etest-bucket

go 1.23.0

require (
	dev.upbound.io/models v0.0.0
	k8s.io/utils v0.0.0-20241104163129-6fe5fd82f078
	sigs.k8s.io/yaml v1.4.0
)

require (
	github.com/apapsch/go-jsonmerge/v2 v2.0.0 // indirect
	github.com/google/uuid v1.4.0 // indirect
	github.com/oapi-codegen/runtime v1.1.0 // indirect
)

replace dev.upbound.io/models => ../../.up/go/models
