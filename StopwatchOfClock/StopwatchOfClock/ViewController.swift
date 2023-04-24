//
//  ViewController.swift
//  StopwatchOfClock
//
//  Created by 최우태 on 2023/04/21.
//

import UIKit

final class ViewController: UIViewController {
    
    var totalTimer : BackgroundTimer?
    var lapTimer : BackgroundTimer?
    var lapTimes : [String?] = []
    var totalTime : Double = 0.00
    var lapTime : Double = 0.00
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var lapTimeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var laptimeRecordTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalTimeLabel.text = "00:00.00"
        lapTimeLabel.text = "00:00.00"
        // Do any additional setup after loading the view.
    }

    @IBAction func clickStartButton(_ sender: UIButton) {

        if startButton.titleLabel?.text == "Start" {
            startButton.setTitle("Stop", for: .normal)
            startButton.setTitleColor(.systemRed, for: .normal)
            recordButton.isEnabled = true
            recordButton.setTitle("Lap", for: .normal)
            
            // 각 라벨에 시간 기록 시작
            if totalTimer == nil {
                totalTimer = BackgroundTimer(with: 10,handler: {[weak self] in
                    guard let self = self else {return}
                    self.totalTime += 0.01
                    let minute = Int(self.totalTime) / 60
                    let second = self.totalTime - Double(minute) * 60
                    DispatchQueue.main.async {
                        self.totalTimeLabel.text = String(format:"%02d:%05.2f",minute,second)
                    }
                })
                lapTimer = BackgroundTimer(with: 10,handler: {[weak self] in
                    guard let self = self else {return}
                    self.lapTime += 0.01
                    let minute = Int(self.lapTime) / 60
                    let second = self.lapTime - Double(minute) * 60
                    DispatchQueue.main.async {
                        self.lapTimeLabel.text = String(format:"%02d:%05.2f",minute,second)
                    }
                })
                totalTimer?.activate()
                lapTimer?.activate()
            }else {
                totalTimer?.resume()
                lapTimer?.resume()
            }
        }else {
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(.systemGreen, for: .normal)
            recordButton.setTitle("Reset", for: .normal)
            // 시간 기록 정지
            totalTimer?.suspend()
            lapTimer?.suspend()
        }
    }
    
    @IBAction func clickRecordButton(_ sender: UIButton) {
        
        if recordButton.titleLabel?.text == "Lap" {
            //테이블 뷰에 랩타입 기록
            // 랩타임 기록 라벨 00:00.00으로 초기화
            lapTimer?.suspend()
            DispatchQueue.main.async {[self] in
                let minute = Int(lapTime) / 60
                let second = lapTime - Double(minute) * 60
                lapTimeLabel.text = String(format:"%02d:%05.2f",minute,second)
                lapTimes.append(lapTimeLabel.text)
                laptimeRecordTable.reloadData()
                lapTime = 0.00
                lapTimer?.resume()
            }
            
            
        }else {
            recordButton.isEnabled = false
            recordButton.setTitle("Lap", for: .disabled)
            // 랩타임, 전체시간 기록 라벨 00:00.00으로 초기화
                        
            DispatchQueue.main.async {[self] in
                totalTime = 0.00
                totalTimeLabel.text = "00:00.00"
                totalTimer = nil
            }
            DispatchQueue.main.async {[self] in
                lapTime = 0.00
                lapTimeLabel.text = "00:00.00"
                lapTimer = nil
                lapTimes.removeAll()
                laptimeRecordTable.reloadData()
            }
    
            // 테이블 셀 데이터 전부 제거
            
        }
        
    }
    
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let indexLabel = cell.viewWithTag(1) as? UILabel {
            indexLabel.text = "Lap \(lapTimes.count - indexPath.row)"
        }
        if let lapTimeLabel = cell.viewWithTag(2) as? UILabel {
            lapTimeLabel.text = lapTimes[lapTimes.count - indexPath.row - 1]
        }
        
        return cell
    }
}
