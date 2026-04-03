//
//  TaskListViewController.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

final class TaskListViewController: UIViewController {
    var presenter: TaskListPresenterProtocol?

    private var items: [TaskListCellViewModel] = [] {
        didSet {
            let count = items.count
            tasksCountLabel.text = "\(count) \(pluralizedTasks(count))"
        }
    }

    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let searchController = UISearchController(searchResultsController: nil)

    private let bottomBarView = UIView()
    private let tasksCountLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private var bottomBarHeightConstraint: NSLayoutConstraint?

    private let overlayView = UIView()
    private let blurView = UIVisualEffectView(effect: nil)
    private let dimView = UIView()

    private let focusedCardView = UIView()
    private let focusedTitleLabel = UILabel()
    private let focusedDescriptionLabel = UILabel()
    private let focusedDateLabel = UILabel()

    private let actionsContainerView = UIStackView()

    private var selectedTodoIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBarHeightConstraint?.constant = 50 + view.safeAreaInsets.bottom

        if let header = tableView.tableHeaderView {
            let width = view.bounds.width
            if header.frame.width != width {
                header.frame.size.width = width
                searchController.searchBar.frame = CGRect(x: 8, y: 0, width: width - 16, height: 56)
                tableView.tableHeaderView = header
            }
        }
    }
}

private extension TaskListViewController {
    func setupUI() {
        view.backgroundColor = AppColors.background
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupTitleLabel()
        setupTableView()
        setupBottomBar()
        setupSearch()
        setupOverlayUI()

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(bottomBarView)
        view.addSubview(overlayView)

        bottomBarHeightConstraint = bottomBarView.heightAnchor.constraint(equalToConstant: 50)
        bottomBarHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),

            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Задачи"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = AppColors.primaryText
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.placeholder = "Search"

        let textField = searchController.searchBar.searchTextField
        textField.backgroundColor = AppColors.searchBackground
        textField.textColor = AppColors.primaryText
        textField.tintColor = AppColors.primaryText
        textField.leftView?.tintColor = AppColors.tertiaryText
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: AppColors.tertiaryText]
        )

        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        headerContainer.backgroundColor = AppColors.background

        searchController.searchBar.frame = CGRect(x: 8, y: 0, width: view.bounds.width - 16, height: 56)
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.barTintColor = AppColors.background
        searchController.searchBar.backgroundColor = AppColors.background

        headerContainer.addSubview(searchController.searchBar)
        tableView.tableHeaderView = headerContainer
    }

    func setupBottomBar() {
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.backgroundColor = AppColors.bottomBarBackground

        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.font = .systemFont(ofSize: 13, weight: .medium)
        tasksCountLabel.textColor = AppColors.primaryText
        tasksCountLabel.textAlignment = .center
        tasksCountLabel.text = "0 Задач"

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = AppColors.accent
        activityIndicator.hidesWhenStopped = true

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.tintColor = AppColors.accent
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

        bottomBarView.addSubview(tasksCountLabel)
        bottomBarView.addSubview(activityIndicator)
        bottomBarView.addSubview(addButton)

        NSLayoutConstraint.activate([
            tasksCountLabel.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: bottomBarView.safeAreaLayoutGuide.topAnchor, constant: 25),

            activityIndicator.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: 16),
            activityIndicator.centerYAnchor.constraint(equalTo: tasksCountLabel.centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: tasksCountLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func setupOverlayUI() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .clear
        overlayView.alpha = 0
        overlayView.isHidden = true

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = true

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        focusedCardView.translatesAutoresizingMaskIntoConstraints = false
        focusedCardView.backgroundColor = AppColors.focusedCardBackground
        focusedCardView.layer.cornerRadius = 16
        focusedCardView.clipsToBounds = true
        focusedCardView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        focusedTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        focusedTitleLabel.textColor = AppColors.primaryText
        focusedTitleLabel.numberOfLines = 2

        focusedDescriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        focusedDescriptionLabel.textColor = AppColors.secondaryText
        focusedDescriptionLabel.numberOfLines = 3

        focusedDateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        focusedDateLabel.textColor = AppColors.tertiaryText

        let cardStack = UIStackView(arrangedSubviews: [focusedTitleLabel, focusedDescriptionLabel, focusedDateLabel])
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.axis = .vertical
        cardStack.spacing = 8

        actionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        actionsContainerView.axis = .vertical
        actionsContainerView.spacing = 1
        actionsContainerView.backgroundColor = AppColors.actionMenuBackground
        actionsContainerView.layer.cornerRadius = 16
        actionsContainerView.clipsToBounds = true

        overlayView.addSubview(blurView)
        overlayView.addSubview(dimView)
        overlayView.addSubview(focusedCardView)
        overlayView.addSubview(actionsContainerView)
        focusedCardView.addSubview(cardStack)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),

            dimView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),

            focusedCardView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            focusedCardView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: -78),
            focusedCardView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 24),
            focusedCardView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -24),

            cardStack.topAnchor.constraint(equalTo: focusedCardView.topAnchor, constant: 16),
            cardStack.leadingAnchor.constraint(equalTo: focusedCardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: focusedCardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: focusedCardView.bottomAnchor, constant: -16),

            actionsContainerView.topAnchor.constraint(equalTo: focusedCardView.bottomAnchor, constant: 16),
            actionsContainerView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 56),
            actionsContainerView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -56)
        ])

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(hideFocusedMenu))
        dimView.addGestureRecognizer(dismissTap)

        let blurTap = UITapGestureRecognizer(target: self, action: #selector(hideFocusedMenu))
        blurView.addGestureRecognizer(blurTap)
    }

    func makeActionRow(title: String, systemImage: String, tintColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = AppColors.actionMenuBackground

        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: systemImage)
        config.imagePlacement = .trailing
        config.imagePadding = 12
        config.baseForegroundColor = tintColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
        button.configuration = config

        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func showFocusedMenu(for index: Int) {
        guard items.indices.contains(index) else { return }

        selectedTodoIndex = index
        let item = items[index]

        focusedTitleLabel.text = item.title
        focusedDescriptionLabel.text = item.description
        focusedDateLabel.text = item.createdAtText

        actionsContainerView.arrangedSubviews.forEach {
            actionsContainerView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let editButton = makeActionRow(
            title: "Редактировать",
            systemImage: "square.and.pencil",
            tintColor: .black,
            action: #selector(didTapEditAction)
        )

        let shareButton = makeActionRow(
            title: "Поделиться",
            systemImage: "square.and.arrow.up",
            tintColor: .black,
            action: #selector(didTapShareAction)
        )

        let deleteButton = makeActionRow(
            title: "Удалить",
            systemImage: "trash",
            tintColor: .systemRed,
            action: #selector(didTapDeleteAction)
        )

        [editButton, shareButton, deleteButton].forEach { actionsContainerView.addArrangedSubview($0) }

        overlayView.isHidden = false
        overlayView.alpha = 0
        focusedCardView.transform = CGAffineTransform(translationX: 0, y: 30).scaledBy(x: 0.96, y: 0.96)
        actionsContainerView.transform = CGAffineTransform(translationX: 0, y: 20)
        blurView.effect = nil

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.overlayView.alpha = 1
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            self.focusedCardView.transform = .identity
            self.actionsContainerView.transform = .identity
        }
    }

    @objc func hideFocusedMenu() {
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.overlayView.alpha = 0
            self.blurView.effect = nil
            self.focusedCardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.actionsContainerView.transform = CGAffineTransform(translationX: 0, y: 12)
        } completion: { _ in
            self.overlayView.isHidden = true
            self.selectedTodoIndex = nil
        }
    }

    @objc func didTapEditAction() {
        guard let selectedTodoIndex else { return }
        hideFocusedMenu()
        presenter?.didSelectItem(at: selectedTodoIndex)
    }

    @objc func didTapShareAction() {
        guard let selectedTodoIndex else { return }
        let item = items[selectedTodoIndex]
        let text = [item.title, item.description].joined(separator: "\n")

        hideFocusedMenu()

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(activityVC, animated: true)
    }

    @objc func didTapDeleteAction() {
        guard let selectedTodoIndex else { return }
        hideFocusedMenu()
        presenter?.didDeleteItem(at: selectedTodoIndex)
    }

    @objc func didTapAdd() {
        presenter?.didTapAdd()
    }

    func pluralizedTasks(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder10 == 1 && remainder100 != 11 {
            return "Задача"
        } else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            return "Задачи"
        } else {
            return "Задач"
        }
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func showLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    func showTodos(_ items: [TaskListCellViewModel]) {
        self.items = items
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoCell.reuseIdentifier,
            for: indexPath
        ) as? TodoCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        showFocusedMenu(for: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        106
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.presenter?.didDeleteItem(at: indexPath.row)
            completion(true)
        }

        let toggleTitle = items[indexPath.row].isCompleted ? "Вернуть" : "Готово"
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.presenter?.didToggleStatus(at: indexPath.row)
            completion(true)
        }
        toggleAction.backgroundColor = .systemBlue

        let config = UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.didSearch(text: searchController.searchBar.text ?? "")
    }
}
