this is not a real boot-loader.
It is for linux simulation.
It is bootram application which just:
1) enables cache, 
2) copies ATAG table into memory 
3) jumps into 80000 address where simulator already has vmlinux preloaded.