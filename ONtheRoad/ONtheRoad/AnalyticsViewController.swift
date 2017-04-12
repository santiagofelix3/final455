//
//  AnalyticsViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-04-05.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import Charts

class AnalyticsViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var pieChartCiew: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var kilometers: [String]!
    var time: [String]!
    var efficiency1: [String]!
    var efficiency2: [String]!
    var counter = 0.0
    var trips: TripData?
    
    override func viewWillAppear(_ animated: Bool) {
//        super.viewDidLoad()
        time = ["0"]
        kilometers = ["0"]

        efficiency1 = ["0"]
        efficiency2 = ["0"]
        
        setBackground()
        updatePieChartData()
        updateBarChartData()
        updateLineChartData()

        //setChart(dataPoints: kilometers, values: efficiency)
    }
    
    // MARK: Navigation
    
    @IBAction func unwindToAnalytics(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DetailedMapViewController, let trip = sourceViewController.sendTrip {
            print("***********************************************************************************HOLAHOLAHOLAHOLAADIOS")
            print(trip)
            //trips = trip
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = backButton
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    // MARK: Functions
    
    func updatePieChartData()  {
        
        //let chart = PieChartView(frame: self.view.frame)
        var low = 0
        var good = 0
        var avg = 0
        var bad = 0
        let track = ["Low", "Good", "Average", "Bad"]
 //       let money = [10, 20, 22, 12]
    
        for trip in (trips?.tripLocationData)! {
            if trip.efficiencyRatio < (trips?.vehicleMaxAccel)!*0.25 {
                low += 1
            }
            else if trip.efficiencyRatio < (trips?.vehicleMaxAccel)!*0.5 {
                good += 1
            }
            else if trip.efficiencyRatio < (trips?.vehicleMaxAccel)!*0.75 {
                avg += 1
            }
            else {
                bad += 1
            }
        }

        let money = [low, good, avg, bad]
        
        
        var entries = [PieChartDataEntry]()
        for (index, value) in money.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = track[index]
            entries.append(entry)
        }
        
        let set = PieChartDataSet( values: entries, label: "")
        
        var colors: [UIColor] = []
        
        for i in 0..<money.count {
            if i == 0 {
                let red = Double(176)
                let green = Double(229)
                let blue = Double(251)
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            } else if i == 1 {
                let red = Double(30)
                let green = Double(159)
                let blue = Double(62)
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            } else if i == 2 {
                let red = Double(224)
                let green = Double(127)
                let blue = Double(21)
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            } else {
                let red = Double(219)
                let green = Double(51)
                let blue = Double(55)
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            }
        }
        
        set.colors = colors
        pieChartCiew.backgroundColor = .clear

        let data = PieChartData(dataSet: set)
        pieChartCiew.data = data
        pieChartCiew.noDataText = "No data available"
        // user interaction
        pieChartCiew.isUserInteractionEnabled = false
        
        //let description = Description()
        //description.text = "iOSCharts.io"
        //pieChartCiew.chartDescription = description
        pieChartCiew.centerText = "Total Trip Time"
        pieChartCiew.holeRadiusPercent = 0.7
        pieChartCiew.transparentCircleColor = UIColor.clear
        //self.view.addSubview(pieChartCiew)
        
    }
    
    
    func updateBarChartData() {
    
        barChartView.noDataText = "You need to provide data for the chart."
        
        let segments = (trips?.tripLocationData.count)! / 10
        var tracker = 0
        
        for i in 0...9 {
            
            var counter = 0.0
            var effTemp = 0.0

            for location in tracker..<(segments+tracker) {
                effTemp += (trips?.tripLocationData[location].efficiencyRatio)!
                counter += 1
            }
            
            effTemp = ((effTemp / (counter+1)) * (trips?.vehicleActual)!)
            self.efficiency1?.append(String(effTemp))
            time.insert(String(effTemp), at: i)
            tracker += segments
        }
        
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in efficiency1.enumerated() {
            let dataEntry = BarChartDataEntry()
            dataEntry.x = Double(i)
            dataEntry.y = Double(j)!
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Efficiency")
        let chartData = BarChartData(dataSet: chartDataSet)
        let targetLine = ChartLimitLine(limit: (trips?.vehicleActual)!, label: "Ideal")
        
        targetLine.lineWidth = 1
        targetLine.valueTextColor = UIColor.white
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        barChartView.data = chartData
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelTextColor = Palette.InfoText
        barChartView.xAxis.drawLabelsEnabled = false
        barChartView.leftAxis.labelTextColor = Palette.InfoText
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.leftAxis.addLimitLine(targetLine)
        barChartView.leftAxis.axisMaximum = (trips?.vehicleActual)!*2.5
        barChartView.rightAxis.axisMinimum = 0.0
        barChartView.rightAxis.axisMaximum = 30.0
        barChartView.leftAxis.axisMinimum = 0.0
        
        barChartView.backgroundColor = UIColor.clear
        barChartView.leftAxis.drawLabelsEnabled = true
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.leftAxis.axisLineColor = UIColor.clear
        barChartView.rightAxis.axisLineColor = UIColor.clear
        barChartView.xAxis.axisLineColor = UIColor.clear
        barChartView.legend.enabled = false
        
        chartDataSet.valueTextColor = .clear
        chartDataSet.setColor(.white, alpha: 0.8)
        chartDataSet.highlightEnabled = false
    }
    
    func setBackground() {
        let topColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 5/255.0, green: 54/255.0, blue: 106/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateLineChartData() {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        let segments = (trips?.tripDistance)! / 10.0
        
        var distance = 0.0
        var effTemp = 0.0
        var counter2 = 0
            for location in (trips?.tripLocationData)! {
                
                if (distance >= segments) {
                    effTemp = ((effTemp / (counter+1)) * (trips?.vehicleActual)!)
                    self.efficiency2?.append(String(effTemp))
                    kilometers.insert(String(effTemp), at: counter2)
                    effTemp = 0
                    distance = 0
                    counter = 0
                    counter2 += 1
                }
                
                effTemp += (location.efficiencyRatio)
                distance += (location.distance)
                counter += 1
                
            }
        
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in efficiency2.enumerated() {
            let dataEntry = BarChartDataEntry()
            dataEntry.x = Double(i)
            dataEntry.y = Double(j)!
            
            dataEntries.append(dataEntry)
        }
        
        let targetLine = ChartLimitLine(limit: (trips?.vehicleActual)!, label: "Ideal")
        
        targetLine.lineWidth = 1
        targetLine.valueTextColor = UIColor.white
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Efficiency")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        lineChartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        lineChartView.data = lineChartData
        lineChartView.chartDescription?.text = ""
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = Palette.InfoText
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.labelTextColor = Palette.InfoText
        //lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        
        lineChartView.leftAxis.addLimitLine(targetLine)
        lineChartView.leftAxis.axisMaximum = (trips?.vehicleActual)!*2.5
        lineChartView.rightAxis.axisMinimum = 0.0
        lineChartView.rightAxis.axisMaximum = 30.0
        lineChartView.leftAxis.axisMinimum = 0.0
        
        lineChartView.backgroundColor = UIColor.clear
        lineChartView.leftAxis.drawLabelsEnabled = true
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.axisLineColor = UIColor.clear
        lineChartView.rightAxis.axisLineColor = UIColor.clear
        lineChartView.xAxis.axisLineColor = UIColor.clear
        lineChartView.legend.enabled = false
        
        lineChartDataSet.setCircleColor(UIColor.clear)
        lineChartDataSet.drawCircleHoleEnabled = true
        lineChartDataSet.circleHoleColor = Palette.InfoText
        lineChartDataSet.circleHoleRadius = 3.0
        lineChartDataSet.valueTextColor = .clear
        lineChartDataSet.setColor(UIColor.white.withAlphaComponent(0.5))
        lineChartDataSet.lineWidth = 2
        
        
        let gradientColors = [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        lineChartDataSet.drawFilledEnabled = true
    }
}
