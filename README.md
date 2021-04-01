# mwcbuildpipeline

This is the build pipeline for mwc-qt-wallet, but also builds mwc713 and mwc-node as part of the package.

## Prepare Tor Binary

For the MacOS we have to ship tor with all dependencies.
Tor binary we get form the homebrew.

Then we have to copy tor plus all dependent shared libraries into the same dir. Then fix the dependencies (code might vary).

```
> otool -l  tor
> install_name_tool -change "/usr/local/opt/libevent/lib/libevent-2.1.7.dylib"  "@loader_path/libevent-2.1.7.dylib" tor
> install_name_tool -change "/usr/local/opt/openssl@1.1/lib/libssl.1.1.dylib"  "@loader_path/libssl.1.1.dylib" tor
> install_name_tool -change "/usr/local/opt/openssl@1.1/lib/libcrypto.1.1.dylib"  "@loader_path/libcrypto.1.1.dylib" tor
> install_name_tool -change "/usr/local/opt/libscrypt/lib/libscrypt.0.dylib"  "@loader_path/libscrypt.0.dylib"

> otool -l libssl.1.1.dylib
> install_name_tool -change "/usr/local/Cellar/openssl@1.1/1.1.1k/lib/libcrypto.1.1.dylib"  "@loader_path/libcrypto.1.1.dylib" libssl.1.1.dylib
```

Then verify if tor loads needed files

```
> DYLD_PRINT_LIBRARIES=YES ./tor
dyld: loaded: <EA2C5A6C-9BE9-301B-A117-0ABD6467E797> /tor_test/./tor
dyld: loaded: <6E2BD7A3-DC55-3183-BBF7-3AC367BC1834> /usr/lib/libz.1.dylib
dyld: loaded: <DF6D8746-C6EB-367D-9544-F10F6E24C753> /tor_test/./libevent-2.1.7.dylib
dyld: loaded: <3D9A4A37-800F-31E5-B385-558175C1732E> /tor_test/./libssl.1.1.dylib
dyld: loaded: <8379949D-F788-34D2-9C44-CF7386DF4E12> /tor_test/./libcrypto.1.1.dylib
dyld: loaded: <7C97E8EA-4AB2-322B-ADC0-E5C0BC12DAB4> /tor_test/./libscrypt.0.dylib
dyld: loaded: <83503CE0-32B1-36DB-A4F0-3CC6B7BCF50A> /usr/lib/libSystem.B.dylib
dyld: loaded: <1A98B064-8FED-39CF-BB2E-5BDA1EF5B65A> /usr/lib/system/libcache.dylib
dyld: loaded: <822A29CE-BF54-35AD-BB15-8FAECB800C7D> /usr/lib/system/libcommonCrypto.dylib
dyld: loaded: <62EE1D14-5ED7-3CEC-81C0-9C93833641F1> /usr/lib/system/libcompiler_rt.dylib
.......
```