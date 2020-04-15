- [Symbolicating Crash Reports](#symbolicating-crash-reports)
	- [Overview](#overview)
	- [Symbolicating Crash Reports with Atos](#symbolicating-crash-reports-with-atos)
	- [Symbolicating Crash Reports with symbolicatecrash](#symbolicating-crash-reports-with-symbolicatecrash)
	- [Other techniques](#other-techniques)
		- [Symbolicating with **lldb**](#symbolicating-with-lldb)
		- [Symbolicating with **Dwarfdump**](#symbolicating-with-dwarfdump)
	- [Note: symbolicating on Linux](#note-symbolicating-on-linux)
	- [Note: symbolicating iOS system symbols](#note-symbolicating-ios-system-symbols)

# Symbolicating Crash Reports

## Overview

Symbolication is the process of resolving backtrace addresses to source code method or function names, known as symbols.

As the compiler translates your source code into machine code, it also generates debug symbols which map each machine instruction in the compiled binary back to the line of source code from which it originated. Depending on build setting, these debug symbols are stored inside the binary or in a companion Debug Symbol (dSYM) file.

There are different ways to symbolicate a crash report.

**It is strongly recommended to read [this article](https://developer.apple.com/library/archive/technotes/tn2151/_index.html)**

The following is just a summary to illustrate symbolication based on example data stored in this repository

Target is to symbolicate frame 2 of thread 0 in `unsymCrashExportedFromApp.crash`

![](addessToSym.png)

|Information|Found in Section|Value (given example)|
|--- | --- | --- |
|Stack Address a.k.a "addres to symbolicate"|Crash File, Exception Backtrace|0x00000001049738a4|
|Load Address|Crash File, Exception Backtrace|0x10496c000|
|dSYM UUID|Crash File, Binary Images|9d6b5e007246317c89bb5f941e71b227|
|Binary Architecture|Crash File, Binary Images|arm64|
|Binary Image Name|Crash File, Binary Images|plcrashreporterusage|
|Slide Value|lookup with help of dSYM File|0x100000000|
|Symbol Offset|Crash File, Exception Backtrace| (0x78A4)|
|File Address|**Derived** stack address - load address + slide |0x1000078A4|

The slide value can be obtained as following

```bash
otool -arch arm64 -l ./9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM/Contents/Resources/DWARF/plcrashreporterusage | grep __TEXT -m 2 -A 1 | grep vmaddr

vmaddr 0x0000000100000000
```

but it appears to be always 0x100000000 for arm64


The app was distributed via TestFlight and a symbolicated crash report was downloaded from TestFlight and is available in `symCrashLogExportedFromTestFlight.crash`

## Symbolicating Crash Reports with Atos

The [atos](https://www.unix.com/man-page/osx/1/atos/) command, available on OSX (Mac), converts numeric addresses to their symbolic equivalents

To symbolicate a part of a crash report using atos:

1. Find a line in the backtrace which you want to symbolicate. Note the name of the binary image in the second column, and the address in the third column.
2. Look for a binary image with that name in the list of binary images at the bottom of the crash report. Note the architecture and load address of the binary image.
3. Locate the dSYM file for the binary (based on the dSYM UUID). You must provide the path to this file, not to the dSYM bundle, when invoking atos.
4. With the above information you can symbolicate addresses in the backtrace using the atos command. You can specify multiple addresses to symbolicate, separated by a space.

Scheme   
```
atos -arch <Binary Architecture> -o <Path to dSYM file>/Contents/Resources/DWARF/<binary image name> -l <load address> <address to symbolicate>
```

So to symbolicate information on line 22 of file `unsymCrashExportedFromApp.crash`

![](addessToSym.png)

the following atos command

```
atos -arch arm64 -o ./9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM/Contents/Resources/DWARF/plcrashreporterusage -l 0x10496c000 0x00000001049738a4
```

will provide the necessary result

```
closure #1 in closure #1 in ContentView.body.getter (in plcrashreporterusage) (ContentView.swift:0)
```

`ATTENTION` **line number is incorrect** as line number should be 20 in this example to match the symbolicated crash report which was downloaded from TestFlight. [This quirk](./quirks/README.md) will help to find out the correct number.

Investigation still ongoing if this might be related due to optimization levels for Swift compiler or maybe some Swift closure related quirk.

You can configure the Optimization Level option in the Xcode Build Settings under the Swift Compiler - Code Generation section.

But how did we know which dSYM file to use in the first place? The Binary Image in question contains a UUID 

```
Binary Images:
0x10496c000 - 0x1049b3fff plcrashreporterusage arm64  <9d6b5e007246317c89bb5f941e71b227> /var/containers/Bundle/Application/C4EB205D-AAD3-4887-B5DB-C3FB6641BE48/plcrashreporterusage.app/plcrashreporterusage
```

We have to find a dSYM file matching this UUID! The UUID of a dSYM can be easily retrieved using the dwarfdump command:

```bash
dwarfdump -u 9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM
```

Output

```bash
UUID: 9D6B5E00-7246-317C-89BB-5F941E71B227 (arm64) 9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM/Contents/Resources/DWARF/plcrashreporterusage
```

Here we are able to verif that UUIDs are semantically the same but in the .crash file the UUID is **without capital letters and without hyphens** (i.e. 9d6b5e007246317c89bb5f941e71b227).

So even if the dSYM file has a different name it's possible to lookup which dSYM file is needed. On a MAC the app developer can use the following command to lookup the file path(s) for a dSYM file(s) in question: 

```bash
mdfind "com_apple_xcode_dsym_uuids == 9D6B5E00-7246-317C-89BB-5F941E71B227"
```

## Symbolicating Crash Reports with symbolicatecrash

So far, we’ve looked at tools that symbolicate specific addresses within a crash, or at best a series of addresses in the case of ATOS. To make this process easier, Apple ships a Perl script `symbolicatecrash` ([see here for script source code](./symbolicatecrash)) with XCode that expedites the symbolication process of a crash report in its entirety. If you have a dSYM, your app binary and a crash report, this is probably the easiest method of symbolication. You don’t have to worry about any of the addresses – this script will parse the whole crash dump file and use ATOS to resolve all of the addresses into symbols for you.

Example

```bash
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

./symbolicatecrash unsymCrashExportedFromApp.crash > symCrashLogWithSymbolicatecrashCommand.crash
```

See [here](https://www.apteligent.com/technical-resource/symbolicating-an-ios-crash-report/) for more details.

## Other techniques

For a good overview and details see [here](https://www.apteligent.com/technical-resource/symbolicating-an-ios-crash-report/)

### Symbolicating with **lldb**

lldb is the default debugger in XCode on OSX and can be used to symbolicate lines from a crash. lldb is again included with XCode for OSX, and there are ports for Linux, FreeBSD and Windows available.

lldb requires the file address for symbolication. For calculation the following seems to do the trick: address to symbolize - load address + slide value

Example:

```
(lldb) target create --arch arm64 9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM/Contents/Resources/DWARF/plcrashreporterusage

Current executable set to '9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM/Contents/Resources/DWARF/plcrashreporterusage' (arm64).
```

```bash
(lldb) image lookup --address 0x1000078A4

Address: plcrashreporterusage[0x00000001000078a4] (plcrashreporterusage.__TEXT.__text + 8184)
Summary: plcrashreporterusage` + 84 at ContentView.swift
```

See [here](./quirks/README.md) how to find out the correct line number which caused the crash.

More info: https://lldb.llvm.org/use/symbolication.html#

### Symbolicating with **Dwarfdump**

version of Dwarfdump is shipped with the XCode developer tools, but you can also get it, along with libdwarf, from the libdwarf project page

Note: Dwarfdump requires file address!

Example

```bash
dwarfdump --arch arm64 9d6b5e00-7246-317c-89bb-5f941e71b227.dSYM --lookup 0x1000078A4 | grep 'Line info'

Line info: file '/Users/<reducted>/git/plcrashreporterusage/plcrashreporterusage/ContentView.swift', line 0, column 0, start line 0
```

## Note: symbolicating on Linux

Most of the tools are OSX specific so either 3rd party or custom ports are needed to be used.

There is an unmaintained port for atos available on own risk: https://github.com/facebookarchive/atosl

Other option can be lldb (llvm) as it appears there is a proof record by [Sentry](https://blog.sentry.io/2017/04/11/ios-symbolication-troubles) with an own LLVM based symbolication library for Python

## Note: symbolicating iOS system symbols

 It is cumbersome to obtain iOS system symbols as Apple does not provide a symbol server. iOS system symbol files can be obtained from (previous) Xcode installations. 

One brave OS contributor tries to collect all iOS system symbols: https://github.com/Zuikyo/iOS-System-Symbols

Once iOS system symbol files (matching OS Version and CPU architecture of device) are obtained the same tooling is possible to symbolicate such related entry in the crash report.

Example

```
34  libdyld.dylib                      0x00000001a2a30360 0x1a2a2f000 + 4960
```

To symbolicate this line we need the dynamic libary `libdyld.dylib`. I collected the file from /Users/\<UserName>/Library/Developer/Xcode/iOS DeviceSupport/13.3.1 (17D50)/Symbols/usr/lib folder and stored it in [./systemLibaries/libdyld.dylib](./systemSymbols/libdyld.dylib)

We can use either atos to symbolicate

```bash
 atos -arch arm64 -o './systemSymbols/libdyld.dylib' -l 0x1a2a2f000 0x00000001a2a30360

start (in libdyld.dylib) + 4
```

or other tools (like lldb)

```bash
# 1. get slide value:
otool -arch arm64 -l ./systemSymbols/libdyld.dylib | grep __TEXT -m 2 -A 1 | grep vmaddr

# result: vmaddr 0x0000000180293000

# 2. calculate file address: (0x00000001a2a30360 - 0x1a2a2f000 + 0x0000000180293000 = 0x180294360)

# 3. load executable in lldb
lldb target create --arch arm64 ./systemSymbols/libdyld.dylib

# Result: Current executable set to './systemSymbols/libdyld.dylib' (arm64).

# 4. finally look up file address
(lldb) image lookup -a 0x180294360
      
# Result

# Address: libdyld.dylib[0x0000000180294360] (libdyld.dylib.__TEXT.__text + 4)
# Summary: libdyld.dylib`start + 4

```

Another example for a **framework** (file not bundled in this repository)

```
atos -arch arm64 -o '/Users/<UserName>/Library/Developer/Xcode/iOS DeviceSupport/13.3.1 (17D50)/Symbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI' -l 0x1d9493000 0x00000001d96073c4

partial apply for PrimitiveButtonStyleConfiguration.trigger() (in SwiftUI) + 20
```
