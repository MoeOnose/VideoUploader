import Foundation
import UIKit
import Alamofire


struct API {
    static let baseUrlStr = "http://localhost:3000/api/v1"
    static func postData(videoClipPath: URL, videoClipName: String){
        let requestUrl = URL(string: "\(baseUrlStr)/videos")!
        //multipart/form-dataでデータを送信する
        Alamofire.upload(multipartFormData: { multipartFormData in
            //multipartFormDataオブジェクトに対してデータの追加を行う
            //withNameはrailsのActiveStorage側で保存するときのキーと同じ
            //mimeTypeは、今回.MOVのファイルを扱うので"video/quicktime"を指定
            // mime-type: https://www.tagindex.com/html5/basic/mimetype.html
            multipartFormData.append(videoClipPath, withName: "clip", fileName: videoClipName, mimeType: "video/quicktime")
        }, to: requestUrl) { encodingResult in
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
    static func fetchLatestVideoUrl(completion: @escaping (URL) -> ()) {
        //レスポンスの型
        struct FetchResult: Codable {
            let url: String
        }
        let requestUrl = URL(string: "\(baseUrlStr)/videos/fetch_latest_video")!
        //今回パラメーターは特に必要ないので[:](空)で！
        Alamofire.request(requestUrl, method: .get, parameters: [:])
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Success!")
                    //レスポンスを定義したFetchResultに変換する
                    guard
                        let data = response.data,
                        let result = try? JSONDecoder().decode(FetchResult.self, from: data),
                        //取得できたFetchResultオブジェクトのurl(String🥶)からURLを生成
                        let fetchedUrl = URL(string: result.url)
                    else { return }
                    //取得できたURLをクロージャーに渡す
                    completion(fetchedUrl)
                case .failure:
                    print("Failure!")
                }
        }
    }
}
