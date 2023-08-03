//
//  DetailViewController.swift
//  New Brighton Murals
//
//  Created by Zhijie Yan on 01/12/2022.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    var infomation = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    var name = ""
    
    @IBOutlet weak var picView: UIImageView!
    var imagesListArray = [image]()
    var UIImageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.text = "Details:\n"+infomation
        nameLabel.text = name
        for i in 1...imagesListArray.count{
            let name = imagesListArray[i-1].filename!
            let URLName = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_images/" + name
            if let url = URL(string: URLName) {
                let session = URLSession.shared
                session.dataTask(with: url) { (data, response, err) in
                    guard let imageData = data else { return }
                    
                    DispatchQueue.main.async {
                        self.UIImageArray.append(UIImage(data: imageData)!)
                        self.picView.animationImages = self.UIImageArray
                        self.picView.animationDuration = 3.0
                        self.picView.startAnimating()
                    }
                    }.resume()

            }
            
        }

        // Do any additional setup after loading the view.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
