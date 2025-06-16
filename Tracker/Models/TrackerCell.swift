import UIKit

class TrackerCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                 configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else {
                return UIMenu(title: "", children: [])
            }

            let isPinned = self.tracker?.isPinned ?? false
            let pinTitle = isPinned ? "Открепить" : "Закрепить"
            let pinImage = UIImage(systemName: isPinned ? "pin.slash" : "pin")

            let pinAction = UIAction(title: pinTitle, image: pinImage) { _ in
                self.delegate?.didRequestPinToggle(for: self)
            }

            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.delegate?.didRequestEdit(for: self)
            }

            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.showDeleteConfirmation()
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    private var tracker: Tracker?
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pinIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pin.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true // скрыта по умолчанию
        return imageView
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
        label.textColor = UIColor(named: "Black[Day]")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "Black[Day]")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        setupViews()
        setupContextMenuInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        plusButton.setTitle("+", for: .normal)
        plusButton.backgroundColor = nil
        plusButton.layer.opacity = 1.0
        emojiLabel.text = nil
        nameLabel.text = nil
        dayLabel.text = nil
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )

        let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didRequestDelete(for: self)
        }

        let cancel = UIAlertAction(title: "Отменить", style: .cancel)

        alert.addAction(delete)
        alert.addAction(cancel)

        // Чтобы не крашилось на iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self
            popover.sourceRect = self.bounds
        }

        self.parentViewController?.present(alert, animated: true)
    }
    
    private func setupContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        cardBackground.addInteraction(interaction)
    }

    private func setupViews() {
        contentView.addSubview(cardBackground)
        cardBackground.addSubview(emojiBackground)
        emojiBackground.addSubview(emojiLabel)
        cardBackground.addSubview(nameLabel)
        cardBackground.addSubview(pinIconView)
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
            
            pinIconView.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 18),
            pinIconView.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -12),
            pinIconView.widthAnchor.constraint(equalToConstant: 8),
            pinIconView.heightAnchor.constraint(equalToConstant: 12),
            
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            dayLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),

            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            plusButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool) {
        self.tracker = tracker
        contentView.backgroundColor = .clear
        plusButton.backgroundColor = tracker.color
        cardBackground.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        dayLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("days.count", comment: "Счетчик дней"),
            completedDays
        )
        let symbol = isCompletedToday ? "✓" : "+"
        plusButton.setTitle(symbol, for: .normal)
        plusButton.backgroundColor = tracker.color
        plusButton.layer.opacity = isCompletedToday ? 0.3 : 1
        pinIconView.isHidden = !tracker.isPinned
    }

    private func pluralizedDays(_ count: Int) -> String {
        switch count % 10 {
        case 1 where count % 100 != 11: return "день"
        case 2, 3, 4 where !(12...14).contains(count % 100): return "дня"
        default: return "дней"
        }
    }
}

protocol TrackerCellDelegate: AnyObject {
    func didRequestDelete(for cell: TrackerCell)
    func didRequestPinToggle(for cell: TrackerCell)
    func didRequestEdit(for cell: TrackerCell)
}

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }
}
