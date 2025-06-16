import UIKit

final class NewCategoryViewController: UIViewController {
    
    private let viewModel: NewCategoryViewModel
    
    init(store: TrackerCategoryStore) {
        self.viewModel = NewCategoryViewModel(store: store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        setupUI()
        bindViewModel()
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        titleLabel.text = "Новая категория"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "Black[Day]")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        textField.backgroundColor = UIColor(named: "Background[Day]") ?? UIColor.systemGray6
        textField.placeholder = "Введите название категории"
        textField.textColor = UIColor(named: "Black[Day]")
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(16)

        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .systemGray3
        doneButton.layer.cornerRadius = 16
        doneButton.isEnabled = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }


    private func bindViewModel() {
        viewModel.onButtonStateChanged = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
            self?.doneButton.backgroundColor = isEnabled ? .black : .systemGray3
        }
        
        viewModel.onSaveSuccess = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        viewModel.onDuplicateDetected = { [weak self] in
            let alert = UIAlertController(title: "Ошибка", message: "Такая категория уже существует", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    @objc private func textDidChange() {
        viewModel.categoryTitle = textField.text ?? ""
    }

    @objc private func doneTapped() {
        viewModel.saveCategory()
    }
}

