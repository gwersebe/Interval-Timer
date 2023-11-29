//
//  ContentView.swift
//  Interval Timer Watch App
//
//  Created by Gabriel Wersebe on 11/25/23.
//

import SwiftUI


struct ContentView: View {
    @State private var selectedMinutes: Int = 1

    var body: some View {
        NavigationView {
            VStack {
                Picker("Minutes", selection: $selectedMinutes) {
                    ForEach(0 ..< 60) { index in
                        Text("\((index + 1)) min")
                            .tag(index + 1)
                    }
                }
                .labelsHidden()
                .frame(width: 100)
                .padding()
                
                NavigationLink(destination: CountdownView(totalTime: $selectedMinutes)) {
                    Text("Start")
                        .padding()
                }
                .disabled(selectedMinutes <= 0)
                .opacity(selectedMinutes <= 0 ? 0.5 : 1)
                .onTapGesture {
                    if selectedMinutes <= 0 {
                        print("Please select a valid time greater than 0.")
                    }
                }
            }
            .padding()
            .navigationBarTitle("Interval Timer")
            .navigationBarTitleDisplayMode(.large)

            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

