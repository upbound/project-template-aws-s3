
import models.v1beta1 as v1beta1

oxr = option("params").oxr # observed composite resource

bucketName = "{}-bucket".format(oxr.metadata.name)
_items: [any] = [
    # Bucket in the desired region
    v1beta1.Bucket{
        metadata.name = bucketName
        spec = v1beta1.S3AwsUpboundIoV1beta1BucketSpec{
            forProvider = v1beta1.S3AwsUpboundIoV1beta1BucketSpecForProvider{
                region = oxr.spec.region
            }
        }
    },
    # ACL for the bucket
    v1beta1.BucketACL{
        metadata.name = "{}-acl".format(oxr.metadata.name)
        spec = v1beta1.S3AwsUpboundIoV1beta1BucketACLSpec{
            forProvider = v1beta1.S3AwsUpboundIoV1beta1BucketACLSpecForProvider{
                region = oxr.spec.region
                acl = oxr.spec.acl
            }
        }
    },
    # Default encryption for the bucket
    v1beta1.BucketServerSideEncryptionConfiguration{
        metadata.name = "{}-encryption".format(oxr.metadata.name)
        spec = v1beta1.S3AwsUpboundIoV1beta1BucketServerSideEncryptionConfigurationSpec{
            forProvider = v1beta1.S3AwsUpboundIoV1beta1BucketServerSideEncryptionConfigurationSpecForProvider{
                region = oxr.spec.region
                bucketRef = v1beta1.S3AwsUpboundIoV1beta1BucketServerSideEncryptionConfigurationSpecForProviderBucketRef{
                    name = bucketName
                }
                rule = [
                    v1beta1.S3AwsUpboundIoV1beta1BucketServerSideEncryptionConfigurationSpecForProviderRuleItems0{
                        applyServerSideEncryptionByDefault = [
                            v1beta1.S3AwsUpboundIoV1beta1BucketServerSideEncryptionConfigurationSpecForProviderRuleItems0ApplyServerSideEncryptionByDefaultItems0{
                                sseAlgorithm = "AES256"
                            }
                        ]
                        bucketKeyEnabled = True
                    }
                ]
            }
        }
    }
]

# Set up versioning for the bucket if desired
if oxr.spec.versioning:
    _items += [
        v1beta1.BucketVersioning{
            metadata.name = "{}-versioning".format(oxr.metadata.name)
            spec = v1beta1.S3AwsUpboundIoV1beta1BucketVersioningSpec{
                forProvider = v1beta1.S3AwsUpboundIoV1beta1BucketVersioningSpecForProvider{
                    region = oxr.spec.region
                    bucketRef = v1beta1.S3AwsUpboundIoV1beta1BucketVersioningSpecForProviderBucketRef{
                        name = bucketName
                    }
                    versioningConfiguration = [
                        v1beta1.S3AwsUpboundIoV1beta1BucketVersioningSpecForProviderVersioningConfigurationItems0{
                            status = "Enabled"
                        }
                    ]
                }
            }
        }
    ]

items = _items
