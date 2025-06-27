# This test suite validates the creation of resources for the XStorageBucket XR.
#
# Creation of resources happens in two sequential calls to the composition
# function:
#
# 1. The first time the function is called, the bucket has not yet been
#    created. Other resources depend on the bucket's name, so the function creates
#    only the bucket.
#
# 2. When the function is called again after the bucket has been created, its name
#    is available, so the rest of the resources can be created.
#
# The test suite contains two tests, one for each of the sequential calls. The
# second test includes the bucket in its observed resources, triggering creation
# of the dependent resources.

import pydantic

from .model.io.upbound.dev.meta.compositiontest import v1alpha1 as compositiontest
from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as metav1

from . import resources

def buildTest(name: str, observed: list[pydantic.BaseModel], expected: list[pydantic.BaseModel]) -> compositiontest.CompositionTest:
    return compositiontest.CompositionTest(
    metadata=metav1.ObjectMeta(
        name=name,
    ),
    spec = compositiontest.Spec(
        observedResources=[o.model_dump(exclude_unset=True) for o in observed],
        assertResources=[e.model_dump(exclude_unset=True) for e in expected],
        compositionPath="apis/xstoragebucket/composition.yaml",
        xrPath="examples/xstoragebuckets/example.yaml",
        xrdPath="apis/xstoragebucket/definition.yaml",
        timeoutSeconds=120,
        validate=False,
    )
)

test1 = buildTest(
    "test-xstoragebucket-bucket-not-yet-created",
    observed=[],
    expected=[
        resources.expected_xr,
        resources.expected_bucket_before,
    ],
)

test2 = buildTest(
    "test-xstoragebucket-bucket-created",
    observed=[resources.observed_bucket],
    expected=[
        resources.expected_xr,
        resources.expected_bucket_after,
        resources.expected_acl,
        resources.expected_boc,
        resources.expected_pab,
        resources.expected_sse,
        resources.expected_versioning,
    ],
)
