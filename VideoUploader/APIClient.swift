import Foundation
import UIKit
import Alamofire

// mime-type: https://www.tagindex.com/html5/basic/mimetype.html
struct API {
    let baseURL = URL(string: "http://localhost:3000/api/v1/videos")!
    static func postData(videoClipPath: URL, videoClipName: String){
        let videoClip = videoClipPath
        //multipart/form-dataでデータを送信する方法
        Alamofire.upload(multipartFormData: { multipartFormData in
            //multipartFormDataオブジェクトに対してデータの追加を行う
//            if let data = data {
//                multipartFormData.append(data, withName: "data" , mimeType: "text/plain")
                multipartFormData.append(videoClip, withName: "clip", fileName: videoClipName, mimeType: "video/quicktime")
//            }

            print(multipartFormData.boundary)
        }, to: url) { encodingResult in
            //encodingが成功するとこのハンドラが呼ばれる
            switch encodingResult {
            case.success(let upload, _ ,_):
                print(upload)
                upload
                    .uploadProgress(closure: { (progress) in
                        //進捗率の取得
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
            case.failure(let error):
                print(error)
            }
        }
    }

    static func fetchLatestVideo() {
        
    }
}
