from crossplane.function import resource
from crossplane.function.proto.v1 import run_function_pb2 as fnv1
from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as metav1
from .model.com.example.platform.xstoragebucket import v1alpha1
from .model.io.upbound.aws.s3.bucket import v1beta1 as bucketv1beta1
from .model.io.upbound.aws.s3.bucketacl import v1beta1 as aclv1beta1
from .model.io.upbound.aws.s3.bucketversioning import v1beta1 as verv1beta1
from .model.io.upbound.aws.s3.bucketserversideencryptionconfiguration import v1beta1 as ssev1beta1

def compose(req: fnv1.RunFunctionRequest, rsp: fnv1.RunFunctionResponse):
    observedXR = v1alpha1.XStorageBucket(**req.observed.composite.resource)
    xrName = observedXR.metadata.name
    bucketName = xrName + "-bucket"

    bucket = bucketv1beta1.Bucket(
        apiVersion="s3.aws.upbound.io/v1beta1",
        kind="Bucket",
        metadata=metav1.ObjectMeta(
            name=bucketName,
        ),
        spec=bucketv1beta1.Spec(
            forProvider=bucketv1beta1.ForProvider(
                region=observedXR.spec.region,
            ),
        ),
    )
    resource.update(rsp.desired.resources[bucket.metadata.name], bucket)

    acl = aclv1beta1.BucketACL(
        apiVersion="s3.aws.upbound.io/v1beta1",
        kind="BucketACL",
        metadata=metav1.ObjectMeta(
            name=xrName + "-acl",
        ),
        spec=aclv1beta1.Spec(
            forProvider=aclv1beta1.ForProvider(
                region=observedXR.spec.region,
                bucketRef=aclv1beta1.BucketRef(
                    name = bucketName,
                ),
                acl=observedXR.spec.acl,
            ),
        ),
    )
    resource.update(rsp.desired.resources[acl.metadata.name], acl)

    sse = ssev1beta1.BucketServerSideEncryptionConfiguration(
        apiVersion="s3.aws.upbound.io/v1beta1",
        kind="BucketServerSideEncryptionConfiguration",
        metadata=metav1.ObjectMeta(
            name=xrName + "-encryption",
        ),
        spec=ssev1beta1.Spec(
            forProvider=ssev1beta1.ForProvider(
                region=observedXR.spec.region,
                bucketRef=ssev1beta1.BucketRef(
                    name=bucketName,
                ),
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
    resource.update(rsp.desired.resources[sse.metadata.name], sse)

    if observedXR.spec.versioning:
        versioning = verv1beta1.BucketVersioning(
            apiVersion="s3.aws.upbound.io/v1beta1",
            kind="BucketVersioning",
            metadata=metav1.ObjectMeta(
                name=xrName + "-versioning",
            ),
            spec=verv1beta1.Spec(
                forProvider=verv1beta1.ForProvider(
                    region=observedXR.spec.region,
                    bucketRef=verv1beta1.BucketRef(
                        name=bucketName,
                    ),
                    versioningConfiguration=[
                        verv1beta1.VersioningConfigurationItem(
                            status="Enabled",
                        ),
                    ],
                ),
            )
        )
        resource.update(rsp.desired.resources[versioning.metadata.name], versioning)
