import UIKit

class NewTrackerViewController: UIViewController {
    
    weak var delegate: TrackerCreationDelegate?
    var trackerType: TrackerType = .habit
    private var selectedSchedule: [Weekday] = []
    var initialDate: Date = Date()
    var selectedCategory: TrackerCategory?
    
    private var scheduleTopConstraint: NSLayoutConstraint?
    private var scheduleBottomConstraint: NSLayoutConstraint?
    
    var trackerToEdit: Tracker?
    var completedDays: Int = 0 // для отображения "5 дней"
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private var selectedEmojiIndex: IndexPath?
    private var selectedEmoji: String?
    
    private let availableColors: [UIColor] = [
        UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1),
        UIColor(red: 255/255, green: 136/255, blue: 30/255, alpha: 1),
        UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1),
        UIColor(red: 110/255, green: 68/255, blue: 254/255, alpha: 1),
        UIColor(red: 51/255, green: 207/255, blue: 105/255, alpha: 1),
        UIColor(red: 230/255, green: 109/255, blue: 212/255, alpha: 1),
        UIColor(red: 249/255, green: 212/255, blue: 212/255, alpha: 1),
        UIColor(red: 52/255, green: 167/255, blue: 254/255, alpha: 1),
        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1),
        UIColor(red: 53/255, green: 52/255, blue: 124/255, alpha: 1),
        UIColor(red: 255/255, green: 103/255, blue: 77/255, alpha: 1),
        UIColor(red: 255/255, green: 153/255, blue: 204/255, alpha: 1),
        UIColor(red: 246/255, green: 196/255, blue: 139/255, alpha: 1),
        UIColor(red: 121/255, green: 148/255, blue: 245/255, alpha: 1),
        UIColor(red: 131/255, green: 44/255, blue: 241/255, alpha: 1),
        UIColor(red: 173/255, green: 86/255, blue: 218/255, alpha: 1),
        UIColor(red: 141/255, green: 114/255, blue: 230/255, alpha: 1),
        UIColor(red: 47/255, green: 208/255, blue: 88/255, alpha: 1)
    ]
    private var selectedColorIndex: IndexPath?
    private var selectedColor: UIColor?
    
    private let doneDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "Black[Day]")
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        return collectionView
    }()
    
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        return collectionView
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "Black[Day]")
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
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
        view.backgroundColor = UIColor(named: "Background[Day]")
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
    
    private let buttonBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "White")
        return view
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        scheduleButton.addTarget(self, action: #selector(openSchedule), for: .touchUpInside)
        layoutUI()
        setupActions()
        updateCreateButtonState()
        if trackerToEdit != nil {
            configureEditingUI()
        }
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
        button.backgroundColor = .clear
        
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(titleLabel)
        
        if trackerToEdit != nil {
            contentView.addSubview(doneDaysLabel)
            NSLayoutConstraint.activate([
                doneDaysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                doneDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 34)
            ])
        }
        
        contentView.addSubview(nameTextField)
        contentView.addSubview(settingsContainer)
        settingsContainer.addSubview(categoryButton)
        
        if trackerType == .habit {
            settingsContainer.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor(named: "Gray")
            settingsContainer.addSubview(scheduleButton)
            categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            scheduleButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        
        view.addSubview(buttonBackgroundView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            buttonBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonBackgroundView.topAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            trackerToEdit == nil
                ? nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24)
            : nameTextField.topAnchor.constraint(equalTo: doneDaysLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            settingsContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            settingsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: settingsContainer.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: settingsContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: settingsContainer.trailingAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: settingsContainer.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.44),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
        
        if trackerType == .event {
            NSLayoutConstraint.activate([
                settingsContainer.heightAnchor.constraint(equalToConstant: 75),
                categoryButton.bottomAnchor.constraint(equalTo: settingsContainer.bottomAnchor)
            ])
        }
        
        if trackerType == .habit {
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
            ])
        }
    }
    
    private func configureEditingUI() {
        guard let tracker = trackerToEdit else { return }

        titleLabel.text = "Редактирование привычки"
        nameTextField.text = tracker.name
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        trackerType = tracker.type
        selectedSchedule = tracker.schedule
        createButton.setTitle("Сохранить", for: .normal)
        if let selectedCategory = selectedCategory {
            updateCellSubtitle(for: categoryButton, with: selectedCategory.title)
        }

        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
            selectedEmoji = tracker.emoji
            emojiCollectionView.selectItem(at: selectedEmojiIndex, animated: false, scrollPosition: [])
        }

        if let colorIndex = availableColors.firstIndex(of: tracker.color) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 0)
            selectedColor = tracker.color
            colorCollectionView.selectItem(at: selectedColorIndex, animated: false, scrollPosition: [])
        }

        // Выставляем расписание
        if trackerType == .habit {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            let shortSymbols = formatter.shortWeekdaySymbols
            let sorted = selectedSchedule.sorted { $0.index < $1.index }
            guard let shortSymbols = formatter.shortWeekdaySymbols else { return }
            let shortDayNames = sorted.map { shortSymbols[$0.index].capitalized }
            updateCellSubtitle(for: scheduleButton, with: shortDayNames.joined(separator: ", "))
        }

        // Заголовок с количеством дней
        doneDaysLabel.text = "\(completedDays) \(pluralizedDays(completedDays))"
        doneDaysLabel.isHidden = false

        NSLayoutConstraint.activate([
            doneDaysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            doneDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38)
        ])

        // Сдвигаем nameTextField вниз (если ты не используешь уже констрейнт)
        nameTextField.topAnchor.constraint(equalTo: doneDaysLabel.bottomAnchor, constant: 24).isActive = true

        updateCreateButtonState()
    }
    private func pluralizedDays(_ count: Int) -> String {
        switch count % 10 {
        case 1 where count % 100 != 11: return "день"
        case 2, 3, 4 where !(12...14).contains(count % 100): return "дня"
        default: return "дней"
        }
    }
    
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(openCategorySelection), for: .touchUpInside)

    }
    
    @objc private func openCategorySelection() {
        let categoryVC = CategorySelectionViewController()
        categoryVC.delegate = self
        categoryVC.initiallySelectedCategory = selectedCategory
        present(categoryVC, animated: true)
    }

    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func createTracker() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let category = selectedCategory else {
            return
        }

        let tracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: trackerType == .habit ? selectedSchedule : [],
            type: trackerType,
            createdDate: trackerToEdit?.createdDate ?? (trackerType == .event ? initialDate : Date()),
            isPinned: trackerToEdit?.isPinned ?? false
        )

        if let _ = trackerToEdit {
            delegate?.didEditTracker(tracker, newCategory: category)
        } else {
            delegate?.didCreateTracker(tracker, categoryTitle: category.title)
        }

        dismiss(animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let nameIsEmpty = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        
        let scheduleIsValid = trackerType == .event || !selectedSchedule.isEmpty
        
        let emojiIsSelected = selectedEmoji != nil
        let colorIsSelected = selectedColor != nil
        
        let shouldEnable = !nameIsEmpty && scheduleIsValid && emojiIsSelected && colorIsSelected
        
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

extension NewTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return availableColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: availableColors[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let selected = selectedEmojiIndex, selected != indexPath {
                collectionView.deselectItem(at: selected, animated: true)
            }
            selectedEmojiIndex = indexPath
            selectedEmoji = emojis[indexPath.item]
        } else {
            if let selected = selectedColorIndex, selected != indexPath {
                collectionView.deselectItem(at: selected, animated: true)
            }
            selectedColorIndex = indexPath
            selectedColor = availableColors[indexPath.item]
        }
        updateCreateButtonState()
    }
}

extension NewTrackerViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        updateCellSubtitle(for: categoryButton, with: category.title)
        updateCreateButtonState()
    }
}



