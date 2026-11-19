#include "about.h"

#include <QCoreApplication>
#include <QString>

#include "revision_utils.hpp"

#include "ui_about.h"

CAboutDlg::CAboutDlg(QWidget *parent) :
  QDialog(parent),
  ui(new Ui::CAboutDlg)
{
  ui->setupUi(this);

  ui->labelTxt->setText ("<h2>" + QString {"JTTY Unicode v%1"}.arg (version ()) + "</h2>"

    "Developed from the open-source WSJT-X™ codebase for weak-signal amateur radio communication.<br /><br />"
    "BI3BJU implemented Unicode transmission over JTTY: UTF-8 multi-frame encoding, "
    "CRC-8 verification, and cross-frame character reassembly.<br />"
    "Open source: <a href=\"https://github.com/BI3BJU\">https://github.com/BI3BJU</a>"
    "<br /><br />"
    "&copy; 2001-2026 by Joe Taylor, K1JT, Bill Somerville, G4WJS, <br />"
    "Steve Franke, K9AN, Nico Palermo, IV3NWV, <br />"
    "Uwe Risse, DG2YCB, Brian Moran, N9ADG, <br />"
    "Roger Rehr, W3SZ, John Nelson, G4KLA, <br />"
    "Charlie Suckling, DL3WDG, Terrell Deppe, KJ5HST,<br />"
    "and David Christle, KD0BTO <br /><br />"
    "Thanks to everyone who has contributed to this project.<br /><br />"
    "Released under the GNU General Public License (GPL) v3.<br /><br />"
    "<a href=" TO_STRING__ (PROJECT_HOMEPAGE) ">"
    "<img src=\":/icon_128x128.png\" /></a>"
    "<a href=\"https://www.gnu.org/licenses/gpl-3.0.txt\">"
    "<img src=\":/gpl-v3-logo.svg\" height=\"80\" /><br />"
    "https://www.gnu.org/licenses/gpl-3.0.txt</a>");
}

CAboutDlg::~CAboutDlg()
{
}