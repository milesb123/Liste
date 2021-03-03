//
//  ImageNetworkManager.swift
//  Liste
//
//  Created by Miles Broomfield on 03/03/2021.
//

import Foundation
import UIKit

class ImageHandler{
    var CLIENT_ID = "8c76da9c32bcbe0"
    
    func uploadImageToImgur(image: UIImage,completionHandler:@escaping(String?,Error?)->()){
        
        let resized = image.resizeWithWidth(width: 600)
        
        getBase64Image(image: resized != nil ? resized! : image) { base64Image in
            
            
            let boundary = "Boundary-\(UUID().uuidString)"

                        var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!)
                        request.addValue("Client-ID \(self.CLIENT_ID)", forHTTPHeaderField: "Authorization")
                        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                        request.httpMethod = "POST"

                        var body = ""
                        body += "--\(boundary)\r\n"
                        body += "Content-Disposition:form-data; name=\"image\""
                        body += "\r\n\r\n\(base64Image ?? "")\r\n"
                        body += "--\(boundary)--\r\n"
                        let postData = body.data(using: .utf8)

                        request.httpBody = postData
            
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("failed with error: \(error)")
                    completionHandler(nil,error)
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                    print("server error")
                    completionHandler(nil,ImgurError.serverError)
                    return
                }
                if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {

                    let parsedResult: [String: AnyObject]
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                        if let dataJson = parsedResult["data"] as? [String: Any] {
                            completionHandler(dataJson["link"] as? String ?? "Link not found",error)

                        }
                    } catch {
                        completionHandler(nil,ImgurError.error)
                    }
                }
                else{
                    completionHandler(nil,ImgurError.error)
                }
            }.resume()
        }
    }
    
    private func getBase64Image(image: UIImage, complete: @escaping (String?) -> ()) {
            DispatchQueue.main.async {
                let imageData = image.pngData()
                let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
                complete(base64Image)
            }
    }
    
    enum ImgurError:Error{
        case serverError
        case error
    }
    
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
