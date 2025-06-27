import models.com.example.platform.v1alpha1 as platformv1alpha1
import models.io.upbound.aws.s3.v1beta1 as s3v1beta1

_expectedXR =  platformv1alpha1.XStorageBucket{
    metadata.name: "example"
    spec: {
        parameters: {
            acl: "public-read"
            region: "us-west-1"
            versioning: True
        }
    }
}

_expectedBucket = s3v1beta1.Bucket{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "bucket"
    }
    spec.forProvider: {
        region: "us-west-1"
    }
}

_observedBucket = s3v1beta1.Bucket{
    metadata.name: "example-bucket"
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "bucket"
    }
    spec.forProvider: {
        region: "us-west-1"
    }
}

_expectedACL = s3v1beta1.BucketACL{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "acl"
    }
    spec.forProvider:{
        acl: "public-read"
        bucketRef: {
            name: "example-bucket"
        }
        region: "us-west-1"
    }
}

_expectedBOC = s3v1beta1.BucketOwnershipControls{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "boc"
    }
    spec.forProvider: {
        bucketRef: {
            name: "example-bucket"
        }
        region: "us-west-1"
        rule: [
            {
                objectOwnership: "BucketOwnerPreferred"
            }
        ]
    }
}

_expectedEncryption = s3v1beta1.BucketServerSideEncryptionConfiguration{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "encryption"
    }
    spec.forProvider: {
        bucketRef: {
            name: "example-bucket"
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

_expectedPAB = s3v1beta1.BucketPublicAccessBlock{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "pab"
    }
    spec.forProvider: {
        blockPublicAcls: False
        blockPublicPolicy: False
        bucketRef: {
            name: "example-bucket"
        }
        ignorePublicAcls: False
        region: "us-west-1"
        restrictPublicBuckets: False
    }
}

_expectedVersioning = s3v1beta1.BucketVersioning{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "versioning"
    }
    spec.forProvider: {
        bucketRef: {
            name: "example-bucket"
        }
        region: "us-west-1"
        versioningConfiguration: [
            {
                status: "Enabled"
            },
        ]
    }
}
