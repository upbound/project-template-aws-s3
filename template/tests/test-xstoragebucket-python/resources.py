from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as metav1
from .model.com.example.platform.xstoragebucket import v1alpha1
from .model.io.upbound.aws.s3.bucket import v1beta1 as bucketv1beta1
from .model.io.upbound.aws.s3.bucketacl import v1beta1 as aclv1beta1
from .model.io.upbound.aws.s3.bucketownershipcontrols import v1beta1 as bocv1beta1
from .model.io.upbound.aws.s3.bucketpublicaccessblock import v1beta1 as pabv1beta1
from .model.io.upbound.aws.s3.bucketversioning import v1beta1 as verv1beta1
from .model.io.upbound.aws.s3.bucketserversideencryptionconfiguration import v1beta1 as ssev1beta1

expected_xr = v1alpha1.XStorageBucket(
    apiVersion=v1alpha1.ApiVersion.platform_example_com_v1alpha1,
    kind=v1alpha1.Kind.XStorageBucket,
    metadata=metav1.ObjectMeta(
        name="example",
    ),
    spec = v1alpha1.Spec(
        parameters = v1alpha1.Parameters(
            acl="public-read",
            region="us-west-1",
            versioning=True,
        ),
    ),
)

expected_bucket_before = bucketv1beta1.Bucket(
    apiVersion=bucketv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=bucketv1beta1.Kind.Bucket,
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
    apiVersion=bucketv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=bucketv1beta1.Kind.Bucket,
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
    apiVersion=bucketv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=bucketv1beta1.Kind.Bucket,
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

expected_acl = aclv1beta1.BucketACL(
    apiVersion=aclv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=aclv1beta1.Kind.BucketACL,
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "acl",
        },
    ),
    spec=aclv1beta1.Spec(
        forProvider=aclv1beta1.ForProvider(
            acl="public-read",
            bucket="example-bucket",
            region="us-west-1",
        ),
    ),
)

expected_boc = bocv1beta1.BucketOwnershipControls(
    apiVersion=bocv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=bocv1beta1.Kind.BucketOwnershipControls,
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "boc",
        },
    ),
    spec=bocv1beta1.Spec(
        forProvider=bocv1beta1.ForProvider(
            region="us-west-1",
            bucket="example-bucket",
            rule=[
                bocv1beta1.RuleItem(
                    objectOwnership="BucketOwnerPreferred",
                ),
            ],
        ),
    ),
)

expected_pab = pabv1beta1.BucketPublicAccessBlock(
    apiVersion=pabv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=pabv1beta1.Kind.BucketPublicAccessBlock,
    metadata=metav1.ObjectMeta(
        annotations={
            "crossplane.io/composition-resource-name": "pab",
        },
    ),
    spec=pabv1beta1.Spec(
        forProvider=pabv1beta1.ForProvider(
            region="us-west-1",
            bucket="example-bucket",
            blockPublicAcls=False,
            ignorePublicAcls=False,
            restrictPublicBuckets=False,
            blockPublicPolicy=False,
        ),
    ),
)

expected_sse = ssev1beta1.BucketServerSideEncryptionConfiguration(
    apiVersion=ssev1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=ssev1beta1.Kind.BucketServerSideEncryptionConfiguration,
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
    apiVersion=verv1beta1.ApiVersion.s3_aws_upbound_io_v1beta1,
    kind=verv1beta1.Kind.BucketVersioning,
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
