import UIKit

class NewTrackerViewController: UIViewController {
    
    weak var delegate: TrackerCreationDelegate?
    var trackerType: TrackerType = .habit
    private var selectedSchedule: [Weekday] = []
    var initialDate: Date = Date()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(12)
        return textField
    }()
    
    private let settingsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryButton = makeCellButton(title: "Категория")
    private lazy var scheduleButton = makeCellButton(title: "Расписание")
    private let separator = UIView()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutUI()
        setupActions()
    }
    
    @objc private func openSchedule() {
        let vc = ScheduleViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func makeCellButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray2
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: button.topAnchor, constant: 25),
            stack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -25)
        ])

        return button
    }
    
    private func layoutUI() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(settingsContainer)
        settingsContainer.addSubview(categoryButton)
        if (trackerType == .habit)
        {
            settingsContainer.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = .systemGray4
            settingsContainer.addSubview(scheduleButton)
        }
        scheduleButton.addTarget(self, action: #selector(openSchedule), for: .touchUpInside)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            
            settingsContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            settingsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: settingsContainer.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: settingsContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: settingsContainer.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            cancelButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.44),
            
            createButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
        if (trackerType == .event){
            NSLayoutConstraint.activate([
                settingsContainer.heightAnchor.constraint(equalToConstant: 75),
            ])}
        if (trackerType == .habit){
            NSLayoutConstraint.activate([
                settingsContainer.heightAnchor.constraint(equalToConstant: 150),
                
                separator.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
                separator.leadingAnchor.constraint(equalTo: settingsContainer.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: settingsContainer.trailingAnchor, constant: -16),
                separator.heightAnchor.constraint(equalToConstant: 0.5),
                
                scheduleButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
                scheduleButton.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor),
                scheduleButton.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor),
                scheduleButton.bottomAnchor.constraint(equalTo: settingsContainer.bottomAnchor),
                
            ])}
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
    }
    
    @objc private func createTracker() {
        let newTracker = Tracker(
            id: UUID(),
            name: nameTextField.text ?? "Без названия",
            color: .systemBlue,
            emoji: "💡",
            schedule: trackerType == .habit ? selectedSchedule : [],
            type: trackerType,
            createdDate: trackerType == .event ? initialDate : Date()
        )
        
        delegate?.didCreateTracker(newTracker)
        dismiss(animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

extension NewTrackerViewController: ScheduleSelectionDelegate {
    func didSelectSchedule(_ schedule: [Weekday]) {
        selectedSchedule = schedule
    }
}

