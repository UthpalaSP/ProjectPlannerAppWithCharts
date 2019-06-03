//
//  TaskViewCell.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/26/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//

import UIKit
import Charts

class TaskViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var progressPieChart: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
