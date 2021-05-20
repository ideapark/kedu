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

## Buy me a coffee

- wechat

![wechat](assets/wechat.png)

- alipay

![alipay](assets/alipay.png)
