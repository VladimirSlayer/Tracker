import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}


class FilterViewController: UIViewController {
    weak var delegate: FilterSelectionDelegate?
    var selectedFilter: TrackerFilter = .all

    private let filters: [(TrackerFilter, String)] = [
        (.all, "Все трекеры"),
        (.today, "Трекеры на сегодня"),
        (.completed, "Завершённые"),
        (.uncompleted, "Не завершённые")
    ]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(named: "Black[Day]")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let filterContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = UIColor(named: "Background[Day]") ?? UIColor.systemGray6
        stack.layer.cornerRadius = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(filterContainer)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filterContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filterContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        for (index, item) in filters.enumerated() {
            let button = createFilterButton(title: item.1, filter: item.0)
            filterContainer.addArrangedSubview(button)

            if index < filters.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor(named: "Gray")
                separator.translatesAutoresizingMaskIntoConstraints = false
                filterContainer.addArrangedSubview(separator)

                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 0.5),
                    separator.leadingAnchor.constraint(equalTo: filterContainer.leadingAnchor, constant: 16),
                    separator.trailingAnchor.constraint(equalTo: filterContainer.trailingAnchor, constant: -16)
                ])
            }
        }
    }

    private func createFilterButton(title: String, filter: TrackerFilter) -> UIButton {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(UIColor(named: "Black[Day]"), for: .normal)
        button.tag = filter.rawValue
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)

        if filter == selectedFilter {
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
            checkmark.tintColor = .blue
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(checkmark)

            NSLayoutConstraint.activate([
                checkmark.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                checkmark.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
            ])
        }

        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return button
    }

    @objc private func filterTapped(_ sender: UIButton) {
        guard let selected = TrackerFilter(rawValue: sender.tag) else { return }
        delegate?.didSelectFilter(selected)
        dismiss(animated: true)
    }
}
