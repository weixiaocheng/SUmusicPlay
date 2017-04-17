//
//  PlayListCell.swift
//  SUMusic-swift
//
//  Created by user on 17/4/11.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit

class PlayListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    class  func musicCellWithTableView(tableView : UITableView) -> PlayListCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "idCell");
        
        if cell == nil
        {
            cell = PlayListCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "idCell");
            cell?.selectionStyle = UITableViewCellSelectionStyle.none;
        }
        
        
        return cell as! PlayListCell ;
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellWithMusicOBJ(musicObj : MusicOBJ)  {
        self.imageView?.image = UIImage(named: musicObj.singerIcon!);
        self.textLabel?.text = musicObj.name;
        self.detailTextLabel?.text = musicObj.singer;
        
    }
    
    
}
