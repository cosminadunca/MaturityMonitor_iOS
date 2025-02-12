import UIKit
import Charts
import DGCharts
import SwiftUI

class BarChartViewController: UIViewController {
    
    var barChartView: BarChartView!
    var people: [BarChartDataEntry] = []
    //var iconImageView = UIImageView(image: UIImage(systemName: "arrow.up"))
    var iconHeights: [CGFloat] = [160, 80, 190]
    var iconNames = ["figure.stand.dress", "figure.stand", "figure.stand"]
    var iconColors: [UIColor] = [.buttonPurpleLight, .buttonTurquoiseDark, .buttonTurquoiseDark]
    var predictedAdultHeightTwoDigits: [Double] = [193.0]
    var percentageAH = ["93.6%"]
    
    init(iconHeights: [CGFloat]) {
        self.iconHeights = iconHeights
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView = BarChartView()
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(barChartView)
        
        // 1. Disable user interactions on the chart (double tapping)
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlightPerTapEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.dragEnabled = false
        
        barChartView.leftAxis.inverted = false
        
        // 2. Create a Y-axis label and customize its appearance
        let yAxisLabel = UILabel()
        yAxisLabel.text = "centimeters"
        yAxisLabel.font = .systemFont(ofSize: 14, weight: .bold)
        yAxisLabel.textColor = .black
        yAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(yAxisLabel)
        
        // 3. Position the Y-axis label above the chart, aligned with the Y-axis
        NSLayoutConstraint.activate([
            yAxisLabel.centerXAnchor.constraint(equalTo: barChartView.leftAnchor, constant: 50),
            yAxisLabel.bottomAnchor.constraint(equalTo: barChartView.topAnchor, constant: 1)
        ])
        
        // 4. Set constraints for barChartView to center it in the view and set its size
        NSLayoutConstraint.activate([
            barChartView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            barChartView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            barChartView.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20), // Optional width constraint
            barChartView.heightAnchor.constraint(equalToConstant: CGFloat(440.0))
        ])
        
        // 5. Set the maximum Y-axis value for the chart and the number of bars to display
        let maxY: CGFloat = 220.0
        let numberOfBars = 3
        
        // 6. Configure the left Y-axis (visible Y-axis)
        self.barChartView.leftAxis.axisMinimum = 0
        self.barChartView.leftAxis.axisMaximum = maxY
        self.barChartView.leftAxis.setLabelCount(12, force: false)
        
        let limitLine = ChartLimitLine(limit: predictedAdultHeightTwoDigits[0], label: "Predicted adult height: \(predictedAdultHeightTwoDigits[0]) cm")
        limitLine.lineColor = .red
        limitLine.lineWidth = 1.5
        limitLine.lineDashLengths = [4, 6]
        limitLine.labelPosition = .leftTop
        limitLine.valueFont = .systemFont(ofSize: 12, weight: .bold)
        
        // 7. Other graph settings
        self.barChartView.xAxis.drawGridLinesEnabled = false
        self.barChartView.rightAxis.enabled = false
        self.barChartView.legend.enabled = false
        self.barChartView.xAxis.drawLabelsEnabled = true
        self.barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.labelFont = .systemFont(ofSize: 13)
        barChartView.leftAxis.labelTextColor = .black
        
        // 9. Configure the X-axis labels and position
        let labels = ["Mother", "Child: PAH = \(percentageAH[0])", "Father"]
        self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        self.barChartView.xAxis.labelPosition = .bottom
        self.barChartView.xAxis.granularity = 1
        self.barChartView.xAxis.granularityEnabled = true

        // 10. Customize font and appearance of the X-axis labels
        self.barChartView.xAxis.labelFont = .systemFont(ofSize: 14)
        self.barChartView.xAxis.labelTextColor = .black  // Ensure text color is also defined
        
        DispatchQueue.main.async {
            let barChartWidth: CGFloat = self.barChartView.frame.width
            let barChartHeight: CGFloat = self.barChartView.frame.height
            let chartWidth: CGFloat = barChartWidth
            let chartHeight: CGFloat = barChartHeight
            let barWidth: CGFloat = chartWidth / CGFloat(numberOfBars)
            let iconWidth: CGFloat = barWidth - 5
            
            print("Chart width: \(chartWidth)")
            print("Chart height: \(chartHeight)")
            print("Bar width: \(barWidth)")
            
            var people: [BarChartDataEntry] = []
            
            // Calculate the offset to center the label
            let labelWidth: CGFloat = ("Child Adult Height \(self.predictedAdultHeightTwoDigits) cm" as NSString).size(withAttributes: [NSAttributedString.Key.font: limitLine.valueFont]).width
            let xOffset = (chartWidth / 2) - (labelWidth / 2) - 20

            // Apply the xOffset and yOffset
            limitLine.xOffset = xOffset  // This moves the label left or right
            limitLine.yOffset = 10       // You can adjust this to move the label up/down
            self.barChartView.leftAxis.addLimitLine(limitLine)
            
            for i in 0..<numberOfBars {
//                if i == 1 {
//                    let scaleIconHeight: CGFloat = CGFloat(self.predictedAdultHeightTwoDigits) - self.iconHeights[1]
//                    let scaleIconWidth: CGFloat = 25
//                    let xOffset: CGFloat = CGFloat(self.predictedAdultHeightTwoDigits)
//                    let yOffset: CGFloat = self.iconHeights[i]
//                    
//                    // Correct UIImage creation using the index 'i' instead of 'self.iconImageView'
//                    if let iconBarImage = self.iconImageView.image {
//                        let iconImageView = UIImageView(image: iconBarImage)
//                        iconImageView.frame = CGRect(x: 0, y: 0, width: scaleIconWidth, height: scaleIconHeight)
//                        iconImageView.frame.origin = CGPoint(x: xOffset, y: yOffset)
//                        
//                        // Set the icon color
//                        iconImageView.tintColor = UIColor.red
//                        
//                        // Add the icon as a subview to the chart view
//                        self.barChartView.addSubview(iconImageView)
//                    }
//                }

                var person = BarChartDataEntry(x: Double(i), y: Double(self.iconHeights[i]))
                people.append(person)
            }
                
            let dataSet = BarChartDataSet(entries: people)
            dataSet.setColor(.buttonGreyLight)
            dataSet.valueFont = .systemFont(ofSize: 13)
            
            var data = BarChartData(dataSet: dataSet)
            self.barChartView.data = data
                
            guard self.barChartView.data?.dataSets.first is BarChartDataSet else {
                print("No dataset found")
                return
            }
                
            for (index, person) in people.enumerated() {
                // Ensure there are enough icons for each bar
                if index < self.iconNames.count, let iconImage = UIImage(systemName: self.iconNames[index]) {
                    
                    // Icon height and width
                    let iconHeight: CGFloat = self.iconHeights[index] * 2
                    
                    // Get the transformer for Y-axis values
                    let transformer = self.barChartView.getTransformer(forAxis: .left)
                    
                    // Get the Y position for the bar's base (bottom of the bar)
                    let pixelPosition = transformer.pixelForValues(x: person.x, y: 0)
                    
                    // Calculate the Y position to place the icon just above the bottom of the bar
                    // `pixelPosition.y` is at the bottom of the bar, so we subtract the icon height to place it just above the bar
                    var yOffset = pixelPosition.y - iconHeight // Default position for the icon above the bar

                    if self.iconHeights[index] < 90 {
                        yOffset = pixelPosition.y - iconHeight + 6
                    } else if self.iconHeights[index] >= 90 && self.iconHeights[index] < 180 {
                        yOffset = pixelPosition.y - iconHeight + 12
                    } else {
                        yOffset = pixelPosition.y - iconHeight + 16
                    }
                    
                    // Create the icon image view
                    let iconImageView = UIImageView(image: iconImage)
                    iconImageView.frame = CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight)
                    
                    // Get the X position for the icon
                    let xPosition = transformer.pixelForValues(x: person.x, y: 0).x
                    let xOffset: CGFloat = xPosition - (iconWidth / 2)  // Center the icon in the bar
                    
                    // Set the final position for the icon
                    iconImageView.frame.origin = CGPoint(x: xOffset, y: yOffset)
                    
                    // Set the icon color
                    iconImageView.tintColor = self.iconColors[index]
                    
                    // Add the icon as a subview to the chart view
                    self.barChartView.addSubview(iconImageView)
                }
            }
        }
    }
}
    
    
struct BarChartViewControllerPreview_Previews: PreviewProvider {
    static var previews: some View {
        BarChartViewControllerPreview(
            iconHeights: [150, 68, 180],
            iconNames: ["figure.stand.dress", "figure.stand", "figure.stand"], // Ensure this array is defined
            iconColors: [.buttonPurpleLight, .buttonTurquoiseDark, .buttonTurquoiseDark], // Ensure this array is defined
            predictedAdultHeightTwoDigits: [183.0],
            percentageAH: ["93.6%"] // Ensure this is a string or the appropriate type
        )
            .previewLayout(.fixed(width: 380, height: 440)) // You can adjust this layout as needed
    }
}
