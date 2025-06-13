from .model.io.upbound.dev.meta.compositiontest import v1alpha1 as compositiontest
from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as k8s
from .model.com.example.platform.xstoragebucket import v1alpha1 as platformv1alpha1
from .model.io.upbound.aws.s3.bucketacl import v1beta1 as bucketaclv1beta1
from .model.io.upbound.aws.s3.bucket import v1beta1 as bucketv1beta1

xStorageBucket = platformv1alpha1.XStorageBucket(
    apiVersion="platform.example.com/v1alpha1",
    kind="XStorageBucket",
    metadata=k8s.ObjectMeta(
        name="example-python"
    ),
    spec = platformv1alpha1.Spec(
        compositionSelector=platformv1alpha1.CompositionSelector(
            matchLabels={
                "language": "python",
            },
        ),
        parameters = platformv1alpha1.Parameters(
            acl="public-read",
            region="us-west-1",
            versioning=True,
        ),
    ),
)

bucket = bucketv1beta1.Bucket(
    apiVersion="s3.aws.upbound.io/v1beta1",
    kind="Bucket",
    metadata=k8s.ObjectMeta(
        name="example-python"
    ),
    spec=bucketv1beta1.Spec(
        forProvider=bucketv1beta1.ForProvider(
            region="us-west-1"
        )
    )
)

test = compositiontest.CompositionTest(
    metadata=k8s.ObjectMeta(
        name="test-xstoragebucket-python",
    ),
    spec = compositiontest.Spec(
        assertResources=[
            xStorageBucket.model_dump(exclude_unset=True),
        ],
        compositionPath="apis/python/composition.yaml",
        xrPath="examples/python/example.yaml",
        xrdPath="apis/xstoragebuckets/definition.yaml",
        timeoutSeconds=120,
        validate=False,
    )
)
