from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as metav1
from .model.com.example.platform.xstoragebucket import v1alpha1
from .model.io.upbound.aws.s3.bucket import v1beta1 as bucketv1beta1
from .model.io.upbound.aws.s3.bucketpublicaccessblock import v1beta1 as pabv1beta1
from .model.io.upbound.aws.s3.bucketversioning import v1beta1 as verv1beta1
from .model.io.upbound.aws.s3.bucketserversideencryptionconfiguration import v1beta1 as ssev1beta1

expected_xr = v1alpha1.XStorageBucket(
    apiVersion="platform.example.com/v1alpha1",
    kind="XStorageBucket",
    metadata=metav1.ObjectMeta(
        name="example",
    ),
    spec = v1alpha1.Spec(
        parameters = v1alpha1.Parameters(
            acl="private",
            region="us-west-1",
            versioning=True,
        ),
    ),
)

expected_bucket_before = bucketv1beta1.Bucket(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="Bucket",
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "bucket",
        },
    ),
    spec=bucketv1beta1.Spec(
        forProvider=bucketv1beta1.ForProvider(
            region="us-west-1",
        ),
    ),
)

observed_bucket = bucketv1beta1.Bucket(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="Bucket",
    metadata=metav1.ObjectMeta(
        name="example-bucket",
        annotations={
            "crossplane.io/composition-resource-name": "bucket",
            "crossplane.io/external-name": "example-bucket",
        },
    ),
    spec=bucketv1beta1.Spec(
        forProvider=bucketv1beta1.ForProvider(
            region="us-west-1"
        )
    )
)

expected_bucket_after = bucketv1beta1.Bucket(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="Bucket",
    metadata=metav1.ObjectMeta(
        name="example-bucket",
        annotations={
            "crossplane.io/composition-resource-name": "bucket",
        },
    ),
    spec=bucketv1beta1.Spec(
        forProvider=bucketv1beta1.ForProvider(
            region="us-west-1",
        ),
    ),
)

expected_pab = pabv1beta1.BucketPublicAccessBlock(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="BucketPublicAccessBlock",
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "pab",
        },
    ),
    spec=pabv1beta1.Spec(
        forProvider=pabv1beta1.ForProvider(
            region="us-west-1",
            bucket="example-bucket",
            blockPublicAcls=True,
            ignorePublicAcls=True,
            restrictPublicBuckets=True,
            blockPublicPolicy=True,
        ),
    ),
)

expected_sse = ssev1beta1.BucketServerSideEncryptionConfiguration(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="BucketServerSideEncryptionConfiguration",
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "sse",
        },
    ),
    spec=ssev1beta1.Spec(
        forProvider=ssev1beta1.ForProvider(
            region="us-west-1",
            bucket="example-bucket",
            rule=[
                ssev1beta1.RuleItem(
                    applyServerSideEncryptionByDefault=[
                        ssev1beta1.ApplyServerSideEncryptionByDefaultItem(
                            sseAlgorithm="AES256",
                        ),
                    ],
                    bucketKeyEnabled=True,
                ),
            ],
        ),
    ),
)

expected_versioning = verv1beta1.BucketVersioning(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="BucketVersioning",
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "versioning",
        },
    ),
    spec=verv1beta1.Spec(
        forProvider=verv1beta1.ForProvider(
            region="us-west-1",
            bucket="example-bucket",
            versioningConfiguration=[
                verv1beta1.VersioningConfigurationItem(
                    status="Enabled",
                ),
            ],
        ),
    ),
)
