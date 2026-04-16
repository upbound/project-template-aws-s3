import models.com.example.platform.v1alpha1 as platformv1alpha1
import models.io.upbound.aws.s3.v1beta1 as s3v1beta1

_expectedXR =  platformv1alpha1.XStorageBucket{
    metadata.name: "example"
    spec: {
        parameters: {
            acl: "private"
            region: "us-west-1"
            versioning: True
        }
    }
}

_expectedBucketBefore = s3v1beta1.Bucket{
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
        "crossplane.io/external-name": "example-bucket"
    }
    spec.forProvider: {
        region: "us-west-1"
    }
}

_expectedBucketAfter = s3v1beta1.Bucket{
    metadata.name: "example-bucket"
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "bucket"
    }
    spec.forProvider: {
        region: "us-west-1"
    }
}

_expectedEncryption = s3v1beta1.BucketServerSideEncryptionConfiguration{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "sse"
    }
    spec.forProvider: {
        bucket: "example-bucket"
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
        blockPublicAcls: True
        blockPublicPolicy: True
        bucket: "example-bucket"
        ignorePublicAcls: True
        region: "us-west-1"
        restrictPublicBuckets: True
    }
}

_expectedVersioning = s3v1beta1.BucketVersioning{
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "versioning"
    }
    spec.forProvider: {
        bucket: "example-bucket"
        region: "us-west-1"
        versioningConfiguration: [
            {
                status: "Enabled"
            },
        ]
    }
}
