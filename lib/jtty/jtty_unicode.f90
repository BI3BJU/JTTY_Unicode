module jtty_unicode

! JTTY Plus extension frames: UTF-8 bytes carried on the JTTY physical layer.
!
! Payload layout (JTTY bit numbering, bit 1 is the first transmitted bit):
!
!   bits 1-32  four content/padding/CRC bytes, most significant bit first
!   bit  33    '1'  extension-frame marker
!   bit  34    '1'  end of message (final frame only)
!
! A message is 1..16 frames in phase 1 (64 frames later).  Every frame carries
! four bytes; the final frame carries three content bytes plus one CRC-8/ATM
! byte over all preceding bytes (including 0x20 padding).  Content is UTF-8;
! padding is 0x20.

  implicit none
  private

  ! Phase 1 uses the unmodified JTTY frame limit; phase 2 raises this to 64.
  integer, parameter, public :: JTTY_UNICODE_MAX_FRAMES = 16
  integer, parameter, public :: JTTY_UNICODE_BYTES_PER_FRAME = 4
  integer, parameter, public :: JTTY_UNICODE_MAX_BYTES = &
       JTTY_UNICODE_MAX_FRAMES * JTTY_UNICODE_BYTES_PER_FRAME - 1
  integer, parameter, public :: JTTY_UNICODE_MAX_MESSAGE = &
       JTTY_UNICODE_MAX_FRAMES * JTTY_UNICODE_BYTES_PER_FRAME
  ! Receive-side assembly buffer: content, CRC byte, gap placeholders and the
  ! damage marker may exceed the 64-byte pack limit.
  integer, parameter, public :: JTTY_UNICODE_BUFFER = 128

  character(len=1), parameter, public :: JTTY_UNICODE_PAD = achar (32)
  ! Marker used for each frame lost between assembled frames: U+FFFD + space,
  ! exactly four bytes so byte alignment is preserved.
  character(len=4), parameter, public :: JTTY_UNICODE_GAP = &
       char (239) // char (191) // char (189) // char (32)

  ! UTF-8 text for "checksum missing", appended when the message CRC8 does not match.
  character(len=14), parameter, public :: JTTY_UNICODE_DAMAGED = &
       '[' // char (230) // char (160) // char (161) // char (233) // &
       char (170) // char (140) // char (231) // char (188) // char (186) // &
       char (229) // char (164) // char (177) // ']'

  public :: jtty_unicode_crc8, jtty_unicode_pack, jtty_unicode_unpack_frame, &
       jtty_unicode_verify, jtty_unicode_lead_byte

contains

  pure integer function jtty_unicode_crc8 (bytes, count) result (crc)
    character(len=*), intent(in) :: bytes
    integer, intent(in) :: count
    integer :: i, bit

    crc = 0
    do i = 1, count
      crc = ieor (crc, iachar (bytes(i:i)))
      do bit = 1, 8
        if (btest (crc, 7)) then
          crc = iand (ishft (crc, 1), 255)
          crc = ieor (crc, 7)
        else
          crc = iand (ishft (crc, 1), 255)
        end if
      end do
    end do
  end function jtty_unicode_crc8

  pure logical function jtty_unicode_lead_byte (c) result (ok)
    character(len=1), intent(in) :: c
    integer :: byte_value

    byte_value = iachar (c)
    ok = (byte_value >= 32 .and. byte_value <= 126) .or. &
         (byte_value >= 194 .and. byte_value <= 223) .or. &
         (byte_value >= 224 .and. byte_value <= 239)
  end function jtty_unicode_lead_byte

  subroutine jtty_unicode_pack (message, nbytes, c32, nframes, valid)
    character(len=*), intent(in) :: message
    integer, intent(in) :: nbytes
    character(len=34), intent(out) :: c32(JTTY_UNICODE_MAX_FRAMES)
    integer, intent(out) :: nframes
    logical, intent(out) :: valid
    character(len=JTTY_UNICODE_MAX_MESSAGE) :: buffer
    integer :: i, byte_index, bit_index, byte_value, total, crc

    c32 = ''
    nframes = 0
    valid = .false.
    if (nbytes < 1 .or. nbytes > JTTY_UNICODE_MAX_BYTES) return
    nframes = (nbytes + 1 + JTTY_UNICODE_BYTES_PER_FRAME - 1) / JTTY_UNICODE_BYTES_PER_FRAME
    if (nframes < 1 .or. nframes > JTTY_UNICODE_MAX_FRAMES) return
    total = nframes * JTTY_UNICODE_BYTES_PER_FRAME

    buffer = JTTY_UNICODE_PAD
    buffer(1:nbytes) = message(1:nbytes)
    crc = jtty_unicode_crc8 (buffer, total - 1)
    buffer(total:total) = achar (crc)

    do i = 1, nframes
      do byte_index = 1, 4
        byte_value = iachar (buffer((i - 1) * 4 + byte_index:(i - 1) * 4 + byte_index))
        do bit_index = 7, 0, -1
          if (btest (byte_value, bit_index)) then
            c32(i)((byte_index - 1) * 8 + (7 - bit_index) + 1 : &
                   (byte_index - 1) * 8 + (7 - bit_index) + 1) = '1'
          else
            c32(i)((byte_index - 1) * 8 + (7 - bit_index) + 1 : &
                   (byte_index - 1) * 8 + (7 - bit_index) + 1) = '0'
          end if
        end do
      end do
      c32(i)(33:33) = '1'
      if (i == nframes) then
        c32(i)(34:34) = '1'
      else
        c32(i)(34:34) = '0'
      end if
    end do
    valid = .true.
  end subroutine jtty_unicode_pack

  subroutine jtty_unicode_unpack_frame (frame, bytes, extension, eom, valid)
    character(len=34), intent(in) :: frame
    character(len=4), intent(out) :: bytes
    logical, intent(out) :: extension, eom, valid
    integer :: byte_index, bit_index, byte_value

    bytes = ''
    extension = .false.
    eom = .false.
    valid = .false.
    do bit_index = 1, 34
      if (frame(bit_index:bit_index) /= '0' .and. &
           frame(bit_index:bit_index) /= '1') return
    end do
    extension = frame(33:33) == '1'
    eom = frame(34:34) == '1'
    do byte_index = 1, 4
      byte_value = 0
      do bit_index = 1, 8
        byte_value = byte_value * 2
        if (frame((byte_index - 1) * 8 + bit_index : &
                  (byte_index - 1) * 8 + bit_index) == '1') byte_value = byte_value + 1
      end do
      bytes(byte_index:byte_index) = achar (byte_value)
    end do
    valid = .true.
  end subroutine jtty_unicode_unpack_frame

  pure logical function jtty_unicode_verify (bytes, count) result (ok)
    character(len=*), intent(in) :: bytes
    integer, intent(in) :: count

    ok = .false.
    if (count < 4 .or. count > JTTY_UNICODE_MAX_MESSAGE) return
    if (mod (count, JTTY_UNICODE_BYTES_PER_FRAME) /= 0) return
    ok = jtty_unicode_crc8 (bytes, count - 1) == iachar (bytes(count:count))
  end function jtty_unicode_verify

  ! C entry for the transmit path: pack UTF-8 bytes into 34-bit frames.
  subroutine jtty_unicode_pack_c (text, nbytes, frames, nframes, status) &
       bind (C, name='jtty_unicode_pack_c')
    use iso_c_binding, only: c_char, c_int
    character(kind=c_char), intent(in) :: text(*)
    integer(c_int), value, intent(in) :: nbytes
    character(kind=c_char), intent(out) :: frames(*)
    integer(c_int), intent(out) :: nframes
    integer(c_int), intent(out) :: status
    character(len=JTTY_UNICODE_MAX_BYTES) :: message
    character(len=34) :: local_frames(JTTY_UNICODE_MAX_FRAMES)
    integer :: i, j, nf
    logical :: valid

    nframes = 0
    status = 1
    if (nbytes < 1 .or. nbytes > JTTY_UNICODE_MAX_BYTES) return
    message = ''
    do i = 1, int (nbytes)
      message(i:i) = text(i)
    end do
    call jtty_unicode_pack (message, int (nbytes), local_frames, nf, valid)
    if (.not.valid) return
    do i = 1, nf
      do j = 1, 34
        frames((i - 1) * 34 + j) = local_frames(i)(j:j)
      end do
    end do
    nframes = nf
    status = 0
  end subroutine jtty_unicode_pack_c

end module jtty_unicode
