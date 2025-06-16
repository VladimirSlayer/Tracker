import UIKit

final class CategorySelectionViewController: UIViewController {
    
    weak var delegate: CategorySelectionDelegate?
    private var viewModel: CategorySelectionViewModel!
    private var selectedIndexPath: IndexPath?
    private var tableHeightConstraint: NSLayoutConstraint?

    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black[Day]")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background[Day]") ?? .systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false // ✅ отключаем скролл
        table.rowHeight = 75
        return table
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "starPlaceholder")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "Black[Day]") ?? .gray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        setupBindings()
        updateUI()
    }

    // MARK: - Setup
    
    private func setupViewModel() {
        let context = CoreDataStack.shared.context
        let store = TrackerCategoryStore(context: context)
        viewModel = CategorySelectionViewModel(store: store)
    }
    
    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        print("🪵 Categories count: \(viewModel.categories.count)") 
        let hasCategories = !viewModel.categories.isEmpty
        tableContainer.isHidden = !hasCategories
        imageView.isHidden = hasCategories
        messageLabel.isHidden = hasCategories

        if hasCategories {
            tableView.reloadData()

            let rowHeight: CGFloat = 75
            let totalHeight = CGFloat(viewModel.numberOfCategories()) * rowHeight
            tableHeightConstraint?.constant = totalHeight
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "White[Day]") ?? .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(titleLabel)
        view.addSubview(tableContainer)
        tableContainer.addSubview(tableView)
        tableHeightConstraint = tableContainer.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor),

            tableContainer.bottomAnchor.constraint(lessThanOrEqualTo: addButton.topAnchor, constant: -16),

            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 246),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }

    @objc private func addCategoryTapped() {
        let newCategoryVC = NewCategoryViewController(store: viewModel.categoryStore)
        present(newCategoryVC, animated: true)
    }
}

// MARK: - UITableView

extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseId, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }

        let category = viewModel.category(at: indexPath.row)
        let isSelected = indexPath == selectedIndexPath
        let isLast = indexPath.row == viewModel.numberOfCategories() - 1

        cell.configure(with: category.title, selected: isSelected, isLast: isLast)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.reloadData()
        let selected = viewModel.category(at: indexPath.row)
        delegate?.didSelectCategory(selected)
        dismiss(animated: true)
    }
}

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}
