//
//  myTVCell.swift
//  New Brighton Murals
//
//  Created by Zhijie Yan on 05/12/2022.
//

import UIKit

class myTVCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var artistLabel: UILabel!
    
    
    @IBOutlet weak var imageLabel: UIImageView!
    
    
    @IBOutlet weak var favouriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
