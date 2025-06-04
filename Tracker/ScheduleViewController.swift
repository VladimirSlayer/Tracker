import UIKit

class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleSelectionDelegate?
    
    var preselectedDays: [Weekday] = []

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black[Day]")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let doneButton = UIButton(type: .system)
    
    private let days = [
        "Понедельник", "Вторник", "Среда",
        "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    private var selectedDays = Set<Int>()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .white
        selectedDays = Set(preselectedDays.compactMap { Weekday.allCases.firstIndex(of: $0) })
        setupTableView()
        setupDoneButton()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(headerLabel)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor(named: "Gray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }
    
    @objc private func didTapDone() {
        let selectedWeekdays = selectedDays.map { Weekday.allCases[$0] }
        delegate?.didSelectSchedule(selectedWeekdays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchCell else {
            return UITableViewCell()
        }
        
        let day = days[indexPath.row]
        cell.dayLabel.text = day
        cell.daySwitch.isOn = selectedDays.contains(indexPath.row)
        cell.daySwitch.tag = indexPath.row
        cell.daySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.superview?.superview?.backgroundColor = .white
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            selectedDays.insert(sender.tag)
        } else {
            selectedDays.remove(sender.tag)
        }
    }
}

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ schedule: [Weekday])
}

