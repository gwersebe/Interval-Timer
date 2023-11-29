//
//  CountdownTimer.swift
//  Interval Timer Watch App
//
//  Created by Gabriel Wersebe on 11/25/23.
//

import SwiftUI

struct CountdownView: View {
    @State private var timer: Timer?
    @State private var remainingTime: TimeInterval = 300
    @State private var isRunning = false

    var body: some View {
        VStack {
            Text("\(formattedTime(remainingTime))")
                .font(.system(size: 40))
                .padding()

            HStack {
                Button(action: {
                    startTimer()
                }) {
                    Text("Start")
                }
                .padding()

                Button(action: {
                    stopTimer()
                }) {
                    Text("Stop")
                }
                .padding()

                Button(action: {
                    resetTimer()
                }) {
                    Text("Reset")
                }
                .padding()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    func startTimer() {
        if !isRunning {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    stopTimer()
                }
            }
            isRunning = true
        }
    }

    func stopTimer() {
        timer?.invalidate()
        isRunning = false
    }

    func resetTimer() {
        stopTimer()
        remainingTime = 300
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView()
    }
}
