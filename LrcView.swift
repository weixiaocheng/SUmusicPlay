//
//  LrcView.swift
//  miusicPlay- swift
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 loda. All rights reserved.
//

import UIKit

class LrcView: UIView ,UITableViewDelegate,UITableViewDataSource{

    //1.创建一个tableview 显示歌词
    private lazy var tableView : UITableView? = {
       let tempTableView = UITableView()
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.backgroundView = UIImageView.init(image: UIImage.init(named: "28131977_1383101943208"))
        tempTableView.separatorStyle = UITableViewCellSeparatorStyle.none

        return tempTableView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView?.frame = frame
        self.addSubview(self.tableView!)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //2.传入 歌词
    var lrcList : NSArray? = nil {

        didSet{
            self.tableView?.reloadData()
            self.tableView?.contentOffset = CGPoint(x: 0, y: -self.frame.height/2)
        }
        
    }
    
    //3.更新当前实现的时间 行数 
    var currentTimeLin : TimeInterval? = nil {
        
        didSet{
            
            if oldValue == nil {
                 self.currentIndex = 0
            }else if oldValue!/currentTimeLin! > 1 {
                
                self.currentIndex = 0
                
            }
  
         
            let currentTimerStr =  self.stringWithTime(time: currentTimeLin!)
            
            for index in self.currentIndex...(self.lrcList?.count)!-1{
                let  currentLine : PYLineOBJ? = self.lrcList?[index] as! PYLineOBJ?;
                
                var currentLineTime = currentLine?.time
                var  nextLineTime : String?  = nil
                
                if (index + 1 < (self.lrcList?.count)!) {
                    let lrcobj : PYLineOBJ? = self.lrcList?[index + 1] as! PYLineOBJ?
                    nextLineTime = lrcobj?.time;
                   
                }
                if nextLineTime == nil {
                    nextLineTime = "00:00";
                }
                
                if currentLineTime == nil {
                    currentLineTime = "0";
                }
              
                
                if (currentTimerStr.compare(currentLineTime!) != ComparisonResult.orderedAscending)&&(currentTimerStr.compare(nextLineTime!) == ComparisonResult.orderedAscending)&&(self.currentIndex != index)  {
                 
                    let reloadLines : Array = [NSIndexPath(row: self.currentIndex, section: 0),NSIndexPath(row: index, section: 0)]
                    
                    self.currentIndex = index;
                    
                    self.tableView?.reloadRows(at: reloadLines as [IndexPath], with: UITableViewRowAnimation.automatic);
                    
                    self.tableView?.scrollToRow(at: NSIndexPath(row: index, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: true);
                    
                }
                
                
                
            }
            
        
        }
    }
    ///当前显示的行 
    private var currentIndex = 0
    
    
    
    //MARK:-- tableViewDelegate
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if lrcList == nil {
            return 0;
        }
        return (lrcList?.count)!
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = LrcCell.lrcCellWithTableView(tableView: tableView) 
        
        let pyline = lrcList?[indexPath.row] as? PYLineOBJ
        
        cell.textLabel?.text = pyline?.words
        
        if self.currentIndex == indexPath.row {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        }else{
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        }
        
        
        return cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView?.contentInset = UIEdgeInsetsMake(self.frame.height/2, 0, self.frame.height/2, 0)
    }
    
    
    
    func stringWithTime(time: TimeInterval ) -> String {
        
        let date = NSDate(timeIntervalSince1970: time);
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "mm:ss"
        
        return dateFormatter.string(from: date as Date)
        
    }

}
