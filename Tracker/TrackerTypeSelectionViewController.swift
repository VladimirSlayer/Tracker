import UIKit

class TrackerTypeSelectionViewController: UIViewController {
    
    weak var delegate: TrackerCreationDelegate?
    var initialDate: Date = Date() 
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "Black[Day]")
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [habitButton, eventButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutUI()
        setupActions()
    }
        
    private func openNewTracker(with type: TrackerType) {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.delegate = delegate
        newTrackerVC.trackerType = type
        newTrackerVC.initialDate = self.initialDate
        present(newTrackerVC, animated: true)
    }

    
    private func setupActions() {
        habitButton.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(eventTapped), for: .touchUpInside)
    }

    @objc private func habitTapped() {
        openNewTracker(with: .habit)
    }

    @objc private func eventTapped() {
        openNewTracker(with: .event)
    }
    
    private func layoutUI() {
        view.addSubview(titleLabel)
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            // Заголовок сверху
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
