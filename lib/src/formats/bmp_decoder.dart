import '../animation.dart';
import '../color.dart';
import '../image.dart';
import '../util/input_buffer.dart';
import 'bmp/bmp_info.dart';
import 'decoder.dart';
import 'decode_info.dart';

/// Decode a BMP image.
class BmpDecoder extends Decoder {
  InputBuffer input;
  BmpInfo info;

  // There are other BMP formats, such as BA, CI, CP, IC, and PT, but they
  // are not currently supported.
  static const BM_FORMAT = 0x4D42;

  /// Is the given file a valid BMP image?
  bool isValidFile(List<int> data) {
    InputBuffer input = InputBuffer(data, bigEndian: false);

    InputBuffer header = input.readBytes(14);
    int format = header.readUint16();
    if (format != BM_FORMAT) {
      return false;
    }

    int dibHeaderSize = input.readUint32();
    if (dibHeaderSize >= input.length) {
      return false;
    }

    return true;
  }

  DecodeInfo startDecode(List<int> data) {
    input = InputBuffer(data, bigEndian: false);

    InputBuffer header = input.readBytes(14);

    info = BmpInfo();

    info.fileHeader.type = header.readUint16();
    if (info.fileHeader.type != BM_FORMAT) {
      return null;
    }

    info.fileHeader.size = header.readUint32();
    info.fileHeader.reserved1 = header.readUint16();
    info.fileHeader.reserved2 = header.readUint16();
    info.fileHeader.offsetBits = header.readUint32();

    info.infoHeader.size = input.readUint32();

    info.width = input.readInt32();
    info.height = input.readInt32();
    info.infoHeader.width = info.width;
    info.infoHeader.height = info.height;
    info.infoHeader.planes = input.readUint16();
    if (info.infoHeader.planes != 1) {
      return null;
    }
    info.infoHeader.bitCount = input.readUint16();
    info.infoHeader.compression = input.readUint32();
    info.infoHeader.sizeImage = input.readUint32();
    info.infoHeader.xPixelsPerMeter = input.readUint32();
    info.infoHeader.yPixelsPerMeter = input.readUint32();
    info.infoHeader.colorsUsed = input.readUint32();
    info.infoHeader.colorsImportant = input.readUint32();

    return info;
  }

  int numFrames() => info != null ? 1 : 0;

  Image decodeFrame(int frame) {
    if (info == null) {
      return null;
    }

    input.offset = info.fileHeader.offsetBits;
    Image image = Image(info.width, info.height,
        channels: info.infoHeader.bitCount == 32 ? Channels.rgba : Channels.rgb);

    int bytesPerPixel = info.infoHeader.bitCount >> 3;
    int rowStride = (info.width * bytesPerPixel);
    while (rowStride % 4 != 0) {
      rowStride++;
    }

    int h = image.height;
    int w = image.width;
    for (int y = h - 1; y >= 0; --y) {
      InputBuffer row = input.readBytes(rowStride);
      for (int x = 0; x < w; ++x) {
        int b = row.readByte();
        int g = row.readByte();
        int r = row.readByte();
        int a = info.infoHeader.bitCount == 32 ? 255 - row.readByte() : 255;

        image.setPixel(x, y, getColor(r, g, b, a));
      }
    }

    return image;
  }

  Image decodeImage(List<int> data, {int frame = 0}) {
    if (startDecode(data) == null) {
      return null;
    }

    return decodeFrame(frame);
  }

  Animation decodeAnimation(List<int> data) {
    Image image = decodeImage(data);
    if (image == null) {
      return null;
    }

    Animation anim = Animation();
    anim.width = image.width;
    anim.height = image.height;
    anim.addFrame(image);

    return anim;
  }
}
