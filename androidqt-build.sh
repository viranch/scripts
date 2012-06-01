NTAS="$HOME/playground/necessitas"
export ANDROID_NDK_HOST="darwin-x86"
export ANDROID_NDK_PLATFORM="android-9"
export ANDROID_NDK_ROOT="$NTAS/android-ndk-r6b"
export ANDROID_NDK_TOOLCHAIN_PREFIX="arm-linux-androideabi"
export ANDROID_NDK_TOOLCHAIN_VERSION="4.4.3"
export ANDROID_NDK_TOOLS_PREFIX="$ANDROID_NDK_TOOLCHAIN_PREFIX"
export QTDIR="$NTAS/Android/Qt/480/armeabi-v7a"
export PATH="$QTDIR/bin":$PATH

qmake "$1" -r -spec android-g++
make -j5
make INSTALL_ROOT="$(dirname "$1")/android" install
$ANDROID_NDK_ROOT/toolchains/$ANDROID_NDK_TOOLCHAIN_PREFIX-$ANDROID_NDK_TOOLCHAIN_VERSION/prebuilt/$ANDROID_NDK_HOST/bin/$ANDROID_NDK_TOOLS_PREFIX-strip "$(dirname "$1")/android/libs/armeabi-v7a/*.so"

cd $(dirname "$1")/android
ant clean release
cd bin/
jarsigner -verbose -keystore viranch.keystore *.apk viranch
PKG_NAME=$(basename `ls *.apk` .apk)
APK=$(echo $PKGNAME | sed 's/-unsigned//g').apk
$NTAS/android-sdk/tools/zipalign 4 *.apk $APK
