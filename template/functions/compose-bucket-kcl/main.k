import models.io.upbound.aws.s3.v1beta1 as s3v1beta1
import models.com.example.platform.v1alpha1.xstoragebucket as xstoragebucketv1alpha1

oxr = xstoragebucketv1alpha1.XStorageBucket{**option("params").oxr}

_metadata = lambda name: str -> any {
  {
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_items: [any] = [
    # Bucket in the desired region
    s3v1beta1.Bucket{
        metadata: _metadata("bucket")
        spec = {
            forProvider = {
                region = oxr.spec.parameters.region
            }
        }
    }
]

ocds = option("params").ocds
bucketExternalName = ocds["bucket"]?.Resource?.metadata?.annotations?["crossplane.io/external-name"]
if bucketExternalName:
    _items += [
        s3v1beta1.BucketOwnershipControls{
            metadata: _metadata("boc")
            spec = {
                forProvider = {
                    bucket = bucketExternalName
                    region = oxr.spec.parameters.region
                    rule:[{
                        objectOwnership:"BucketOwnerPreferred"
                    }]
                }
            }
        },
        s3v1beta1.BucketPublicAccessBlock{
            metadata: _metadata("pab")
            spec = {
                forProvider = {
                    bucket = bucketExternalName
                    region = oxr.spec.parameters.region
                    blockPublicAcls: False
                    ignorePublicAcls: False
                    restrictPublicBuckets: False
                    blockPublicPolicy: False
                }
            }
        },
        # ACL for the bucket
        s3v1beta1.BucketACL{
            metadata: _metadata("acl")
            spec = {
                forProvider = {
                    bucket = bucketExternalName
                    region = oxr.spec.parameters.region
                    acl = oxr.spec.parameters.acl
                }
            }
        },
        # Default encryption for the bucket
        s3v1beta1.BucketServerSideEncryptionConfiguration{
            metadata: _metadata("sse")
            spec = {
                forProvider = {
                    region = oxr.spec.parameters.region
                    bucket = bucketExternalName
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
    if oxr.spec.parameters.versioning:
        _items += [
            s3v1beta1.BucketVersioning{
                metadata: _metadata("versioning")
                spec = {
                    forProvider = {
                        region = oxr.spec.parameters.region
                        bucket = bucketExternalName
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
