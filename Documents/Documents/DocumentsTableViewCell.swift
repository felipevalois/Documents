//
//  DocumentsTableViewCell.swift
//  Documents
//
//  Created by Felipe Costa on 6/18/19.
//  Copyright © 2019 Felipe Costa. All rights reserved.
//

import UIKit

class DocumentsTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var modified: UILabel!
    @IBOutlet weak var size: UILabel!
    
    let dateFormatter = DateFormatter()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(document: Document){
        self.title.text = document.name
        self.modified.text = dateFormatter.string(from: Date() as Date)//(from: document.modified!)
        if(document.modified != nil){
            print("doc modified \(document.modified)")
        }
        else{
            print("doc not modified")
        }
        self.size.text = String(document.size)
    }

}
