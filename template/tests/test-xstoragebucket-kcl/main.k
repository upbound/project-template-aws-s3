"""
This test suite validates the creation of resources for the XStorageBucket XR.

Creation of resources happens in two sequential calls to the composition
function:

1. The first time the function is called, the bucket has not yet been
   created. Other resources depend on the bucket's name, so the function creates
   only the bucket.

2. When the function is called again after the bucket has been created, its name
   is available, so the rest of the resources can be created.

The test suite contains two tests, one for each of the sequential calls. The
second test includes the bucket in its observed resources, triggering creation
of the dependent resources.
"""

import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import resources

# It's a best practice for composition functions to return only fields whose
# values they care about, since they become the owner of any field they
# return. Allow for fields with defaults to be omitted by the composition
# function by clearing them in our expected resources.
_stripDefaults = lambda obj: any -> any {
    obj | {
        spec.deletionPolicy = Undefined
        spec.managementPolicies = Undefined
    }
}

_spec = metav1alpha1.CompositionTest {
    spec = {
        compositionPath: "apis/xstoragebucket/composition.yaml"
        xrPath: "examples/xstoragebuckets/example.yaml"
        xrdPath: "apis/xstoragebucket/definition.yaml"
        timeoutSeconds: 120
        validate: False
    }
}

_test1 = metav1alpha1.CompositionTest {
    metadata.name = "test-xstoragebucket-bucket-not-yet-created"
    **_spec
    spec.assertResources = [
        resources._expectedXR
        _stripDefaults(resources._expectedBucketBefore)
    ]
}

_test2 = metav1alpha1.CompositionTest {
    metadata.name = "tests-xstoragebucket-bucket-created"
    **_spec
    spec.observedResources = [
        resources._observedBucket
    ]
    spec.assertResources = [
        resources._expectedXR
        _stripDefaults(resources._expectedBucketAfter)
        _stripDefaults(resources._expectedACL)
        _stripDefaults(resources._expectedBOC)
        _stripDefaults(resources._expectedPAB)
        _stripDefaults(resources._expectedEncryption)
        _stripDefaults(resources._expectedVersioning)
    ]
}

items = [_test1, _test2]
