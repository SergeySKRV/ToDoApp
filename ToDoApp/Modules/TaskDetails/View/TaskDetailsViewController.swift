//
//  TaskDetailsViewController.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import UIKit

final class TaskDetailsViewController: UIViewController {
    var presenter: TaskDetailsPresenterProtocol?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleTextView = UITextView()
    private let dateLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let titlePlaceholderLabel = UILabel()
    private let descriptionPlaceholderLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension TaskDetailsViewController {
    func setupUI() {
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle(" \(L10n.back)", for: .normal)
        backButton.tintColor = AppColors.accent
        backButton.setTitleColor(AppColors.accent, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = AppColors.accent

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        setupTitleTextView()
        setupDateLabel()
        setupDescriptionTextView()
        setupPlaceholders()

        view.addSubview(scrollView)
        view.addSubview(activityIndicator)

        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionTextView)

        titleTextView.addSubview(titlePlaceholderLabel)
        descriptionTextView.addSubview(descriptionPlaceholderLabel)

        NSLayoutConstraint.activate([
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240),

            titlePlaceholderLabel.topAnchor.constraint(equalTo: titleTextView.topAnchor),
            titlePlaceholderLabel.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor, constant: 5),
            titlePlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: titleTextView.trailingAnchor),

            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 5),
            descriptionPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: descriptionTextView.trailingAnchor)
        ])
    }

    func setupTitleTextView() {
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.backgroundColor = .clear
        titleTextView.textColor = AppColors.primaryText
        titleTextView.tintColor = AppColors.primaryText
        titleTextView.font = .systemFont(ofSize: 34, weight: .bold)
        titleTextView.isScrollEnabled = false
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.autocapitalizationType = .sentences
        titleTextView.returnKeyType = .default
        titleTextView.delegate = self
    }

    func setupDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = AppColors.tertiaryText
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.numberOfLines = 1
    }

    func setupDescriptionTextView() {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textColor = AppColors.primaryText
        descriptionTextView.tintColor = AppColors.primaryText
        descriptionTextView.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.autocapitalizationType = .sentences
        descriptionTextView.delegate = self
    }

    func setupPlaceholders() {
        titlePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        titlePlaceholderLabel.text = L10n.taskTitlePlaceholder
        titlePlaceholderLabel.textColor = AppColors.tertiaryText
        titlePlaceholderLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titlePlaceholderLabel.numberOfLines = 1
        titlePlaceholderLabel.isUserInteractionEnabled = false

        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionPlaceholderLabel.text = L10n.taskDescriptionPlaceholder
        descriptionPlaceholderLabel.textColor = AppColors.tertiaryText
        descriptionPlaceholderLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionPlaceholderLabel.numberOfLines = 1
        descriptionPlaceholderLabel.isUserInteractionEnabled = false
    }

    func updatePlaceholdersVisibility() {
        titlePlaceholderLabel.isHidden = !titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc func didTapBack() {
        presenter?.didTapSave(
            title: titleTextView.text ?? "",
            description: descriptionTextView.text ?? "",
            isCompleted: false
        )
    }
}

extension TaskDetailsViewController: TaskDetailsViewProtocol {
    func display(title: String, description: String, screenTitle: String, dateText: String?) {
        self.title = screenTitle
        titleTextView.text = title
        descriptionTextView.text = description
        dateLabel.text = dateText
        dateLabel.isHidden = dateText == nil
        updatePlaceholdersVisibility()
    }

    func showLoading(_ isLoading: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = !isLoading
        titleTextView.isEditable = !isLoading
        descriptionTextView.isEditable = !isLoading

        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: L10n.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        present(alert, animated: true)
    }
}

extension TaskDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholdersVisibility()
    }
}
