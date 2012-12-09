# script to open specified file with associated application
# Usage: qt-open ~/some/file.avi

import sys

try:
    from PyQt4.QtCore import QUrl
    from PyQt4.QtGui import QDesktopServices
    QDesktopServices.openUrl(QUrl.fromLocalFile(sys.argv[1]))
except IndexError:
    QDesktopServices.openUrl(QUrl.fromLocalFile('.'))
except:
    pass