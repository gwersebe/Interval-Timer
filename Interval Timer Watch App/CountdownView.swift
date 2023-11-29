//
//  CountdownView.swift
//  Interval Timer Watch App
//
//  Created by Gabriel Wersebe on 11/25/23.
//


import SwiftUI
import WatchConnectivity
import WatchKit



class CountdownManager: NSObject, ObservableObject {
    static let shared = CountdownManager()

    @Published var remainingTime: TimeInterval = 0
    @Published var originalTime: TimeInterval = 0
    @Published var isRunning = false
    var session: WKExtendedRuntimeSession?
    var timer: Timer?

    private override init() {
        super.init()
        restoreTimerState()
    }

    func saveTimerState() {
        UserDefaults.standard.set(remainingTime, forKey: "RemainingTime")
        UserDefaults.standard.set(isRunning, forKey: "IsRunning")
    }

    func restoreTimerState() {
        if let savedRemainingTime = UserDefaults.standard.value(forKey: "RemainingTime") as? TimeInterval {
            remainingTime = savedRemainingTime
        }

        if let savedIsRunning = UserDefaults.standard.value(forKey: "IsRunning") as? Bool {
            isRunning = savedIsRunning
        }
    }
    
    
    func startTimer() {
        guard !isRunning else { return }

        timer?.invalidate()
        session?.invalidate()

        // Check if the session is nil before creating a new one
        if session == nil {
            session = WKExtendedRuntimeSession()
            session?.delegate = self
            session?.start(at: Date())
        }

        // Ensure that the timer is scheduled on the main run loop
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            if self.isRunning {
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.stopTimer()
                }

                if Int(self.remainingTime) % 60 == 0 {
                    WKInterfaceDevice.current().play(.notification)
                    print("Debug Vibrate")
                }

                print("Remaining Time: \(self.remainingTime)")
                print("Timer is running in the background")
            }
        })

        isRunning = true
    }


    func pauseTimer() {
        guard isRunning else { return }

        // Invalidate the timer and session
        timer?.invalidate()
        session?.invalidate()

        // Set both timer and session to nil after invalidating
        timer = nil
        session = nil

        isRunning = false
        saveTimerState()
    }




    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        session?.invalidate()
        isRunning = false
        remainingTime = 0
    }

    func resetTimer() {
        stopTimer()
        remainingTime = originalTime
    }
    
    deinit {
        // Ensure that the session is invalidated when CountdownManager is deallocated
        if isRunning {
            session?.invalidate()
        }
    }

}

extension CountdownManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Nothing needed here
    }

    func extendedRuntimeSessionDidInvalidate(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Complete any necessary cleanup when the session is invalidated
        stopTimer()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Handle session expiration if needed
        stopTimer()
    }
}

struct CountdownView: View {
    @StateObject private var countdownManager = CountdownManager.shared
    @Binding var totalTime: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("\(formattedTime(countdownManager.remainingTime))")
                .font(.system(size: 40))
                .padding()

            HStack {
                Button(action: {
                    countdownManager.resetTimer()
                }) {
                    Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }

                Button(action: {
                    countdownManager.toggleTimer()
                }) {
                    Image(systemName: countdownManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(countdownManager.isRunning ? .yellow : .green)
                }

                Button(action: {
                    countdownManager.resetTimer()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
        }
        .onDisappear {
            countdownManager.saveTimerState()
        }
        .onAppear {
            countdownManager.remainingTime = Double(totalTime * 60)
            countdownManager.originalTime = Double(totalTime * 60)
            countdownManager.startTimer()
        }
        .navigationBarBackButtonHidden(true)
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
