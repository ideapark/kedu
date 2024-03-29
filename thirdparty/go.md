# Go Programming Language

## Go standard library

```bash
$go list std
archive/tar
archive/zip
bufio
bytes
compress/bzip2
compress/flate
compress/gzip
compress/lzw
compress/zlib
container/heap
container/list
container/ring
context
crypto
crypto/aes
crypto/cipher
crypto/des
crypto/dsa
crypto/ecdsa
crypto/ed25519
crypto/ed25519/internal/edwards25519
crypto/elliptic
crypto/hmac
crypto/internal/randutil
crypto/internal/subtle
crypto/md5
crypto/rand
crypto/rc4
crypto/rsa
crypto/sha1
crypto/sha256
crypto/sha512
crypto/subtle
crypto/tls
crypto/x509
crypto/x509/internal/macos
crypto/x509/pkix
database/sql
database/sql/driver
debug/dwarf
debug/elf
debug/gosym
debug/macho
debug/pe
debug/plan9obj
embed
embed/internal/embedtest
encoding
encoding/ascii85
encoding/asn1
encoding/base32
encoding/base64
encoding/binary
encoding/csv
encoding/gob
encoding/hex
encoding/json
encoding/pem
encoding/xml
errors
expvar
flag
fmt
go/ast
go/build
go/build/constraint
go/constant
go/doc
go/format
go/importer
go/internal/gccgoimporter
go/internal/gcimporter
go/internal/srcimporter
go/parser
go/printer
go/scanner
go/token
go/types
hash
hash/adler32
hash/crc32
hash/crc64
hash/fnv
hash/maphash
html
html/template
image
image/color
image/color/palette
image/draw
image/gif
image/internal/imageutil
image/jpeg
image/png
index/suffixarray
internal/bytealg
internal/cfg
internal/cpu
internal/execabs
internal/fmtsort
internal/goroot
internal/goversion
internal/lazyregexp
internal/lazytemplate
internal/nettrace
internal/obscuretestdata
internal/oserror
internal/poll
internal/profile
internal/race
internal/reflectlite
internal/singleflight
internal/syscall/execenv
internal/syscall/unix
internal/sysinfo
internal/testenv
internal/testlog
internal/trace
internal/unsafeheader
internal/xcoff
io
io/fs
io/ioutil
log
log/syslog
math
math/big
math/bits
math/cmplx
math/rand
mime
mime/multipart
mime/quotedprintable
net
net/http
net/http/cgi
net/http/cookiejar
net/http/fcgi
net/http/httptest
net/http/httptrace
net/http/httputil
net/http/internal
net/http/pprof
net/internal/socktest
net/mail
net/rpc
net/rpc/jsonrpc
net/smtp
net/textproto
net/url
os
os/exec
os/signal
os/signal/internal/pty
os/user
path
path/filepath
plugin
reflect
regexp
regexp/syntax
runtime
runtime/cgo
runtime/debug
runtime/internal/atomic
runtime/internal/math
runtime/internal/sys
runtime/metrics
runtime/pprof
runtime/race
runtime/trace
sort
strconv
strings
sync
sync/atomic
syscall
testing
testing/fstest
testing/internal/testdeps
testing/iotest
testing/quick
text/scanner
text/tabwriter
text/template
text/template/parse
time
time/tzdata
unicode
unicode/utf16
unicode/utf8
unsafe
vendor/golang.org/x/crypto/chacha20
vendor/golang.org/x/crypto/chacha20poly1305
vendor/golang.org/x/crypto/cryptobyte
vendor/golang.org/x/crypto/cryptobyte/asn1
vendor/golang.org/x/crypto/curve25519
vendor/golang.org/x/crypto/hkdf
vendor/golang.org/x/crypto/internal/subtle
vendor/golang.org/x/crypto/poly1305
vendor/golang.org/x/net/dns/dnsmessage
vendor/golang.org/x/net/http/httpguts
vendor/golang.org/x/net/http/httpproxy
vendor/golang.org/x/net/http2/hpack
vendor/golang.org/x/net/idna
vendor/golang.org/x/net/nettest
vendor/golang.org/x/net/route
vendor/golang.org/x/sys/cpu
vendor/golang.org/x/text/secure/bidirule
vendor/golang.org/x/text/transform
vendor/golang.org/x/text/unicode/bidi
vendor/golang.org/x/text/unicode/norm
```

## `go doc` to explore packages

```bash
$go doc archive/tar
package tar // import "archive/tar"

Package tar implements access to tar archives.

Tape archives (tar) are a file format for storing a sequence of files that
can be read and written in a streaming manner. This package aims to cover
most variations of the format, including those produced by GNU and BSD tar
tools.

const TypeReg = '0' ...
var ErrHeader = errors.New("archive/tar: invalid tar header") ...
type Format int
    const FormatUnknown Format ...
type Header struct{ ... }
    func FileInfoHeader(fi fs.FileInfo, link string) (*Header, error)
type Reader struct{ ... }
    func NewReader(r io.Reader) *Reader
type Writer struct{ ... }
    func NewWriter(w io.Writer) *Writer
```

## `go mod help` to share or use packages

```bash
$go mod help
Go mod provides access to operations on modules.

Note that support for modules is built into all the go commands,
not just 'go mod'. For example, day-to-day adding, removing, upgrading,
and downgrading of dependencies should be done using 'go get'.
See 'go help modules' for an overview of module functionality.

Usage:

	go mod <command> [arguments]

The commands are:

	download    download modules to local cache
	edit        edit go.mod from tools or scripts
	graph       print module requirement graph
	init        initialize new module in current directory
	tidy        add missing and remove unused modules
	vendor      make vendored copy of dependencies
	verify      verify dependencies have expected content
	why         explain why packages or modules are needed

Use "go help mod <command>" for more information about a command.
```

## Other daily Go tools

- go test
- go install
- go get
- go build
- go env

## EMACS love Go

Personally, I use EMACS to coding and reading Go code. you would have
your favourite IDE to work with Go.
