import UIKit

class NewTrackerViewController: UIViewController {
    
    weak var delegate: TrackerCreationDelegate?
    var trackerType: TrackerType = .habit
    private var selectedSchedule: [Weekday] = []
    var initialDate: Date = Date()
    
    private var scheduleTopConstraint: NSLayoutConstraint?
    private var scheduleBottomConstraint: NSLayoutConstraint?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "Black[Day]")
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Gray")]
        )
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = UIColor(named: "Background[Day]")
        textField.textColor = UIColor(named: "Black[Day]")
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(12)
        return textField
    }()
    
    private let settingsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        layoutUI()
        setupActions()
        updateCreateButtonState()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func openSchedule() {
        let vc = ScheduleViewController()
        vc.delegate = self
        vc.preselectedDays = selectedSchedule
        present(vc, animated: true)
    }
    
    func makeCellButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Background[Day]")
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(named: "Black[Day]")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = UIColor(named: "Gray")
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.tag = 99 
        subtitleLabel.isHidden = true
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.isUserInteractionEnabled = false
        
        textStack.addArrangedSubview(titleLabel)
        
        subtitleLabel.isHidden = true
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textStack.addArrangedSubview(subtitleLabel)
        
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(named: "Gray")
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.isUserInteractionEnabled = false
        
        let fullStack = UIStackView(arrangedSubviews: [textStack, chevron])
        fullStack.axis = .horizontal
        fullStack.alignment = .center
        fullStack.distribution = .fill
        fullStack.spacing = 8
        fullStack.translatesAutoresizingMaskIntoConstraints = false
        fullStack.isUserInteractionEnabled = false
        
        let top = fullStack.topAnchor.constraint(equalTo: button.topAnchor, constant: 12)
        let bottom = fullStack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -12)
        
        button.addSubview(fullStack)
        
        NSLayoutConstraint.activate([
            fullStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            fullStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            top,
            bottom
        ])
        
        if title == "Расписание" {
            scheduleTopConstraint = top
            scheduleBottomConstraint = bottom
        }
        
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
            separator.backgroundColor = UIColor(named: "Gray")
            settingsContainer.addSubview(scheduleButton)
            categoryButton.layer.cornerRadius = 16
            categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            scheduleButton.layer.cornerRadius = 16
            scheduleButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if (trackerType == .event)
        {
            categoryButton.layer.cornerRadius = 16
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
                categoryButton.bottomAnchor.constraint(equalTo: settingsContainer.bottomAnchor)
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
                scheduleButton.heightAnchor.constraint(equalToConstant: 75)
                
            ])}
    }
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
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
    
    private func updateCreateButtonState() {
        let nameIsEmpty = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        
        let scheduleIsValid = trackerType == .event || !selectedSchedule.isEmpty
        
        let shouldEnable = !nameIsEmpty && scheduleIsValid
        
        createButton.isEnabled = shouldEnable
        createButton.backgroundColor = shouldEnable ? .black : .systemGray3
    }
    
    private func updateCellSubtitle(for button: UIButton, with text: String?) {
        guard
            let fullStack = button.subviews
                .compactMap({ $0 as? UIStackView })
                .first(where: { $0.axis == .horizontal }),
            let textStack = fullStack.arrangedSubviews
                .compactMap({ $0 as? UIStackView })
                .first(where: { $0.axis == .vertical }),
            let subtitleLabel = textStack.arrangedSubviews
                .compactMap({ $0 as? UILabel })
                .first(where: { $0.tag == 99 })
        else {
            return
        }
        
        let hasSubtitle = !(text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        if hasSubtitle {
            subtitleLabel.text = text
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
            subtitleLabel.text = nil
        }

        button.setNeedsLayout()
        button.layoutIfNeeded()
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
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        let shortSymbols = formatter.shortWeekdaySymbols
        

        let sorted = schedule.sorted { $0.index < $1.index }
        guard let shortSymbols = formatter.shortWeekdaySymbols else { return }
        
        let shortDayNames = sorted.map { shortSymbols[$0.index].capitalized }
        

        let subtitle = shortDayNames.joined(separator: ", ")
        
        updateCellSubtitle(for: scheduleButton, with: subtitle)
        
        updateCreateButtonState()
    }
}

