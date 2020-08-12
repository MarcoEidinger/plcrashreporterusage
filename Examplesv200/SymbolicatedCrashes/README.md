This are examples of symbolicated crashes with `symbolicatecrash` tool

Example how-to generate:

```
./symbolicatecrash ../UnsymbolicatedCrashes/shakeRandom6.crash > shakeRandom6.crash
```



Example to symbolicate stack frame `2  SAPFoundation                      0x00000001028ecb84 0x1027e4000 + 1084292` in file ../UnsymbolicatedCrashes/frw.crash with `atos`

```
atos -arch arm64 -o ../InfosToSymbolicate/HCP-SDK-for-iOS-dSYM-iphoneos/SAPFoundation.framework.dSYM/Contents/Resources/DWARF/SAPFoundation -l 0x1027e4000 0x00000001028ecb84
```
