//
//  UIImageView+loadImageUsingURL.swift
//  Karaokieee
//
//  Created by Mu Yu on 4/25/22.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImageUsingUrlString(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }).resume()
    }
    
}
