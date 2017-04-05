//
//  GarageTableViewCell.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-04-01.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

class GarageTableViewCell: UITableViewCell {

    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleDescription: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
