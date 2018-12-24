//
//  ViewController.swift
//  DownloadImageBigSize
//
//  Created by van.tien.tu on 12/21/18.
//  Copyright © 2018 van.tien.tu.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate var downloadTask: URLSessionDownloadTask?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var processingView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73992/world.200403.3x21600x10800.png") {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
            let task = session.downloadTask(with: url)
            task.resume()
        }
    }
    
    fileprivate func showProcessing(_ process: Double) {
        self.processingView.progress = Float(process)
    }
    
    fileprivate func downsample(imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPiexels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                 kCGImageSourceShouldCacheImmediately: true,
                                 kCGImageSourceCreateThumbnailWithTransform: true,
                                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPiexels] as? CFDictionary
        let downsampleImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampleImage)
    }
}

extension ViewController: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    // URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.showProcessing(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        self.showProcessing(Double(fileOffset) / Double(expectedTotalBytes) * 100)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print(location)
        self.imageView.image = self.downsample(imageURL: location, to: self.imageView.bounds.size, scale: 1)
        print("")
    }
    
    // URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("error related",error)
        }
    }
}

