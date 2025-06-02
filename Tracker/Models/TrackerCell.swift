import UIKit

class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(cardBackground)
        cardBackground.addSubview(emojiBackground)
        emojiBackground.addSubview(emojiLabel)
        cardBackground.addSubview(nameLabel)
        contentView.addSubview(dayLabel)
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            cardBackground.widthAnchor.constraint(equalToConstant: 167),
            cardBackground.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackground.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            nameLabel.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -12),
            nameLabel.topAnchor.constraint(equalTo: emojiBackground.bottomAnchor, constant: -12),
            
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            dayLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),

            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            plusButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool) {
        contentView.backgroundColor = .clear
        plusButton.backgroundColor = tracker.color
        cardBackground.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        dayLabel.text = "\(completedDays) \(pluralizedDays(completedDays))"
        let symbol = isCompletedToday ? "✓" : "+"
        plusButton.setTitle(symbol, for: .normal)
        plusButton.backgroundColor = isCompletedToday ? .gray : tracker.color
    }

    private func pluralizedDays(_ count: Int) -> String {
        switch count % 10 {
        case 1 where count % 100 != 11: return "день"
        case 2, 3, 4 where !(12...14).contains(count % 100): return "дня"
        default: return "дней"
        }
    }
}
