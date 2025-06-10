import UIKit

class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    var visibleCategories: [TrackerCategory] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "addTrackerButton"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor(named: "DatePicker_BG")
        return picker
    }()
    
    private let searchField: UISearchBar = {
        let searchBar = UISearchBar()
        let placeholderColor = UIColor(named: "SearchBar_Label") ?? .gray
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [.foregroundColor: placeholderColor]
        )
        if let iconView = searchBar.searchTextField.leftView as? UIImageView {
                iconView.tintColor = UIColor(named: "SearchBar_Label")
            }
        if let iconView = searchBar.searchTextField.rightView as? UIImageView {
                iconView.tintColor = UIColor(named: "SearchBar_Label")
            }
        searchBar.searchBarStyle = .default
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = UIColor(named: "SearchBar_BG")
        searchBar.searchTextField.textColor = .black
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.identifier
        )
        collectionView.register(
            UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell"
        )
        return collectionView
    }()
    
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "starPlaceholder")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        searchField.delegate = self
        reloadVisibleTrackers()
        setupActions()
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

    }
    
    @objc private func dismissKeyboard() {
        searchField.resignFirstResponder()
    }

    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadVisibleTrackers()
    }
    
    @objc private func didTapPlusButton(_ sender: UIButton) {
        let section = sender.tag / 1000
        let item = sender.tag % 1000
        
        let tracker = visibleCategories[section].trackers[item]
        
        guard currentDate <= Date() else { return }
        
        let isCompleted = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        if isCompleted {
            completedTrackers.removeAll {
                $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
            }
        } else {
            completedTrackers.append(TrackerRecord(id: UUID(), trackerId: tracker.id, date: currentDate))
        }
        
        collectionView.reloadData()
    }
    
    
    @objc private func addTrackerTapped() {
        let selectionVC = TrackerTypeSelectionViewController()
        selectionVC.delegate = self
        selectionVC.initialDate = self.currentDate
        selectionVC.modalPresentationStyle = .pageSheet
        present(selectionVC, animated: true)
    }
    
    private func reloadVisibleTrackers(searchText: String = "") {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)
        let weekdaySymbols = calendar.shortWeekdaySymbols.map { String($0.prefix(3)) }
        let weekdayString = weekdaySymbols[weekdayIndex - 1]
        
        guard let weekday = Weekday(rawValue: weekdayString) else { return }
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                
                switch tracker.type {
                case .habit:
                    return tracker.schedule.contains(weekday) && matchesSearch
                case .event:
                    let isAfterCreation = currentDate >= tracker.createdDate
                    let wasCompleted = completedTrackers.contains {
                        $0.trackerId == tracker.id
                    }
                    let isCompletedToday = completedTrackers.contains {
                        $0.trackerId == tracker.id &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }

                    return matchesSearch && (
                        (!wasCompleted && isAfterCreation) || isCompletedToday
                    )
                }
            }

            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        let isEmpty = visibleCategories.flatMap { $0.trackers }.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.reloadData()
    }
    
    
    
    func setupUI(){
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(datePicker)
        view.addSubview(searchField)
        view.addSubview(collectionView)
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 6),
            
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            
            searchField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            searchField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 92),
            
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 358),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.identifier,
            for: indexPath
        ) as! TrackerSectionHeaderView
        
        let category = visibleCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        let isCompletedToday = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        cell.configure(with: tracker, completedDays: completedDays, isCompletedToday: isCompletedToday)
        
        cell.plusButton.tag = indexPath.section * 1000 + indexPath.item
        cell.plusButton.addTarget(self, action: #selector(didTapPlusButton(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2 + 8
        let availableWidth = collectionView.bounds.width - padding
        let cellWidth = availableWidth / 2
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
}

extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        let newCategoryTitle = "Мои трекеры"
        
        if let index = categories.firstIndex(where: { $0.title == newCategoryTitle }) {
            categories[index].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(title: newCategoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        
        reloadVisibleTrackers()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadVisibleTrackers(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        reloadVisibleTrackers(searchText: "")
    }
}


