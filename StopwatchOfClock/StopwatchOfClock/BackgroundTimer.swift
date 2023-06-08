import Foundation

// MARK: - DispatchSourceTimer를 구현한 클래스
final class BackgroundTimer {
    
    // MARK: - 상태 관리를 위해 열거형을 정의
    private enum State {
        case suspended
        case resumed
    }
    private var state: State = .suspended
    private var timerLock = NSLock() // 동시성 문제를 해결하기 위해 도입
    private var interval: Int
    private var eventHandler: (() -> Void)?
    
    // MARK: - Memberwise 생성자를 통해 생성과 동시에 handler를 설정할 수 있습니다.
    init(with interval: Int, handler: (() -> Void)? = nil) {
        self.interval = interval
        self.eventHandler = handler
    }
    
    // MARK: - main이 아닌 custom 디스패치 대기열을 생성합니다.(기본: concurrent)
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.init(label: "thanks.codesquad.timer"))
        t.schedule(deadline: .now(), repeating: .milliseconds(self.interval))
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    // MARK: - 추가 인스턴스를 생성하지 않고 기존 타이머 객체를 재활용합니다.
    func reschedule(interval: Int, handler: (() -> Void)? = nil) {
        self.interval = interval
        timer.schedule(deadline: DispatchTime.now(), repeating: .milliseconds(interval))
        eventHandler = handler
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
    }
    
    // MARK: - 타이머에 설정된 핸들러를 제거한 후 타이머를 종료시킵니다.
    deinit {
        timer.setEventHandler(handler: nil)
        timer.cancel()
        resume()
        eventHandler = nil
    }
    
    func activate() {
        timerLock.lock()
        timer.activate()
        state = .resumed
        timerLock.unlock()
    }

    func resume() {
        timerLock.lock()
        if state == .resumed {
            timerLock.unlock()
            return
        }
        state = .resumed
        timer.resume()
        timerLock.unlock()
    }

    func suspend() {
        timerLock.lock()
        if state == .suspended {
            timerLock.unlock()
            return
        }
        state = .suspended
        timer.suspend()
        timerLock.unlock()
    }
}
