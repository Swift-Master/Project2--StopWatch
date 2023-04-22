//
//  ViewController.swift
//  StopwatchOfClock
//
//  Created by 최우태 on 2023/04/21.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var lapTimeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
//    @IBOutlet weak var laptimeRecordTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clickStartButton(_ sender: UIButton) {

        if startButton.titleLabel?.text == "Start" {
            startButton.setTitle("Stop", for: .normal)
            startButton.setTitleColor(.systemRed, for: .normal)
            recordButton.isEnabled = true
            recordButton.setTitle("Lap", for: .normal)
            
            // 각 라벨에 시간 기록 시작
        }else {
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(.systemGreen, for: .normal)
            recordButton.setTitle("Reset", for: .normal)
            
            // 시간 기록 정지
        }
    }
    
    @IBAction func clickRecordButton(_ sender: UIButton) {
        
        if recordButton.titleLabel?.text == "Lap" {
            //테이블 뷰에 랩타입 기록
            
            // 랩타임 기록 라벨 00:00.00으로 초기화
            
        }else {
            recordButton.isEnabled = false
            recordButton.setTitle("Lap", for: .disabled)
            // 랩타임, 전체시간 기록 라벨 00:00.00으로 초기화
            
            // 테이블 셀 데이터 전부 제거
        }
        
    }
    
    
}

