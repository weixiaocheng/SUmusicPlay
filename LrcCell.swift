//
//  LrcCell.swift
//  miusicPlay- swift
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 loda. All rights reserved.
//

import UIKit

class LrcCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   class func lrcCellWithTableView(tableView : UITableView) -> LrcCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "lrcCell")
        if cell == nil {
            cell = LrcCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "lrcCell")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell?.textLabel?.textAlignment = NSTextAlignment.center
            cell?.backgroundColor = UIColor.clear
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
        }
        return cell as! LrcCell
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
