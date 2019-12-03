import UIKit
import Photos

import AVKit

class VideoUploaderViewController: UIViewController {
    private let playerViewController = AVPlayerViewController()

    private let imagePickerController = UIImagePickerController()
    private var videoUrl: NSURL?
    private var compressedVideoUrl: URL?

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBAction func didTapSelectButton(_ sender: Any) { selectVideo() }
    @IBAction func didTapPlayButton(_ sender: Any) { playVideo() }
    @IBAction func didTapUploadButton(_ sender: Any) { uploadVideo() }

    override func viewDidLoad() {
        super.viewDidLoad()
        confirmPhotoLibraryAuthenticationStatus()
    }
}

// MARK: Access permission
extension VideoUploaderViewController {
    private func confirmPhotoLibraryAuthenticationStatus() {
        //権限の現状確認
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            //許可されていないので確認アラートの表示
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                //初回(notDetermined)もしくは拒否されている(denied)の場合に再度アラートを表示する
                case .notDetermined, .denied:
                    self.appearChangeStatusAlert()
                default:
                    break
                }
            }
        }
    }
    private func appearChangeStatusAlert() {
        //許可していないユーザーに対して設定のし直しを促す。
        //タイトルとメッセージを設定しアラートモーダルを作成する
        let alert = UIAlertController(title: "Not authorized", message: "we need to access photo library to upload video", preferredStyle: .alert)
        //アラートには設定アプリを起動するアクションとキャンセルアクションを設置
        let settingAction = UIAlertAction(title: "setting", style: .default, handler: { (_) in
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
        })
        let closeAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        //アラートに２つのアクションを追加
        alert.addAction(settingAction)
        alert.addAction(closeAction)
        //アラートを表示させる
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Select video
extension VideoUploaderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func selectVideo() {
        print("select video from camera roll")
        //選択できるメディアは動画のみを指定
        self.imagePickerController.mediaTypes = ["public.movie"]
        //選択元はフォトライブラリ
        self.imagePickerController.sourceType = .photoLibrary
        //imagePickerControllerを呼び出して利用するのはVideoUploaderViewController
        self.imagePickerController.delegate = self
        //実際にimagePickerControllerを呼び出してフォトライブラリを開く
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    // MARK: Set thumbnail
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //UIImagePickerControllerReferenceURLはiOS11でdeprecatedになってる
        //代替はUIImagePickerControllerPHAsset && UIImagePickerControllerMediaURL(これかな)
        //PHAssetは画像や動画の情報を辞書で持ってる。取り出し方は以下の通り
        //let phKey = UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerPHAsset")
        //let phAsset = info[phKey] as? PHAsset
        //print("PHAsset", phAsset)
        let key = UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerMediaURL")
        videoUrl = info[key] as? NSURL
        print(videoUrl ?? "videoUrl is not found")
        print(videoUrl?.absoluteURL ?? "videoUrl.absoluteUrl is not found")
        thumbnailImageView.image = generateThumbnailFromVideo((videoUrl?.absoluteURL)!)
        thumbnailImageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)

    }

    private func generateThumbnailFromVideo(_ url: URL) -> UIImage? {
        print("generate a thumbnail from video")
        //以下の３行で縦動画から画像を取り出しても横向きの画像にならないようにしてる
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
}
// MARK: Play video
extension VideoUploaderViewController {
    private func playVideo() {
        if let videoUrl = videoUrl {
            //audio setting
            //thanks to: https://stackoverflow.com/questions/35289918/play-audio-when-device-in-silent-mode-ios-swift
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            }
            catch {
                print("cannot play the sound with video when silent mode")
            }
            guard let url = videoUrl.absoluteURL else { return }
            let player = AVPlayer(url: url)
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                print("playing video")
                self.playerViewController.player!.play()
            }
        }
    }
}

// MARK: Upload video
extension VideoUploaderViewController {
    private func uploadVideo() {

        print(playerViewController.player?.currentItem)

    }
}



