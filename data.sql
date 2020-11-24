USE LoanModule

INSERT INTO LoanType(loan_type_id, percentage_value, name)
VALUES (0, 10, 'Mortgage'),
       (1, 15, 'Car loan'),
	   (2, 7, 'Appliance loan'),
       (3, 5, 'Payday loan'),
	   (4, 12, 'Cash loan')

INSERT INTO LoanStatus(loan_status_id,name)
VALUES (0, 'Repayed'),
	   (1, 'Pending'),
	   (2, 'Active'),
       (3, 'Delinquency and Default'),
	   (4, 'Deferment and Forebearance'),
       (5, 'Grace Period')

INSERT INTO RepaymentEventStatus(repayment_event_status_id,name)
VALUES (0, 'Pending'),
	   (1, 'Approved'),
	   (2, 'Denied')
      
INSERT INTO LoanDocumentType(loan_document_type_id,name)
VALUES (0, 'Identity proof'),
	   (1, 'Address proof'),
	   (2, 'Bank statement'),
	   (3, 'Salary certificate')

INSERT INTO Currency(currency_id, name)
VALUES (0, 'PLN'),
	   (1, 'USD'),
	   (2, 'EUR'),
	   (3, 'GBP'),
	   (4, 'JPY'),
	   (5, 'CHF'),
	   (6, 'RUB'),
	   (7, 'MXN')

INSERT INTO LoanInsuranceType(loan_insurance_type_id, percentage_value, name)
VALUES (0, 0.5, 'Disability Insurance'),
	   (1, 0.3, 'Life Insurance'),
	   (2, 0.6, 'Balance protection insurance'),
	   (3, 0.7, 'Debt insurance'),
	   (4, 0, 'NONE')

INSERT INTO LoanInsurance(loan_insurance_id, content, price, loan_insurance_type)
VALUES (0, 'Disability Insurance for loan: 0',3000, 0),
	   (1, 'Life Insurance for loan: 1',2000, 1),
	   (2, 'Balance protection insurance for loan: 2',1000, 2),
	   (3, 'Debt insurance for loan: 3',4000, 3),
	   (4, 'Disability Insurance for loan: 4', 1500, 0),
	   (5, 'Life Insurance for loan: 5',3000, 1),
	   (6, 'Balance protection insurance for loan: 6',2000, 2),
	   (7, 'Debt insurance for loan: 7',1200, 3),
	   (8, 'Disability Insurance for loan: 8',3000, 0),
	   (9, 'Life Insurance for loan: 9',1000, 1),
	   (10, 'Balance protection insurance for loan: 10',2000, 2),
	   (11, 'Debt insurance for loan: 11',2400, 3)

INSERT INTO Account(account_id, login, password, name, surname, balance, currency, is_client)
VALUES (0, '12345678', 'password', 'Tomasz', 'Stachura', 30000, 0, 1),
	   (1, '14580432', 'password', 'Lukasz', 'Rogozinski', 40000, 1, 1),
	   (2, '59201951', 'password', 'Jan', 'Kowalski',    3000,  2, 0),
	   (3, '56790732', 'password', 'Krzysztof', 'Nowak', 20000, 3, 1),
	   (4, '41235165', 'password', 'Kamil', 'Kucharski', 7000,  4, 1),
	   (5, '09701251', 'password', 'Szymon', 'Mes', 30000, 5, 1),
	   (6, '61235123', 'password', 'Roksana', 'Traczyk', 30000, 6, 1),
	   (7, '12345676', 'password', 'Karolina', 'Nawrot', 30000, 7, 1),
	   (8, '63123414', 'password', 'Marta', 'Weber', 30000, 7, 1),
	   (9, '81235961', 'password', 'Konrad', 'Kowalski', 30000,  0, 1),
	   (10, '43252932', 'password', 'Ma³gorzata', 'Naze', 30000, 5, 1),
	   (11, '83838383', 'password', 'Piotr', 'Nowak', 30000, 4, 1)

INSERT INTO Loan(loan_id, amount, current_amount, rrso, number_of_loan_installment, loan_installment, loan_type, loan_status, currency, loan_insurance, account)
VALUES (0, 10000, 0, 1, 0, 1000, 0, 0,0,0, 0),
	   (1, 20000, 19000, 2, 19, 1000, 1, 2,1, 1, 0),
	   (2, 30000, 27000, 3, 9, 3000, 2, 2,2, 2, 1),
	   (3, 40000, 36000, 4, 18, 2000, 3, 3, 3, 3, 3),
	   (4, 50000, 45000, 5, 9, 5000, 3, 4, 4, 4, 3),
	   (5, 60000, 54000, 1,27, 2000, 2,4, 5, 5, 4),
	   (6, 70000, 63000, 2,9, 7000,1,3, 6, 6, 6),
	   (7, 80000, 72000, 3,36, 2000,0,2, 7, 7, 7),
	   (8, 100000, 10000, 2, 2, 5000,0,1, 7, 8, 8),
	   (9, 110000, 99000, 5, 9, 11000, 1, 0, 6, 9, 9),
	   (10,120000, 108000, 3, 36,3000, 2, 5, 5, 10, 10),
	   (11,130000, 117000, 5, 9, 13000, 3, 2, 4, 11, 11)
	  
INSERT INTO RepaymentEvent (repayment_event_id, name, amount, repayment_date, repayment_status, loan, currency)
VALUES (0, 'Repayment amount = 1000 PLN', 1000, '2020-11-01', 2,0,0),
	   (1, 'Repayment amount = 1000 USD', 1000, '2020-11-02', 1,1,1),
	   (2, 'Repayment amount = 3000 EUR', 3000, '2020-11-02', 0,2,2),
	   (3, 'Repayment amount = 2000 GBP', 2000, '2020-11-02', 0,3,3),
	   (4, 'Repayment amount = 5000 JPY', 5000, '2020-11-02', 1,4,4),
	   (5, 'Repayment amount = 2000 CHF', 2000,'2020-11-02', 2,5,5),
	   (6, 'Repayment amount = 7000 RUB', 7000,'2020-11-02', 2,6,6),
	   (7, 'Repayment amount = 2000 MXN', 2000, '2020-11-02', 1,7,7),
	   (8, 'Repayment amount = 5000 MXN', 5000, '2020-11-02', 0,8,7),
	   (9, 'Repayment amount = 11000 PLN', 11000, '2020-11-02', 0,9,0),
	   (10, 'Repayment amount = 3000 CHF', 3000, '2020-11-02', 1,10,5),
	   (11,'Repayment amount = 13000 JPY', 13000, '2020-11-02', 2,11,4)	  


INSERT INTO LoanDocument(loan_document_id, content, loan_document_type, loan_id)
VALUES (0, 'Identity proof content', 0, 0),
	   (1, 'Address proof content', 1, 0),
	   (2, 'Bank statement content', 2, 0),
	   (3, 'Salary certificate content', 3, 0),
	   (4, 'Identity proof content', 0, 1),
	   (5, 'Address proof content', 1, 1),
	   (6, 'Bank statement content', 2, 1),
	   (7, 'Salary certificate content', 3, 1),
	   (8, 'Identity proof content', 0,	2),
	   (9, 'Address proof content', 1, 2),
	   (10, 'Bank statement content', 2, 2),
	   (11, 'Salary certificate content', 3, 2),
	   (12, 'Identity proof content', 0, 3),
	   (13, 'Address proof content', 1, 3),
	   (14, 'Bank statement content', 2, 3),
	   (15, 'Salary certificate content', 3, 3),
	   (16, 'Identity proof content', 0, 4),
	   (17, 'Address proof content', 1, 4),
	   (18, 'Bank statement content', 2, 4),
	   (19, 'Salary certificate content', 3, 4),
	   (20, 'Identity proof content', 0, 5),
	   (21, 'Address proof content', 1, 5),
	   (22, 'Bank statement content', 2, 5),
	   (23, 'Salary certificate content', 3, 5),
	   (24, 'Identity proof content', 0, 6),
	   (25, 'Address proof content', 1, 6),
	   (26, 'Bank statement content', 2, 6),
	   (27, 'Salary certificate content', 3, 6),
	   (28, 'Identity proof content', 0, 7),
	   (29, 'Address proof content', 1, 7),
	   (30, 'Bank statement content', 2, 7),
	   (31, 'Salary certificate content', 3, 7),
	   (32, 'Identity proof content', 0, 8),
	   (33, 'Address proof content', 1,	8),
	   (34, 'Bank statement content', 2, 8),
	   (35, 'Salary certificate content', 3, 8),
	   (36, 'Identity proof content', 0, 9),
	   (37, 'Address proof content', 1,	9),
	   (38, 'Bank statement content', 2, 9),
	   (39, 'Salary certificate content', 3, 9),
	   (40, 'Identity proof content', 0, 10),
	   (41, 'Address proof content', 1,	10),
	   (42, 'Bank statement content', 2, 10),
	   (43, 'Salary certificate content', 3, 10),
	   (44, 'Identity proof content', 0, 11),
	   (45, 'Address proof content', 1, 11),
	   (46, 'Bank statement content', 2, 11),
	   (47, 'Salary certificate content', 3, 11)
		  


	 