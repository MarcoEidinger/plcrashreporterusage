arm64 is the current 64-bit ARM CPU architecture, as used since the iPhone 5S and later (6, 6S, SE and 7), the iPad Air, Air 2 and Pro, with the A7 and until and inclusive A11 chips.

The arm64e architecture is used on the A12(+) chipset, which is added in the latest 2018 iPhone models (XS/XS Max/XR), to enable pointer-authentication features. See https://lists.llvm.org/pipermail/llvm-dev/2019-October/136091.html for details

|Device|Internal Name|arm6|arm64e|
|---|---|---|---|
|iPhone 6s|iPhone8,1|X||
|iPhone 6s Plus|iPhone8,2|X||
|iPhone SE (1st gen)|iPhone8,4|X||
|iPhone 7|iPhone9,1 or iPhone9,3|X||
|iPhone 7 Plus|iPhone9,2 or iPhone9,4|X||
|iPhone 8|iPhone10,1 or iPhone10,4|X||
|iPhone 8 Plus|iPhone10,2 or iPhone10,5|X||
|iPhone X|iPhone10,3 or iPhone10,6|X||
|iPhone XR|iPhone11,8||X|
|iPhone XS|iPhone11,2||X|
|iPhone XS Max|iPhone11,4 or iPhone 11,6||X|
|iPhone 11|iPhone12,1||X|
|iPhone 11 Pro|iPhone12,3||X|
|iPhone 11 Pro Max|iPhone12,5||X|
|iPhone SE (2nd gen)|iPhone12,8||X|

arm64e is back compatible with arm64, i.e new devices can run applications built with older Xcode versions, for the generic arm64 iOS architecture.

However, CPU architecture mattes! Especially when it comes to symbolicating iOS system symbols.

Examples:
- `arm64_1351.crash` is a crash report from arm64 device.
- `arm64e_1351.crash` is a crash report from arm64e device.
- both devices run on iOS 13.5.1

Analysis:

Let's have a look whats the result when trying to symbolicate either an iOS framework or an iOS dylib with the help of shell script `atosSymbolicationWithOriginalSymbols.sh`

Output:

```bash
1. Crash on arm64e device ----------
arm64e symbols - atos with arm64e
PrimitiveButtonStyleConfiguration.trigger() (in SwiftUI) + 28
-----
arm64e symbols - atos with arm64
atos cannot load symbols for the file arm64eSymbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI for architecture arm64.
-----
arm64 symbols - atos with arm64e
specialized static View.makeView(view:inputs:) (in SwiftUI) + 388
-----
arm64 symbols - atos with arm64
specialized static View.makeView(view:inputs:) (in SwiftUI) + 388
-----
arm64e symbols - atos with arm64e
start (in libdyld.dylib) + 4
-----
arm64e symbols - atos with arm64
atos cannot load symbols for the file arm64eSymbols/usr/lib/system/libdyld.dylib for architecture arm64.
-----
arm64 symbols - atos with arm64e
0x00000001802992dc (in libdyld.dylib)
-----
arm64 symbols - atos with arm64
0x00000001802992dc (in libdyld.dylib)
-----
2. Crash on arm64 device ----------
arm64e symbols - atos with arm64e
static ResolvedTabView.makeView<A>(view:style:inputs:) (in SwiftUI) + 236
-----
arm64e symbols - atos with arm64
atos cannot load symbols for the file arm64eSymbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI for architecture arm64.
-----
arm64 symbols - atos with arm64e
PrimitiveButtonStyleConfiguration.trigger() (in SwiftUI) + 20
-----
arm64 symbols - atos with arm64
PrimitiveButtonStyleConfiguration.trigger() (in SwiftUI) + 20
-----
arm64e symbols - atos with arm64e
dyld3::closure::Image::neverUnload() const (in libdyld.dylib) + 4
-----
arm64e symbols - atos with arm64
atos cannot load symbols for the file arm64eSymbols/usr/lib/system/libdyld.dylib for architecture arm64.
-----
arm64 symbols - atos with arm64e
start (in libdyld.dylib) + 4
-----
arm64 symbols - atos with arm64
start (in libdyld.dylib) + 4
-----
```

It is obvious that correct architecture instruction for atos is required as well as matching symbols.

However, it is possible to merge iOS system symbols :)

I copied `arm64eSymbols` to `arm64e_and_arm64Symbols` and ran the following shell script command to merge arm64e and arm64 symbols

```bash
sh ./iOS-System-Symbols/tools/merge_symbols.sh ./arm64e_and_arm64Symbols ./arm64Symbols
```

I am able to verify with `atosSymbolicationWithMergedSymbols.sh` that merged symbols can be used to symbolicate crash report from either arm64 or arm64e device. But **correct architecture instruction for atos is still required**

Output

```bash
1. Crash on arm64e device ----------
merged symbols - atos with arm64e
PrimitiveButtonStyleConfiguration.trigger() (in SwiftUI) + 28
-----
merged symbols - atos with arm64
specialized static View.makeView(view:inputs:) (in SwiftUI) + 388
-----
merged symbols - atos with arm64e
start (in libdyld.dylib) + 4
-----
merged symbols - atos with arm64
0x00000001802992dc (in libdyld.dylib)
-----
2. Crash on arm64 device ----------
merged symbols - atos with arm64e
static ResolvedTabView.makeView<A>(view:style:inputs:) (in SwiftUI) + 236
-----
merged symbols - atos with arm64
PrimitiveButtonStyleConfiguration.trigger() (in SwiftUI) + 20
-----
merged symbols - atos with arm64e
dyld3::closure::Image::neverUnload() const (in libdyld.dylib) + 4
-----
arm64e symbols - atos with arm64
start (in libdyld.dylib) + 4
-----
```
