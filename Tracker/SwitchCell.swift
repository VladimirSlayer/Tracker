import UIKit

final class SwitchCell: UITableViewCell {

    let dayLabel = UILabel()
    let daySwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 0))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.textColor = UIColor(named: "Black[Day]")
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
        selectionStyle = .none
        backgroundColor = UIColor(named: "Background[Day]")
        daySwitch.onTintColor = UIColor(named: "SwitchTintColor")
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 75)

        ])
    }
}
