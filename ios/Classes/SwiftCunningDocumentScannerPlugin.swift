import Flutter
import UIKit
import Vision
import VisionKit
import Photos

@available(iOS 13.0, *)
public class SwiftCunningDocumentScannerPlugin: NSObject, FlutterPlugin, VNDocumentCameraViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   var resultChannel :FlutterResult?
   var presentingController: VNDocumentCameraViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cunning_document_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftCunningDocumentScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPictures" {
            let presentedVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            self.resultChannel = result
            self.presentingController = VNDocumentCameraViewController()
            self.presentingController!.delegate = self
            presentedVC?.present(self.presentingController!, animated: true)
    } else if call.method == "getPictureFromGallery" {
        self.resultChannel = result
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // Choose the photo library as the source
        let presentedVC = UIApplication.shared.keyWindow?.rootViewController
        presentedVC?.present(imagePicker, animated: true)
    } else {
        result(FlutterMethodNotImplemented)
        return
    }
}


    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let tempDirPath = self.getDocumentsDirectory()
        let currentDateTime = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let formattedDate = df.string(from: currentDateTime)
        var filenames: [String] = []
        for i in 0 ... scan.pageCount - 1 {
            let page = scan.imageOfPage(at: i)
            let url = tempDirPath.appendingPathComponent(formattedDate + "-\(i).png")
            try? page.pngData()?.write(to: url)
            filenames.append(url.path)
        }
        resultChannel?(filenames)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        resultChannel?(nil)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        resultChannel?(nil)
        presentingController?.dismiss(animated: true)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            self.resultChannel?(nil)
            picker.dismiss(animated: true)
            return
        }
        
        // Optionally, convert the UIImage to a format suitable for your Flutter app
        let tempDirPath = getDocumentsDirectory()
        let currentDateTime = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let formattedDate = df.string(from: currentDateTime)
        let url = tempDirPath.appendingPathComponent(formattedDate + ".png")
        if let imageData = image.pngData() {
            try? imageData.write(to: url)
            self.resultChannel?([url.path])
        } else {
            self.resultChannel?(nil)
        }
        
        picker.dismiss(animated: true)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.resultChannel?(nil)
        picker.dismiss(animated: true)
    }
}
