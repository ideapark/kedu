# Docker image

## Manifest

```bash
$docker manifest inspect alpine:latest
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
  "manifests": [
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:def822f9851ca422481ec6fee59a9966f12b351c62ccb9aca841526ffaa9f748",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:ea73ecf48cd45e250f65eb731dd35808175ae37d70cca5d41f9ef57210737f04",
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v6"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:9663906b1c3bf891618ebcac857961531357525b25493ef717bca0f86f581ad6",
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v7"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:8f18fae117ec6e5777cc62ba78cbb3be10a8a38639ccfb949521abd95c8301a4",
      "platform": {
        "architecture": "arm64",
        "os": "linux",
        "variant": "v8"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:5de788243acadd50526e70868b86d12ad79f3793619719ae22e0d09e8c873a66",
      "platform": {
        "architecture": "386",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:827525365ff718681b0688621e09912af49a17611701ee4d421ba50d57c13f7e",
      "platform": {
        "architecture": "ppc64le",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:a090d7c93c8e9ab88946367500756c5f50cd660e09deb4c57494989c1f23fa5a",
      "platform": {
        "architecture": "s390x",
        "os": "linux"
      }
    }
  ]
}
```

## Image (linux/arm64)

```bash
$docker image inspect alpine:latest
[
  {
    "Id": "sha256:3fcaaf3dc95cc40ea9ec229c2e43c69091b962a605b8ff9aa0c3f5ecf5c0e64a",
    "RepoTags": [
      "alpine:latest"
    ],
    "RepoDigests": [
      "alpine@sha256:69e70a79f2d41ab5d637de98c1e0b055206ba40a8145e7bddb55ccc04e13cf8f"
    ],
    "Parent": "",
    "Comment": "",
    "Created": "2021-04-14T18:42:38.108586646Z",
    "Container": "e3ac2f8aff741231d4b667a84f9fafb108112c3a72fe44581b7ab731bbd67df7",
    "ContainerConfig": {
      "Hostname": "e3ac2f8aff74",
      "Domainname": "",
      "User": "",
      "AttachStdin": false,
      "AttachStdout": false,
      "AttachStderr": false,
      "Tty": false,
      "OpenStdin": false,
      "StdinOnce": false,
      "Env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ],
      "Cmd": [
        "/bin/sh",
        "-c",
        "#(nop) ",
        "CMD [\"/bin/sh\"]"
      ],
      "Image": "sha256:3f32d1754e45edc72ca0423d792d57f49eaacd757f2bee4b0417d3c805419a6f",
      "Volumes": null,
      "WorkingDir": "",
      "Entrypoint": null,
      "OnBuild": null,
      "Labels": {}
    },
    "DockerVersion": "19.03.12",
    "Author": "",
    "Config": {
      "Hostname": "",
      "Domainname": "",
      "User": "",
      "AttachStdin": false,
      "AttachStdout": false,
      "AttachStderr": false,
      "Tty": false,
      "OpenStdin": false,
      "StdinOnce": false,
      "Env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ],
      "Cmd": [
        "/bin/sh"
      ],
      "Image": "sha256:3f32d1754e45edc72ca0423d792d57f49eaacd757f2bee4b0417d3c805419a6f",
      "Volumes": null,
      "WorkingDir": "",
      "Entrypoint": null,
      "OnBuild": null,
      "Labels": null
    },
    "Architecture": "arm64",
    "Os": "linux",
    "Size": 5350282,
    "VirtualSize": 5350282,
    "GraphDriver": {
      "Data": {
        "MergedDir": "/var/lib/docker/overlay2/0464bb05fcfb8cb4050f36efceb84736c41bbc6d2a54cbaa3c85ca0c4b840c5e/merged",
        "UpperDir": "/var/lib/docker/overlay2/0464bb05fcfb8cb4050f36efceb84736c41bbc6d2a54cbaa3c85ca0c4b840c5e/diff",
        "WorkDir": "/var/lib/docker/overlay2/0464bb05fcfb8cb4050f36efceb84736c41bbc6d2a54cbaa3c85ca0c4b840c5e/work"
      },
      "Name": "overlay2"
    },
    "RootFS": {
      "Type": "layers",
      "Layers": [
        "sha256:c55d5dbdab4094da9ba390de49be10dd3b42e990670236a81a792fd2c933fceb"
      ]
    },
    "Metadata": {
      "LastTagTime": "0001-01-01T00:00:00Z"
    }
  }
]
```
