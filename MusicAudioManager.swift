//
//  MusicAudioManager.swift
//  SUMusic-swift
//
//  Created by user on 17/4/13.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit
import AVFoundation
class MusicAudioManager: NSObject {

    private let musicPlayers = NSMutableDictionary()

    override init(){
        super.init()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            
            try session.setActive(true)
        } catch {
            print(error)
            return
        }
 
    }
    
    ///音乐播放单例
    static let shareInstance : MusicAudioManager = {
        let tools = MusicAudioManager()
        
        
        return tools;
    }()
    
    //暂停播放 
    func pauseMusic(file_name : String?)  {
        if file_name == nil || file_name?.characters.count == 0 {
            return;
        }
        
        let player = musicPlayers[file_name!] as! AVAudioPlayer;
        player.pause();
        
        
    }
    //播放音乐
    func playMusic(file_name : String? ,delegate : PlayMusicContrloller) ->AVAudioPlayer? {
        if file_name == nil || file_name?.characters.count == 0 {
            return nil;
        }
        
        var player : AVAudioPlayer?  = musicPlayers[file_name!] as? AVAudioPlayer;
        
        if player == nil {
            let string = Bundle.main.path(forResource: file_name, ofType: nil);
            
            let url = NSURL.fileURL(withPath: string!)
            
            do {
                player = try AVAudioPlayer.init(contentsOf: url)
            } catch _ {
                
            }
         
            if (player?.prepareToPlay() == nil) {
                return nil
            }
            
            player?.delegate = delegate;
            
            musicPlayers[file_name!] = player;
            
        }
        
        if player?.isPlaying == false {
            player?.play()
        }
        
        return player
        
    }
    
    
    //停止播放 
    func stopMusicPlay(file_name : String?)  {
       
        if file_name == nil || file_name?.characters.count == 0 {
            return;
        }
        
        let player : AVAudioPlayer?  = musicPlayers[file_name!] as? AVAudioPlayer
        if player == nil {
            return;
        }
        
        player?.stop()
        
        musicPlayers.removeObject(forKey: file_name!)
        
    }
    
    
    
}
