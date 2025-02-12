import UIKit
import Charts
import DGCharts
import SwiftUI

class BarChartViewController1: UIViewController {
    var barChartView: BarChartView!
    var people: [BarChartDataEntry] = []
    var iconHeights: [CGFloat] = [340, 320, 410] // Heights for 3 icons

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

        // Set constraints for barChartView
        NSLayoutConstraint.activate([
            barChartView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            barChartView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            barChartView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            barChartView.heightAnchor.constraint(equalToConstant: 440)
        ])

        // Dummy data for the bar chart
        let numberOfBars = 3
        var people = [BarChartDataEntry]()
        for i in 0..<numberOfBars {
            let person = BarChartDataEntry(x: Double(i), y: Double(220)) // Y value is fixed for all 3 people
            people.append(person)
        }

        self.people = people

        // Create a dataset and set it to the chart
        let dataSet = BarChartDataSet(entries: people)
        dataSet.colors = [NSUIColor.clear] // Clear bars to overlay icons on top
        dataSet.highlightEnabled = false

        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data

        // Configure chart appearance
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 220
        barChartView.leftAxis.setLabelCount(12, force: false)

        let labels = ["Mother", "Child", "Father"]
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelFont = .systemFont(ofSize: 16)

        // Hide right Y-axis
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false

        // Overlay icons on top of the bars
        overlayIcons()
    }

    // Function to overlay icons on top of bars
    func overlayIcons() {
        let iconNames = ["figure.stand.dress", "figure.stand", "figure.stand"]
        let iconColors: [UIColor] = [.buttonPurpleLight, .buttonTurquoiseDark, .buttonTurquoiseDark]

        let barWidth: CGFloat = barChartView.frame.width / CGFloat(3) // Width for each bar
        let iconWidth: CGFloat = barWidth - 10 // Icon width slightly smaller than bar width

        // Remove any existing icons
        for subview in barChartView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }

        // Get the chart's transformer for correct positioning
        let transformer = barChartView.getTransformer(forAxis: .left)

        // Loop through each entry and overlay the corresponding icon on top
        for (index, person) in people.enumerated() {
            if index < iconNames.count, let iconImage = UIImage(systemName: iconNames[index]) {
                let iconHeight: CGFloat = iconHeights[index]

                let yOffset: CGFloat = 0

                // Create an image view for the icon
                let iconImageView = UIImageView(image: iconImage)
                iconImageView.frame = CGRect(x: 0, y: 0, width: iconWidth, height: iconHeight)

                // Get the X position for the icon
                let xPosition = transformer.pixelForValues(x: person.x, y: 0).x
                let xOffset: CGFloat = xPosition - (iconWidth / 2)

                iconImageView.frame.origin = CGPoint(x: xOffset, y: yOffset)
                iconImageView.tintColor = iconColors[index]

                // Add the icon to the chart
                barChartView.addSubview(iconImageView)
            }
        }
    }
}

// SwiftUI Preview
struct BarChartViewController1_Previews: PreviewProvider {
    static var previews: some View {
        BarChartViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all) // Optional: to ignore safe areas in preview
    }
}

struct BarChartViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BarChartViewController1 {
        return BarChartViewController1(iconHeights: [340, 320, 410])
    }

    func updateUIViewController(_ uiViewController: BarChartViewController1, context: Context) {
        // Update your view controller here if needed
    }
}
