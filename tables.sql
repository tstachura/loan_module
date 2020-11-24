CREATE DATABASE LoanModule
GO
USE LoanModule

CREATE TABLE LoanType (
	loan_type_id INT PRIMARY KEY,
	percentage_value float NOT NULL,
	name VARCHAR(50) NOT NULL
)
GO

CREATE TABLE LoanStatus (
	loan_status_id INT PRIMARY KEY,
	name VARCHAR(50) NOT NULL
)
GO

CREATE TABLE RepaymentEventStatus (
    repayment_event_status_id INT PRIMARY KEY,
	name VARCHAR(50) NOT NULL
)
GO

CREATE TABLE LoanDocumentType (
	loan_document_type_id INT PRIMARY KEY,
	name VARCHAR(50) NOT NULL
)
GO

CREATE TABLE Currency (
	currency_id INT PRIMARY KEY,
	name VARCHAR(50) NOT NULL
)
GO

CREATE TABLE LoanInsuranceType (
	loan_insurance_type_id INT PRIMARY KEY,
	percentage_value float NOT NULL,
	name VARCHAR(50) NOT NULL
)
GO

CREATE TABLE LoanInsurance (
	loan_insurance_id INT PRIMARY KEY,
	content VARCHAR(500) NOT NULL,
	price FLOAT NOT NULL,
	loan_insurance_type INT NOT NULL,
	CONSTRAINT FK_loanInsurance_loanInsuranceType
	FOREIGN KEY(loan_insurance_type) REFERENCES LoanInsuranceType(loan_insurance_type_id)
)
GO

CREATE TABLE Account (
	account_id INT PRIMARY KEY,
	login VARCHAR(8) UNIQUE NOT NULL,
	password VARCHAR(10) NOT NULL,
	name VARCHAR(50) NOT NULL,
	surname VARCHAR(50) NOT NULL,
	balance FLOAT NOT NULL,
	currency INT NOT NULL,
	is_client BIT NOT NULL,
	CONSTRAINT FK_account_currency
	FOREIGN KEY(currency) REFERENCES Currency(currency_id)
)
GO

CREATE TABLE Loan (
	loan_id INT PRIMARY KEY,
	amount FLOAT NOT NULL,
	current_amount FLOAT NOT NULL,
	rrso FLOAT,
	number_of_loan_installment INT NOT NULL,
	loan_installment FLOAT NOT NULL,
	loan_type INT NOT NULL,
	loan_status INT NOT NULL,
	currency INT NOT NULL,
	loan_insurance INT NOT NULL,
	account INT NOT NULL,
	CONSTRAINT FK_loan_loanType
	FOREIGN KEY(loan_type) REFERENCES LoanType(loan_type_id),
	CONSTRAINT FK_loan_loanStatus
	FOREIGN KEY(loan_status) REFERENCES LoanStatus(loan_status_id),
	CONSTRAINT FK_loan_currency
	FOREIGN KEY(currency) REFERENCES Currency(currency_id),
	CONSTRAINT FK_loan_loanInsurance
	FOREIGN KEY(loan_insurance) REFERENCES LoanInsurance(loan_insurance_id),
	CONSTRAINT FK_loan_account
	FOREIGN KEY(account) REFERENCES Account(account_id)
)
GO

CREATE TABLE LoanDocument (
	loan_document_id INT PRIMARY KEY,
	content VARCHAR(500) NOT NULL,
	loan_document_type INT NOT NULL,
	loan_id INT NOT NULL,
	CONSTRAINT FK_loanDocument_loanDocumentType
	FOREIGN KEY(loan_document_type) REFERENCES LoanDocumentType(loan_document_type_id),
	CONSTRAINT FK_loanDocument_loan
	FOREIGN KEY(loan_id) REFERENCES Loan(loan_id)
)
GO

CREATE TABLE RepaymentEvent (
	repayment_event_id INT PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	amount FLOAT NOT NULL,
	repayment_date DATE NOT NULL,
	repayment_status INT NOT NULL,
	loan INT NOT NULL,
	currency INT NOT NULL,
	CONSTRAINT FK_repayment_event_currency
	FOREIGN KEY(currency) REFERENCES Currency(currency_id),
	CONSTRAINT FK_repaymentEvent_loanStatus
	FOREIGN KEY(repayment_status) REFERENCES RepaymentEventStatus(repayment_event_status_id),
	CONSTRAINT FK_repaymentEvent_loan
	FOREIGN KEY(loan) REFERENCES Loan(loan_id)
)
GO