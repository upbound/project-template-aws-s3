import models.com.example.platform.v1alpha1 as platformv1alpha1
import models.io.upbound.aws.s3.v1beta1 as s3v1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name="test-xstoragebucket-kcl"
        spec= {
            assertResources: [
                platformv1alpha1.XStorageBucket{
                    metadata.name: "example-kcl"
                    spec: {
                        parameters: {
                            acl: "public-read"
                            region: "us-west-1"
                            versioning: True
                        }
                        compositionSelector:{
                            matchLabels: {
                                language: "kcl"
                            }
                        }
                    }
                }
                s3v1beta1.BucketACL{
                    metadata.name: "example-kcl-acl"
                    spec.forProvider:{
                        acl: "public-read"
                        bucketRef: {
                            name: "example-kcl-bucket"
                        }
                        region: "us-west-1"
                    }
                }
                s3v1beta1.BucketOwnershipControls{
                    metadata.name: "example-kcl-boc"
                    spec.forProvider: {
                        bucketRef: {
                            name: "example-kcl-bucket"
                        }
                        region: "us-west-1"
                        rule: [
                            {
                                objectOwnership: "BucketOwnerPreferred"
                            }
                        ]
                    }
                }
                s3v1beta1.Bucket{
                    metadata.name: "example-kcl-bucket"
                    spec.forProvider: {
                        region: "us-west-1"
                    }
                }
                s3v1beta1.BucketServerSideEncryptionConfiguration{
                    metadata.name: "example-kcl-encryption"
                    spec.forProvider: {
                        bucketRef: {
                            name: "example-kcl-bucket"
                        }
                        region: "us-west-1"
                        rule: [
                            {
                                applyServerSideEncryptionByDefault: [
                                    {
                                        sseAlgorithm: "AES256"
                                    }
                                ]
                                bucketKeyEnabled: True
                            }
                        ]
                    }
                }
                s3v1beta1.BucketPublicAccessBlock{
                    metadata.name: "example-kcl-pab"
                    spec.forProvider: {
                        blockPublicAcls: False
                        blockPublicPolicy: False
                        bucketRef: {
                            name: "example-kcl-bucket"
                        }
                        ignorePublicAcls: False
                        region: "us-west-1"
                        restrictPublicBuckets: False
                    }
                }
                s3v1beta1.BucketVersioning{
                    metadata.name: "example-kcl-versioning"
                    spec.forProvider: {
                        bucketRef: {
                            name: "example-kcl-bucket"
                        }
                        region: "us-west-1"
                        versioningConfiguration: [
                            {
                                status: "Enabled"
                            },
                        ]
                    }
                }
            ]
            compositionPath: "apis/kcl/composition.yaml"
            xrPath: "examples/kcl/example.yaml"
            xrdPath: "apis/xstoragebuckets/definition.yaml"
            timeoutSeconds: 120
            validate: False
        }
    }
]
items = _items
