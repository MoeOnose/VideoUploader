import Foundation

struct Video {
    //cf.https://asahi-net.jp/support/guide/homepage/0017.html
    enum MimeType: String {
        case mov = "video/quicktime", jpeg = "image/jpeg"
    }
    var data: Data
    var mimeType: MimeType
    var filename: String

    init(data: Data, mimeType: MimeType, filename: String) {
        self.data = data
        self.mimeType = mimeType
        self.filename = filename
    }
}
