# script to install a command line utility for MacOS to
# open specified file with associated application
# Install: sh install_ko.sh
# Use the utility: ko ~/some/file.avi

mkdir ko
cd ko

cat << EOF > main.cpp
#include<QDesktopServices>
#include<QUrl>

int main(int argc, char* argv[])
{
    return QDesktopServices::openUrl(QUrl::fromLocalFile(argv[1]));
}
EOF

qmake -project
qmake -spec macx-g++
make
sudo cp ko.app/Contents/MacOS/ko /usr/local/bin
cd ..
rm -rf ko
