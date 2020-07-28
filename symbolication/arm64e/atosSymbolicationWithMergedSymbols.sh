echo "1. Crash on arm64e device ----------"
echo "merged symbols - atos with arm64e"
atos -arch arm64e -o './arm64e_and_arm64Symbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI' -l 0x1e4cde000 0x00000001e4d51a98
echo "-----"
echo "merged symbols - atos with arm64"
atos -arch arm64 -o './arm64e_and_arm64Symbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI' -l 0x1e4cde000 0x00000001e4d51a98
echo "-----"

echo "merged symbols - atos with arm64e"
atos -arch arm64e -o './arm64e_and_arm64Symbols/usr/lib/system/libdyld.dylib' -l 0x1aca78000 0x00000001aca792dc
echo "-----"
echo "merged symbols - atos with arm64"
atos -arch arm64 -o './arm64e_and_arm64Symbols/usr/lib/system/libdyld.dylib' -l 0x1aca78000 0x00000001aca792dc
echo "-----"

echo "2. Crash on arm64 device ----------"
echo "merged symbols - atos with arm64e"
atos -arch arm64e -o './arm64e_and_arm64Symbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI' -l 0x1d7e77000 0x00000001d7ee5560
echo "-----"
echo "merged symbols - atos with arm64"
atos -arch arm64 -o './arm64e_and_arm64Symbols/System/Library/Frameworks/SwiftUI.framework/SwiftUI' -l 0x1d7e77000 0x00000001d7ee5560
echo "-----"

echo "merged symbols - atos with arm64e"
atos -arch arm64e -o './arm64e_and_arm64Symbols/usr/lib/system/libdyld.dylib' -l 0x1a05d8000 0x00000001a05d98f0
echo "-----"
echo "arm64e symbols - atos with arm64"
atos -arch arm64 -o './arm64e_and_arm64Symbols/usr/lib/system/libdyld.dylib' -l 0x1a05d8000 0x00000001a05d98f0
echo "-----"
