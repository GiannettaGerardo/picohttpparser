PicoHTTPParser
=============

Copyright (c) 2009-2014 [Kazuho Oku](https://github.com/kazuho), [Tokuhiro Matsuno](https://github.com/tokuhirom), [Daisuke Murase](https://github.com/typester), [Shigeo Mitsunari](https://github.com/herumi)

PicoHTTPParser is a tiny, primitive, fast HTTP request/response parser.

Unlike most parsers, it is stateless and does not allocate memory by itself.
All it does is accept pointer to buffer and the output structure, and setups the pointers in the latter to point at the necessary portions of the buffer.

The code is widely deployed within Perl applications through popular modules that use it, including [Plack](https://metacpan.org/pod/Plack), [Starman](https://metacpan.org/pod/Starman), [Starlet](https://metacpan.org/pod/Starlet), [Furl](https://metacpan.org/pod/Furl).  It is also the HTTP/1 parser of [H2O](https://github.com/h2o/h2o).

Check out [test.cpp] to find out how to use the parser.

The software is dual-licensed under the Perl License or the MIT License.

Usage
-----

The library exposes four functions: `phr_parse_request`, `phr_parse_response`, `phr_parse_headers`, `phr_decode_chunked`.

### phr_parse_request

The example below reads an HTTP request from socket `sock` using `read(2)`, parses it using `phr_parse_request`, and prints the details.

```cpp
int pret;
ssize_t rret;
HttpRequest request(30, 4000);

while (1) {
    /* read the request */
    rret = read(sock, request.buffer.data() + request.buffer_len, request.buffer.size() - request.buffer_len);
    if (rret == -1 && errno == EINTR)
        continue;
    if (rret <= 0)
        return 1;
    request.prev_buffer_len = request.buffer_len;
    request.buffer_len += rret;
    /* parse the request */
    pret = phr_parse_request(request);
    if (pret > 0)
        break; /* successfully parsed the request */
    else if (pret == -1)
        return 1;
    /* request is incomplete, continue the loop */
    assert(pret == -2);
    if (request.buffer_len == request.buffer.size())
        return 1;
}

std::cout << "request is " << pret << " bytes long\n";
std::cout << "method is " << request.method << "\n";
std::cout << "path is " << request.path << "\n";
std::cout << "HTTP version is 1." << request.minor_version << "\n";
std::cout << "headers:\n";

for (auto& pair : request.headers)
    std::cout << pair.first << ": " << pair.second << "\n";
```

### phr_parse_response, phr_parse_headers

`phr_parse_response` and `phr_parse_headers` provide similar interfaces as `phr_parse_request`.  `phr_parse_response` parses an HTTP response, and `phr_parse_headers` parses the headers only.

### phr_decode_chunked

The example below decodes incoming data in chunked-encoding.  The data is decoded in-place.

```c
struct phr_chunked_decoder decoder = {}; /* zero-clear */
char *buf = malloc(4096);
size_t size = 0, capacity = 4096, rsize;
ssize_t rret, pret;

/* set consume_trailer to 1 to discard the trailing header, or the application
 * should call phr_parse_headers to parse the trailing header */
decoder.consume_trailer = 1;

do {
    /* expand the buffer if necessary */
    if (size == capacity) {
        capacity *= 2;
        buf = realloc(buf, capacity);
        assert(buf != NULL);
    }
    /* read */
    while ((rret = read(sock, buf + size, capacity - size)) == -1 && errno == EINTR)
        ;
    if (rret <= 0)
        return IOError;
    /* decode */
    rsize = rret;
    pret = phr_decode_chunked(&decoder, buf + size, &rsize);
    if (pret == -1)
        return ParseError;
    size += rsize;
} while (pret == -2);

/* successfully decoded the chunked data */
assert(pret >= 0);
printf("decoded data is at %p (%zu bytes)\n", buf, size);
```

Benchmark
---------

![benchmark results](http://i.gyazo.com/a85c18d3162dfb46b485bb41e0ad443a.png)

The benchmark code is from [fukamachi/fast-http@6b91103](https://github.com/fukamachi/fast-http/tree/6b9110347c7a3407310c08979aefd65078518478).

The internals of picohttpparser has been described to some extent in [my blog entry]( http://blog.kazuhooku.com/2014/11/the-internals-h2o-or-how-to-write-fast.html).
