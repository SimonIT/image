import '../decode_info.dart';

class BmpInfo extends DecodeInfo {
  // The number of frames that can be decoded.
  int get numFrames => 1;

  BmpFileHeader fileHeader = BmpFileHeader();
  BmpInfoHeader infoHeader = BmpInfoHeader();
}

class BmpFileHeader {
  int type = 0; // uint16
  int size = 0; // uint32
  int reserved1 = 0; // uint16
  int reserved2 = 0; // uint16
  int offsetBits = 0; // uint32
}

class BmpInfoHeader {
  int size = 0; // uint32
  int width = 0; // uint32
  int height = 0; // uint32
  int planes = 0; // uint16
  int bitCount = 0; // uint16
  int compression = 0; // uint32
  int sizeImage = 0; // uint32
  int xPixelsPerMeter = 0; // uint32
  int yPixelsPerMeter = 0; // uint32
  int colorsUsed = 0; // uint32
  int colorsImportant = 0; // uint32
}