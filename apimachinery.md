# Module k8s.io/apimachinery

This is a collection to guide you to explore the kubernetes low level module
`k8s.io/apimachinery`. To be accurate, I will explain the details of package
`k8s.io/apimachinery/pkg/runtime`, since other packages are quite simple and
easy to understand by yourself.

## Kubernetes Types Conversion & Serialization

```bash
$ go doc k8s.io/apimachinery/pkg/runtime
package runtime // import "k8s.io/apimachinery/pkg/runtime"

Package runtime defines conversions between generic types and structs to map
query strings to struct objects.

Package runtime includes helper functions for working with API objects that
follow the kubernetes API object conventions, which are:

0. Your API objects have a common metadata struct member, TypeMeta.

1. Your code refers to an internal set of API objects.

2. In a separate package, you have an external set of API objects.

3. The external set is considered to be versioned, and no breaking changes
are ever made to it (fields may be added but not changed or removed).

4. As your api evolves, you'll make an additional versioned package with
every major change.

5. Versioned packages have conversion functions which convert to and from
the internal version.

6. You'll continue to support older versions according to your deprecation
policy, and you can easily provide a program/library to update old versions
into new versions because of 5.

7. All of your serializations and deserializations are handled in a
centralized place.

Package runtime provides a conversion helper to make 5 easy, and the
Encode/Decode/DecodeInto trio to accomplish 7. You can also register
additional "codecs" which use a version of your choice. It's recommended
that you register your types with runtime in your package's init function.

As a bonus, a few common types useful from all api objects and versions are
provided in types.go.

...[REDACTED]...
```

In one word, it handles all the conversion and serialization:

```text
Conversion from and to the hub version

     +--------+           +-------+
     |v1alpha1|           |v1beta1|
     +--------+           +-------+
              \          /
               \        /
              +----------+
              | Internal |
              | version  |
              +----------+
                    |
                    |
                 +----+
                 | v1 |
                 +----+
```

## k8s.io/apimachinery/pkg/runtime.Scheme

All the kubernetes native types will be registered to this scheme:

1. [internal version example](https://github.com/kubernetes/kubernetes/blob/29e4fdab4d644af51c1fa2623bf0e78f3dd6383b/pkg/apis/apps/register.go#L49)
2. [external version example](https://github.com/kubernetes/kubernetes/blob/29e4fdab4d644af51c1fa2623bf0e78f3dd6383b/staging/src/k8s.io/api/apps/v1/register.go#L45)

```go
package runtime // import "k8s.io/apimachinery/pkg/runtime"

// Scheme defines methods for serializing and deserializing API objects, a type
// registry for converting group, version, and kind information to and from Go
// schemas, and mappings between Go schemas of different versions. A scheme is the
// foundation for a versioned API and versioned configuration over time.
//
// In a Scheme, a Type is a particular Go struct, a Version is a point-in-time
// identifier for a particular representation of that Type (typically backwards
// compatible), a Kind is the unique name for that Type within the Version, and a
// Group identifies a set of Versions, Kinds, and Types that evolve over time. An
// Unversioned Type is one that is not yet formally bound to a type and is promised
// to be backwards compatible (effectively a "v1" of a Type that does not expect
// to break in the future).
//
// Schemes are not expected to change at runtime and are only threadsafe after
// registration is complete.
type Scheme struct {
	// versionMap allows one to figure out the go type of an object with
	// the given version and name.
	gvkToType map[schema.GroupVersionKind]reflect.Type

	// typeToGroupVersion allows one to find metadata for a given go object.
	// The reflect.Type we index by should *not* be a pointer.
	typeToGVK map[reflect.Type][]schema.GroupVersionKind

	// unversionedTypes are transformed without conversion in ConvertToVersion.
	unversionedTypes map[reflect.Type]schema.GroupVersionKind

	// unversionedKinds are the names of kinds that can be created in the context of any group
	// or version
	// TODO: resolve the status of unversioned types.
	unversionedKinds map[string]reflect.Type

	// Map from version and resource to the corresponding func to convert
	// resource field labels in that version to internal version.
	fieldLabelConversionFuncs map[schema.GroupVersionKind]FieldLabelConversionFunc

	// defaulterFuncs is an array of interfaces to be called with an object to provide defaulting
	// the provided object must be a pointer.
	defaulterFuncs map[reflect.Type]func(interface{})

	// converter stores all registered conversion functions. It also has
	// default converting behavior.
	converter *conversion.Converter

	// versionPriority is a map of groups to ordered lists of versions for those groups indicating the
	// default priorities of these versions as registered in the scheme
	versionPriority map[string][]string

	// observedVersions keeps track of the order we've seen versions during type registration
	observedVersions []schema.GroupVersion

	// schemeName is the name of this scheme.  If you don't specify a name, the stack of the NewScheme caller will be used.
	// This is useful for error reporting to indicate the origin of the scheme.
	schemeName string
}
```

From the above struct definition, we can concluded that `Scheme` is used to
connect between the `network data (such as post data)` and `kubernetes go struct
object`. To be more abstract, it is used to codec data between memory and the
wire.

## Buy me a coffee

- wechat

![wechat](assets/wechat.png)

- alipay

![alipay](assets/alipay.png)
