//
//  TripTableViewCell.swift
//  ONtheRoad
//
//  Created by Michael Dickenson on 2017-04-04.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var tripname: UILabel!
    @IBOutlet weak var tripTest1: UILabel!
    @IBOutlet weak var tripTest2: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
