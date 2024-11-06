
import models.io.upbound.aws.s3.v1beta1 as s3v1beta1

oxr = option("params").oxr # observed composite resource
params = oxr.spec.parameters

bucketName = "{}-bucket".format(oxr.metadata.name)

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_items: [any] = [
    # Bucket in the desired region
    s3v1beta1.Bucket{
        metadata: _metadata(bucketName)
        spec = {
            forProvider = {
                region = params.region
            }
        }
    },
    # ACL for the bucket
    s3v1beta1.BucketACL{
        metadata: _metadata("{}-acl".format(oxr.metadata.name))
        spec = {
            forProvider = {
                region = params.region
                acl = params.acl
            }
        }
    },
    # Default encryption for the bucket
    s3v1beta1.BucketServerSideEncryptionConfiguration{
        metadata: _metadata("{}-encryption".format(oxr.metadata.name))
        spec = {
            forProvider = {
                region = params.region
                bucketRef = {
                    name = bucketName
                }
                rule = [
                    {
                        applyServerSideEncryptionByDefault = [
                            {
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
if params.versioning:
    _items += [
        s3v1beta1.BucketVersioning{
            metadata: _metadata("{}-versioning".format(oxr.metadata.name))
            spec = {
                forProvider = {
                    region = params.region
                    bucketRef = {
                        name = bucketName
                    }
                    versioningConfiguration = [
                        {
                            status = "Enabled"
                        }
                    ]
                }
            }
        }
    ]

items = _items
