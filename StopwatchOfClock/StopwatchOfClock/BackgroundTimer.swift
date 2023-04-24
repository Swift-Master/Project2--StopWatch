import Foundation

class BackgroundTimer {
    private enum State {
        case suspended
        case resumed
    }
    private var state: State = .suspended
    private var timerLock = NSLock()
    private var interval: Int
    private var eventHandler: (() -> Void)?

    init(with interval: Int, handler: (() -> Void)? = nil) {
        self.interval = interval
        self.eventHandler = handler
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.init(label: "thanks.codesquad.timer"))
        t.schedule(deadline: .now(), repeating: .milliseconds(self.interval))
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    func reschedule(interval: Int, handler: (() -> Void)? = nil) {
        self.interval = interval
        timer.schedule(deadline: DispatchTime.now(), repeating: .milliseconds(interval))
        eventHandler = handler
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
    }

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
