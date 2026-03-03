import UIKit

class StatisticsViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = UIColor(named: "Black[Day]") ?? .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sadEmoji") ?? UIImage(systemName: "face.smiling")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "Black[Day]") ?? .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let coreData = CoreDataStack.shared
        let recordStore = TrackerRecordStore(context: coreData.context)
        let trackerStore = TrackerStore(context: coreData.context)

        let stats = StatisticsProvider(recordStore: recordStore, trackerStore: trackerStore).calculateStatistics()

        if stats.completedCount == 0 {
            showEmptyState()
        } else {
            showStatistics(stats)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStatistics()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "White")
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func showEmptyState() {
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func showStatistics(_ stats: TrackerStatistics) {
        view.addSubview(statsStackView)
        NSLayoutConstraint.activate([
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let values: [(Int, String)] = [
            (stats.bestPeriod, "Лучший период"),
            (stats.perfectDays, "Идеальные дни"),
            (stats.completedCount, "Трекеров завершено"),
            (stats.averagePerDay, "Среднее значение")
        ]

        values.forEach { value, title in
            let statView = StatCardView(value: value, title: title)
            statsStackView.addArrangedSubview(statView)
        }
    }
    
    private func refreshStatistics() {
        
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyImageView.removeFromSuperview()
        emptyLabel.removeFromSuperview()

        let coreData = CoreDataStack.shared
        let recordStore = TrackerRecordStore(context: coreData.context)
        let trackerStore = TrackerStore(context: coreData.context)

        let stats = StatisticsProvider(recordStore: recordStore, trackerStore: trackerStore).calculateStatistics()

        if stats.completedCount == 0 {
            showEmptyState()
        } else {
            showStatistics(stats)
        }
    }

}
