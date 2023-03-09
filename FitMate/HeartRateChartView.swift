//
//  HeartRateChartView.swift
//  FitMate
//
//  Created by eversense on 2023/03/09.
//

import SwiftUI
import Charts
import HealthKit


struct HeartRateChartView: UIViewRepresentable {
    let samples: [HKQuantitySample]
    let date: Date

    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .systemFont(ofSize: 12)
        chartView.xAxis.labelTextColor = .black
        chartView.leftAxis.labelPosition = .outsideChart
        chartView.leftAxis.labelFont = .systemFont(ofSize: 12)
        chartView.leftAxis.labelTextColor = .black
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = true
        chartView.legend.textColor = .black
        chartView.legend.form = .circle
        chartView.legend.formSize = 8
        chartView.legend.formLineWidth = 2
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        return chartView
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = generateLineChartData()
    }

    private func generateLineChartData() -> LineChartData {
        var entries: [ChartDataEntry] = []
        let now = date
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let samplesInPeriod = samples.filter { sample in
            let sampleStartOfDay = Calendar.current.startOfDay(for: sample.startDate)
            return sampleStartOfDay >= startOfDay && sampleStartOfDay < endOfDay
        }

        for i in 0..<samplesInPeriod.count {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let heartRate = samplesInPeriod[i].quantity.doubleValue(for: heartRateUnit)
            let time = samplesInPeriod[i].startDate.timeIntervalSince(startOfDay)
            entries.append(ChartDataEntry(x: time / 60, y: heartRate))
        }

        let dataSet = LineChartDataSet(entries: entries)
        dataSet.colors = [.blue]
        dataSet.circleColors = [.blue]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.label = "Heart Rate"

        let data = LineChartData(dataSet: dataSet)
        return data
    }
}
struct HeartRateChartView_Previews: PreviewProvider {
    static var previews: some View {
        let samples = [
            HKQuantitySample(
                type: HKObjectType.quantityType(forIdentifier: .heartRate)!,
                quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: 60),
                start: Date(),
                end: Date()
            )
        ]
        return HeartRateChartView(samples: samples, date: Date())
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
