![JTTY Unicode](logo.png)

# JTTY Unicode

## Weak-Signal Communication Software with Unicode JTTY

JTTY Unicode is an open-source fork of WSJT-X™, developed from the WSJT-X
codebase for weak-signal amateur radio communication. It keeps the full
WSJT-X mode set and adds Unicode text transmission over JTTY.

BI3BJU implemented Unicode transmission over JTTY: UTF-8 multi-frame encoding,
CRC-8 verification, and cross-frame character reassembly.

Current version: **3.2.0-rc1.261122**

Open source: <https://github.com/BI3BJU>

## JTTY Unicode

*JTTY Unicode* extends the native JTTY keyboard mode with Unicode text:

- UTF-8 messages of up to 63 bytes, carried in 1–16 JTTY frames;
- 4 UTF-8 bytes per frame, with a final 3-byte frame protected by CRC-8;
- automatic native/Unicode selection: pure-ASCII text keeps the native JTTY path;
- damaged Unicode frames are marked with a localized "[checksum missing]" marker;
- All Decodes and QSO Frequency panes show saved history with UTC timestamps and
  Tx/Rx markers, and right-click Erase can remove JTTY records from ALL.TXT.

The extension is backward compatible with the native JTTY frame format.

## Interoperability with JTTY Unicode for Android

JTTY Unicode for Windows and [JTTY Unicode for
Android](https://github.com/BI3BJU/JTTY_Unicode_Android) use the same over-the-air
protocol and decode each other directly:

- **Native JTTY frames** are identical to WSJT-X 3.2 and work in both directions.
- **Unicode extension frames** (bit 33, four UTF-8 bytes per frame, CRC-8, up to
  63 bytes in 1–16 frames) work in both directions.
- No gateway, bridge or text conversion is required: both programs transmit and
  receive the same GFSK waveform at the same audio offset.
- The Android app's whole-passband decoder (300–2700 Hz) and the Windows wideband
  search decode the signal without forcing the Rx frequency marker onto the
  sender's audio offset.
- Verified with **Windows 3.2.0-rc1.261122** and **Android 0.1.0.261122**.

For Unicode text, both ends need a build with the Unicode extension
(Windows 3.2.0-rc1.261122+ / Android 0.1.0.261122+). Native JTTY remains
compatible with unmodified WSJT-X 3.2.

## Programs

*JTTY Unicode* is built on the WSJT-X codebase and runs on Windows, macOS, and
Linux. It works with a standard SSB transceiver. The program is open source,
free of charge, and licensed under the GNU General Public License.

*JTTY Unicode* implements the WSJT-X communication protocols **FST4**,
**FST4W**, **FT4**, **FT8**, **JT4**, **JT9**, **JT65**, **JTTY**, **MSK144**,
**Q65**, **WSPR**, and **Echo**. Its two-way modes are designed for making
reliable, confirmed QSOs in a wide variety of weak-signal propagation
circumstances. Most use timed Transmit/Receive sequences of specific lengths,
synchronized with UTC. **JTTY** supports fast RTTY-like contest exchanges and
other keyboard-to-keyboard communication, and in this fork it also carries
Unicode text. **WSPR** and **FST4W** are for probing potential propagation paths
with low-power transmissions, and **Echo** is for detecting and measuring
reflections of your own signals from the Moon.

WSJT-X™ is a trademark of the WSJT Development Team; JTTY Unicode is an
independent fork. See [TRADEMARK.md](TRADEMARK.md) for the upstream policy.

## Mode Details

**JT4**, **JT9**, and **JT65** use nearly identical message structure, efficient compression of messages for minimal QSOs, and 60-second T/R sequences. **JT4** and **JT65** were designed for EME on the VHF, UHF, and microwave bands, while **JT9** is optimized for the MF and HF bands. **JT9** is about 1 dB more sensitive than **JT65** while using less than 10% of the bandwidth.

**FT4** and **FT8** use T/R cycles of only 7.5 and 15 s, respectively. They have become extremely popular for world-wide DXing on the HF bands. **MSK144** is designed for Meteor Scatter on the VHF bands. **Q65** offers submodes with T/R sequence lengths from 15 seconds to 5 minutes, and a wide range of tone spacings. Particular Q65 submodes are highly recommended for EME, ionospheric scatter, and other weak signal work on VHF, UHF, and microwave bands. These modes include message formats explicitly supporting nonstandard callsigns and some popular radio contests.

**FST4** and **FST4W** are designed particularly for the LF and MF bands. On these bands their fundamental sensitivities are better than other *WSJT-X* modes with the same sequence lengths, approaching the theoretical limits for their rates of information throughput. **FST4** is optimized for two-way QSOs, while **FST4W** is for quasi-beacon transmissions of **WSPR**-style messages. **FST4** and **FST4W** do not require the strict, independent time synchronization and phase locking of modes like EbNaut.

Documentation for operating procedures, mode details, configuration, and
platform installation is included in this repository under `doc/`.

## Building from source

The [source-build guide](doc/user_guide/en/install-from-source.adoc) is the
maintained reference for developer builds, including the supported Windows
MSYS2 environment, required dependencies, tests, installation, and common
failures. Contributors should also read [CONTRIBUTING.md](CONTRIBUTING.md) for
the repository and development workflow.

## Support and contributing

Source code, bug reports, and pull requests are hosted at
[github.com/BI3BJU](https://github.com/BI3BJU). Please use the GitHub issue
tracker there for questions, bug reports, and contributions.

## Credits

© 2001–2026 by Joe Taylor, K1JT, Bill Somerville, G4WJS,
Steve Franke, K9AN, Nico Palermo, IV3NWV,
Uwe Risse, DG2YCB, Brian Moran, N9ADG,
Roger Rehr, W3SZ, John Nelson, G4KLA,
Charlie Suckling, DL3WDG, Terrell Deppe, KJ5HST,
and David Christle, KD0BTO.

Thanks to everyone who has contributed to this project.

## License

JTTY Unicode is free software licensed under the GNU General Public License
version 3. See [COPYING](COPYING) for the full license.
