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
    @IBOutlet weak var noTripLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Setting up some working vars for tracking stuff
    var kilometers: [String]!
    var time: [String]!
    var efficiency1: [String]!
    var efficiency2: [String]!
    var counter = 0.0
    var trips: TripData?
    var trips2 = TripData()
    
    override func viewWillAppear(_ animated: Bool) {
        //filling working vars
        
        if trips == nil {
            scrollView.isHidden = true
        } else {
            scrollView.isHidden = false
            noTripLabel.isHidden = true
            
            time = ["0"]
            kilometers = ["0"]
            efficiency1 = ["0"]
            efficiency2 = ["0"]
            
            //Drawing all the charts
            setBackground()
            updatePieChartData()
            updateBarChartData()
            updateLineChartData()
        }
    }
    
    // MARK: Navigation
    
    @IBAction func unwindToAnalytics(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DetailedMapViewController, let trip = sourceViewController.sendTrip {

            //Grabbing the passed TripData entity
            trips = trip
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = backButton
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    // MARK: Functions
    
    //Piechart is all the different effRatios readings split into categories
    func updatePieChartData()  {
        
        var good = 0
        var avg = 0
        var poor = 0
        var bad = 0
        let track = ["Good", "Average", "Poor", "Bad"]

        //Tallying up all the readings into different categories. This guy is fuzzy, would need more tinkering to get better readings
        for trip in (trips?.tripLocationData)! {
            if trip.efficiencyRatio < (trips?.vehicleMaxAccel)!*0.25 {
                good += 1
            }
            else if trip.efficiencyRatio < (trips?.vehicleMaxAccel)!*0.5 {
                avg += 1
            }
            else if trip.efficiencyRatio < (trips?.vehicleMaxAccel)!*0.75 {
                poor += 1
            }
            else {
                bad += 1
            }
        }
        //Fills the piechart array with the values
        let money = [good, avg, poor, bad]
        
        //displaying the chart
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
        
        pieChartCiew.centerText = ""
        pieChartCiew.holeColor = UIColor.clear
        pieChartCiew.holeRadiusPercent = 0.7
        pieChartCiew.transparentCircleColor = UIColor.clear
        pieChartCiew.chartDescription?.text = ""
        pieChartCiew.drawEntryLabelsEnabled = false
    }
    
    //Bar chart for eff over time
    func updateBarChartData() {
    
        barChartView.noDataText = "You need to provide data for the chart."
        
        //Splitting it into 10 segments
        let segments = (trips?.tripLocationData.count)! / 10
        var tracker = 0
        
        //Counting through the 10 segments
        for i in 0...9 {
            
            var counter = 0.0
            var effTemp = 0.0

            //Counting through each segment step
            for location in tracker..<(segments+tracker) {
                //Tallying up all the effratio for a segment
                effTemp += (trips?.tripLocationData[location].efficiencyRatio)!
                counter += 1
            }
            
            //Grabbing the L/100km
            effTemp = ((effTemp / (counter+1)) * (trips?.vehicleActual)!)
            //Inserting the effTemp into the chart in spot i
            self.efficiency1?.append(String(effTemp))
            time.insert(String(effTemp), at: i)
            tracker += segments
        }
        
        //Filling the chart and dispalying values, the first spot is always blank, unsure why and don't have the time to fix it.
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in efficiency1.enumerated() {
            if (i > 0) {
                let dataEntry = BarChartDataEntry()
                dataEntry.x = Double(i)
                dataEntry.y = Double(j)!
                dataEntries.append(dataEntry)
            }
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
    
    //Line graph for charting eff over distance
    func updateLineChartData() {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        //Breaking the trip total distance into 10 segments
        let segments = (trips?.tripDistance)! / 10.0
        
        var distance = 0.0
        var effTemp = 0.0
        var counter2 = 0
            //Walks through all the trip locations
            for location in (trips?.tripLocationData)! {
                
                //Cuts the trip into segments by checking the distance travelled in a segment,
                //Once distance is >= the value of segments we are going to cut it into a info point on the chart and reset our working vars
                if (distance >= segments) {
                    //Grabbing the avg for the segment
                    effTemp = ((effTemp / (counter+1)) * (trips?.vehicleActual)!)
                    //Adding the point to the chart
                    self.efficiency2?.append(String(effTemp))
                    kilometers.insert(String(effTemp), at: counter2)
                    //reseting to continue counting
                    effTemp = 0
                    distance = 0
                    counter = 0
                    counter2 += 1
                }
                //Adding the effTemp and distance to a working var
                effTemp += (location.efficiencyRatio)
                distance += (location.distance)
                counter += 1
                
            }
        //adding the last segment, this guy might not be a full segment so it could be slightly skewed
        effTemp = ((effTemp / (counter+1)) * (trips?.vehicleActual)!)
        //Adding the point to the chart
        self.efficiency2?.append(String(effTemp))
        kilometers.insert(String(effTemp), at: counter2)
        
        //Displaying the charts
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in efficiency2.enumerated() {
            if (i > 0) {
                let dataEntry = BarChartDataEntry()
                dataEntry.x = Double(i)
                dataEntry.y = Double(j)!
                dataEntries.append(dataEntry)
            }
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
