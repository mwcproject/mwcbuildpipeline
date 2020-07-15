#!/bin/sh

# First update INCPATH
sed 's/^INCPATH.*/INCPATH       = -I. -I\$\(QT_DIR\)\/5.9.9\/clang_64\/lib\/QtSvg.framework\/Headers -I\$\(QT_DIR\)\/5.9.9\/clang_64\/lib\/QtWidgets.framework\/Headers -I\$\(QT_DIR\)\/5.9.9\/clang_64\/lib\/QtGui.framework\/Headers -I\$\(QT_DIR\)\/5.9.9\/clang_64\/lib\/QtNetwork.framework\/Headers -I\$\(QT_DIR\)\/5.9.9\/clang_64\/lib\/QtCore.framework\/Headers -I. -I\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/MacOSX.platform\/Developer\/SDKs\/MacOSX10.14.sdk\/System\/Library\/Frameworks\/OpenGL.framework\/Headers -I\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/MacOSX.platform\/Developer\/SDKs\/MacOSX10.14.sdk\/System\/Library\/Frameworks\/AGL.framework\/Headers -I. -I\$\(QT_DIR\)\/5.9.9\/clang_64\/mkspecs\/macx-clang -F\$\(QT_DIR\)\/5.9.9\/clang_64\/lib/' Makefile > Makefile.replace

# Caller suppose to set QT_INSTALL_PATH to QT location
# Add QT_DIR Variable
echo "QT_DIR=$QT_INSTALL_PATH" > Makefile.replace2
cat Makefile.replace >> Makefile.replace2

# Update libs
sed 's/^LIBS.*/LIBS          = -F\$\(QT_DIR\)\/5.9.9\/clang_64\/lib -framework AppKit -framework QtSvg -framework QtWidgets -framework QtGui -framework QtCore -framework DiskArbitration -framework IOKit -framework QtNetwork -framework OpenGL -framework AGL/' Makefile.replace2 > Makefile.replace3

sed 's/^LFLAGS.*/LFLAGS        = -stdlib=libc++ -headerpad_max_install_names \$\(EXPORT_ARCH_ARGS\) -Wl,-syslibroot,\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/MacOSX.platform\/Developer\/SDKs\/MacOSX.sdk -mmacosx-version-min=10.10 -Wl,-rpath,@executable_path\/..\/Frameworks -Wl,-rpath,@executable_path\/Frameworks -Wl,-rpath,\$\(QT_DIR\)\/5.9.9\/clang_64\/lib/' Makefile.replace3 > Makefile.replace4

# Delete plugin_import.o from linking
cp Makefile.replace4 Makefile.replace5
perl -pi -e 's/\tmwc-qt-wallet_plugin_import.o \\/\\/g' Makefile.replace5

# Switch to backwards compatible versions
perl -pi -e 's/MacOSX\d+\.\d+/MacOSX/g' Makefile.replace5

# Finally replace Original Makefile
mv Makefile.replace5 Makefile
rm -rf Makefile.replace*
