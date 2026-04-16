import json
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
isPublicRead = oxr.spec.parameters.acl == "public-read"

if bucketExternalName:
    _items += [
        # Block public ACLs unconditionally (BucketOwnerEnforced is the AWS
        # default since April 2023). When acl=public-read, we still allow
        # public access via bucket policy by loosening the policy-related
        # blocks.
        s3v1beta1.BucketPublicAccessBlock{
            metadata: _metadata("pab")
            spec = {
                forProvider = {
                    bucket = bucketExternalName
                    region = oxr.spec.parameters.region
                    blockPublicAcls: True
                    ignorePublicAcls: True
                    blockPublicPolicy: not isPublicRead
                    restrictPublicBuckets: not isPublicRead
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

    # Grant anonymous read access via bucket policy (the modern replacement
    # for the legacy public-read ACL).
    if isPublicRead:
        _items += [
            s3v1beta1.BucketPolicy{
                metadata: _metadata("policy")
                spec = {
                    forProvider = {
                        region = oxr.spec.parameters.region
                        bucket = bucketExternalName
                        policy = json.encode({
                            Version = "2012-10-17"
                            Statement = [{
                                Sid = "PublicRead"
                                Effect = "Allow"
                                Principal = "*"
                                Action = ["s3:GetObject"]
                                Resource = ["arn:aws:s3:::{}/*".format(bucketExternalName)]
                            }]
                        })
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
