The UUID of a dSYM can be easily retrieved using the dwarfdump command:

```
dwarfdump -u plcrashreporterusage.app.dSYM
```

Output

```
UUID: 2812A6DA-379F-3AE8-AF85-36B663F1E515 (arm64) plcrashreporterusage.app.dSYM/Contents/Resources/DWARF/plcrashreporterusage
```

 0x101de6000

atos -arch arm64 -o /Users/d041771/git/plcrashreporterusage/dSYMs/plcrashreporterusage.app.dSYM/Contents/Resources/DWARF/plcrashreporterusage -l 0x101de6000 0x0000000101dea17c
-[AtomicElementViewController myTransitionDidStop:finished:context:]



