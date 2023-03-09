//
//  ContentView.swift
//  FitMate
//
//  Created by eversense on 2023/03/09.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject var heartRateStore = HeartRateStore()
    @State var samples: [HKQuantitySample] = []
    @State var date = Date()
    @State var showDatePicker = false

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(.leading)
                        .onTapGesture {
                            // do something
                        }

                    Text("Heart Rate")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()

                    Spacer()

                    Button(action: {
                        showDatePicker = true
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .sheet(isPresented: $showDatePicker) {
                        DatePicker("Select Date", selection: $date, in: ...Date(), displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onChange(of: date) { _ in
                                heartRateStore.fetchHeartRateSamples(for: date) { samples in
                                    self.samples = samples ?? []
                                }
                            }
                    }
                }
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )

                Spacer()

                if samples.isEmpty {
                    ProgressView("Loading...")
                        .foregroundColor(.gray)
                } else {
                    HeartRateChartView(samples: samples, date: date)
                        .frame(maxHeight: 300)
                }

                Spacer()
            }
        }
        .onAppear {
            heartRateStore.authorizeHealthKit()
            heartRateStore.fetchHeartRateSamples(for: date) { samples in
                self.samples = samples ?? []
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
