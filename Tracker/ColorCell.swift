import UIKit

class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"

    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let borderLayer = CAShapeLayer()

    override var isSelected: Bool {
        didSet {
            borderLayer.isHidden = !isSelected
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        let borderFrame = CGRect(x: (52 - 46)/2, y: (52 - 46)/2, width: 46, height: 46)
        let path = UIBezierPath(roundedRect: borderFrame, cornerRadius: 8)

        borderLayer.path = path.cgPath
        borderLayer.lineWidth = 3
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.isHidden = true

        contentView.layer.addSublayer(borderLayer)
    }

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        borderLayer.strokeColor = color.withAlphaComponent(0.3).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
