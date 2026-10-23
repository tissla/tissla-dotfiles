The nebula shader deforms the cached galaxy texture using a shared desktop coordinate
system and animation time. Only the gas renders at half resolution; stars and the HUD
remain full resolution. The CPU software renderer uses the static galaxy fallback.

Rebuild the checked-in shader after editing `nebula.frag`:

```sh
/usr/lib/qt6/bin/qsb --qt6 -o Lock/shaders/nebula.frag.qsb Lock/shaders/nebula.frag
```
