NTAS="$HOME/playground/necessitas"
export ANDROID_NDK_HOST="darwin-x86"
export ANDOIRD_NDK_PLATFORM="android-9"
export ANDROID_NDK_ROOT="$NTAS/android-ndk-r6b"
export ANDROID_NDK_TOOLCHAIN_PREFIX="arm-linux-androideabi"
export ANDROID_NDK_TOOLCHAIN_VERSION="4.4.3"
export ANDROID_NDK_TOOLS_PREFIX="$ANDROID_NDK_TOOLCHAIN_PREFIX"
export QTDIR="$NTAS/Android/Qt/480/armeabi-v7a"
export PATH="$QTDIR/bin":$PATH

qmake "$1" -r -spec android-g++
make -j5
make INSTALL_ROOT="$(dirname "$1")/android" install
cd $(dirname "$1")
ant clean debug
