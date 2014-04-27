
purge_images.pl - Bereinigung nicht referenzierter Images, Rel. 0.1.0 - 2014/04/24

Benutzung
=========
perl purge_images.pl -image="Verzeichnis/Maske" Dateien 

Argumente:
-imagedir  = Verzeichnis und Maske der Imagedateien
Dateien    = zu verifizierende Dateien (html, css, ...)

Beispiele
=========
perl purge_images.pl  -imagedir="/fzk.de/android/images/*"  "fzk.de/android/*"  "fzk.de/android/de/*"
perl purge_images.pl  -imagedir="/fzk.de/images/*"  "/fzk.de/*"  "/fzk.de/en/*"  "/fzk.de/de/*"

