
####sere.pl
**Search & Replace Utility, Rel. 0.4 - 2012/11/23**

**Benutzung**

perl sere.pl -search="RegExp" -replace="String" [-overwrite] Dateien

**Argumente**

-search  = Suchtext (regulaerer Ausdruck)

-replace = Ersatztext (String)

Dateien  = Zu bearbeitende Dateien

**Optionen**

-overwrite = Ausgangsdatei ueberschreiben

**Anmerkungen**

Soll nach Metazeichen gesucht werden, so sind diese mit \ zu maskieren.

Regular Expression Metazeichen: * + ? . ( ) [ ] { } \ / | ^ $

Soll nach Begrenzerzeichen gesucht werden, so sind dieses mit \ zu maskieren.

Regular Expression Begrenzer: #

**Beispiele**

perl sere.pl -search="1210" -replace="1211" *.html

perl sere.pl -search="1210" -replace="1211" *.html *.txt

perl sere.pl -search="Ausgabe 12\.10" -replace="Ausgabe 12.11" *.html
