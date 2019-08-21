cat Qt5.tar.bz2.* > ./Qt.tar.bz2
bzip2 -dc Qt.tar.bz2 | tar xvf -
del /q /s Qt.tar.bz2
