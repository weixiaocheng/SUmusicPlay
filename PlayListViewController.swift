//
//  PlayListViewController.swift
//  SUMusic-swift
//
//  Created by user on 17/4/11.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit

class PlayListViewController: UIViewController {

    //确定当前选中的Cell 
    var currentIndex : Int = 0;
    // 播放界面
    let playVC  = PlayMusicContrloller()
    
    
    lazy var tableview : UITableView = {
        let tempTableview : UITableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tempTableview.delegate = self;
        tempTableview.dataSource = self;
      
        
        return tempTableview;
        
    }()
    let musicTools : MusicTools = MusicTools.shareMusictool;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "音乐列表";
        self.view.addSubview(self.tableview);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


extension PlayListViewController : UITableViewDelegate , UITableViewDataSource{
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.musicTools.all_musics?.count)!;
    }
    
    
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PlayListCell = PlayListCell.musicCellWithTableView(tableView: tableView);
//        cell.textLabel?.text = "我是利于: \(indexPath.row)"
        let music : MusicOBJ = self.musicTools.all_musics?[indexPath.row] as! MusicOBJ ;
        
        cell.setCellWithMusicOBJ(musicObj: music);
    
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let music_obj : MusicOBJ = self.musicTools.all_musics?[indexPath.row] as! MusicOBJ;
        if !music_obj.isPlay {
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.top)
            let current_music_obj : MusicOBJ = self.musicTools.all_musics?[self.currentIndex] as! MusicOBJ;
            current_music_obj.isPlay = false;
            self.currentIndex = indexPath.row;
            music_obj.isPlay = true;
        }
        
        //self.present(playVC, animated: true, completion: nil);
        self.present(playVC, animated: true) { 
           // self.playVC.musicTools.current_play_music = music_obj;
            // self.playVC.playSong(button: self.playVC.paly_btn);
            self.playVC.setMusicAndChangeSong(music_obj: music_obj)
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70;
    }
    
    
}
