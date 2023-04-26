import UIKit

final class ViewController: UIViewController {
    
    var totalTimer : BackgroundTimer?
    var lapTimer : BackgroundTimer?
    
    var lapTimeList : [String?] = [] // 랩타임 저장 및 테이블뷰의 참조 데이터
    
    var totalTime : Double = 0.00
    var lapTime : Double = 0.00
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var lapTimeLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var lapResetButton: UIButton!
    
    @IBOutlet weak var laptimeRecordTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitializedOnce()
    }
    
    func InitializedOnce() {
        totalTimeLabel.text = "00:00.00"
        lapTimeLabel.text = "00:00.00"
        lapResetButton.isEnabled = false
    }
    
    func setTimeLabel(_ time : Double, _ targetLabel : UILabel) {
        let minute = Int(time) / 60
        let second = time - Double(minute) * 60
        DispatchQueue.main.async {
            targetLabel.text = String(format:"%02d:%05.2f",minute,second)
        }
    }
    
    // MARK: - 타이머를 설정 후 최초 실행시킵니다.
    func setTimer() {
        totalTimer = BackgroundTimer(with: 10,handler: {[weak self] in
            guard let self = self else {return}
            self.totalTime += 0.01
            self.setTimeLabel(self.totalTime, self.totalTimeLabel)
        })
        lapTimer = BackgroundTimer(with: 10,handler: {[weak self] in
            guard let self = self else {return}
            self.lapTime += 0.01
            self.setTimeLabel(self.lapTime, self.lapTimeLabel)
        })
        totalTimer?.activate()
        lapTimer?.activate()
    }
    
    // MARK: - 타이머를 생성 후 실행 또는 일시정지 상태에서 재개시킵니다.
    func resumeTimer() {
        lapResetButton.isEnabled = true
        playPauseButton.setTitle("Stop", for: .normal)
        playPauseButton.setTitleColor(.systemRed, for: .normal)
        lapResetButton.setTitle("Lap", for: .normal)
        
        if totalTimer == nil {
            setTimer()
            return
        }
        totalTimer?.resume()
        lapTimer?.resume()
    }
    
    // MARK: - 실행중인 타이머를 일시정지 시킵니다.
    func suspendTimer() {
        playPauseButton.setTitle("Start", for: .normal)
        playPauseButton.setTitleColor(.systemGreen, for: .normal)
        lapResetButton.setTitle("Reset", for: .normal)
        totalTimer?.suspend()
        lapTimer?.suspend()
    }
    
    // MARK: - 현재 랩 타임을 기록합니다.
    func recordLapTime() {
        DispatchQueue.main.async {[self] in
            lapTimeList.append(lapTimeLabel.text)
            laptimeRecordTableView.reloadData()
            lapTime = 0.00
        }
    }
    
    // MARK: - 스케줄된 타이머를 소멸시키고 연관 UI를 변경합니다.
    func resetTimer() {
        lapResetButton.isEnabled = false
        lapResetButton.setTitle("Lap", for: .disabled)
        
        totalTime = 0.00
        totalTimeLabel.text = "00:00.00"
        totalTimer = nil
        
        lapTime = 0.00
        lapTimeLabel.text = "00:00.00"
        lapTimer = nil
        lapTimeList.removeAll()
        DispatchQueue.main.async {
            self.laptimeRecordTableView.reloadData()
        }
    }
    
    
    @IBAction func clickPlayPauseButton(_ sender: UIButton) {
        
        // MARK: - Start상태의 버튼을 눌렀을 때의 로직
        if playPauseButton.titleLabel?.text == "Start" {
            resumeTimer()
            
        // MARK: - Stop 상태의 버튼을 눌렀을 때의 로직
        }else {
            suspendTimer()
        }
    }
    
    @IBAction func clickLapResetButton(_ sender: UIButton) {
        
        // MARK: - Lap상태의 버튼을 눌렀을때의 로직
        if lapResetButton.titleLabel?.text == "Lap" {
            recordLapTime()
            
        // MARK: - Reset상태의 버튼을 눌렀을 때의 로직
        }else {
            resetTimer()
        }
        
    }
    
    
}

// MARK: - 랩 타임 기록 테이블 관련 설정
extension ViewController : UITableViewDataSource {
    
    // MARK: - 현재 저장된 랩타임 개수만큼 테이블에 표시합니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimeList.count
    }
    
    // MARK: - cell의 재사용 및 값을 설정합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        // MARK: - 스토리보드에서 설정해 둔 UITableViewCell 내부 UIView의 태그 번호로 구분 및 UI를 설정해줍니다
        if let indexLabel = cell.viewWithTag(1) as? UILabel {
            indexLabel.text = "Lap \(lapTimeList.count - indexPath.row)"
        }
        if let lapTimeLabel = cell.viewWithTag(2) as? UILabel {
            lapTimeLabel.text = lapTimeList[lapTimeList.count - indexPath.row - 1]
        }
        
        return cell
    }
}
