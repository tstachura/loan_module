USE LoanModule

set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[CalculateRRSOAndroid] @amount float, @number_of_loan_installment int, @loan_type int, @loan_insurance_type INT
	as begin
			declare @tab table(col1 float)
			declare @rrso float, @percentage int, @insurance_percentage int, @commission int = 1
			select @percentage = coalesce((select top 1 percentage_value from LoanType where loan_type_id = @loan_type), 0)
			select @insurance_percentage = coalesce((select top 1 percentage_value from LoanInsuranceType where loan_insurance_type_id = @loan_insurance_type), 0)
			select @rrso = @percentage + @commission * (12 / @number_of_loan_installment) + @insurance_percentage * 12
			insert @tab values(ROUND(@rrso, 2))
			select * from @tab
	end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go


	/* Execute CalculateLoanInstallment */
	--USE LoanModule
	--GO 
	--DECLARE @result float
	--EXEC @result = dbo.CalculateRRSOAndroid @amount= 15000, @number_of_loan_installment= 15, @loan_type= 1, @loan_insurance_type = 1
	--PRINT(@result)


/* Procedura obliczenia raty kredytu */
/**
Procedura oblicza wartoœæ raty kredytu. 
**/

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[CalculateLoanInstallmentAndroid] @amount float, @number_of_loan_installment int, @rrso float
	as begin
			declare @tab table(col1 float)
			declare @loan_installment float, @q float;
			select @q=1+@rrso/12/100
			select @loan_installment =  @amount*power(@q, @number_of_loan_installment)*(@q-1)/(power(@q,@number_of_loan_installment) -1)
			insert @tab values (ROUND(@loan_installment, 2))
			select * from @tab
	end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute CalculateLoanInstallment */
--	USE LoanModule
--	GO 
--	DECLARE @result float
--	EXEC @result = dbo.CalculateLoanInstallmentAndroid @amount= 15000, @number_of_loan_installment= 48,  @rrso =13
--	PRINT(@result)
--USE LoanModule

/* Procedura obliczenia rrso */
/**
Procedura oblicza rrso.
Wzór: rrso = oprocentowanie + prowizja * okres kredytowania + procent ubezpieczenia miesiêcznie * 12
Przyjmuj ¿e prowizja to 1%
**/

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[CalculateRRSO] @amount float, @number_of_loan_installment int, @loan_type int, @loan_insurance_type INT
	as begin
			declare @rrso float, @percentage int, @insurance_percentage int, @commission int = 1;
			select @percentage = coalesce((select top 1 percentage_value from LoanType where loan_type_id = @loan_type), 0)
			select @insurance_percentage = coalesce((select top 1 percentage_value from LoanInsuranceType where loan_insurance_type_id = @loan_insurance_type), 0)
			select @rrso = @percentage + @commission * (12 / @number_of_loan_installment) + @insurance_percentage * 12
			return @rrso
	end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute CalculateLoanInstallment */
	--USE LoanModule
	--GO 
	--DECLARE @result float
	--EXEC @result = dbo.CalculateRRSO @amount= 5000, @number_of_loan_installment= 16, @loan_type= 2, @loan_insurance_type = 4
	--PRINT(@result)


/* Procedura obliczenia raty kredytu */
/**
Procedura oblicza wartoœæ raty kredytu. 
**/

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[CalculateLoanInstallment] @amount float, @number_of_loan_installment int, @rrso float
	as begin
			declare @loan_installment float, @q float;
			select @q=1+@rrso/12/100
			select @loan_installment = @amount*power(@q, @number_of_loan_installment)*(@q-1)/(power(@q,@number_of_loan_installment) -1)
			return @loan_installment
	end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute CalculateLoanInstallment */
	--USE LoanModule
	--GO 
	--DECLARE @result float
	--EXEC @result = dbo.CalculateLoanInstallment @amount= 5000, @number_of_loan_installment= 16,  @rrso =79
	--PRINT(@result)

/* Procedura dodania nowego ubezpieczenia */
/** 
Procedura wewnêtrzna, ¿eby nie powtarzaæ kodu
Procedura dodaje nowe ubezpieczenie
Oblicza wartoœæ ubezpieczenia na podstawie wartoœci kredytu i procentu jaki ustawiny jest dla danego typu ubezpieczenia.
**/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER  PROCEDURE [dbo].[AddLoanInsurence] @loan_amount float, @loanInsurenceType int, @loanId int,  @number_of_loan_installment int
AS BEGIN
		DECLARE @ID int, @percentage float, @type_name varchar(50), @current_loan_insurence int;
		SELECT @type_name = coalesce((SELECT TOP 1 name FROM LoanInsuranceType WHERE loan_insurance_type_id = @loanInsurenceType), NULL) 
		SELECT @percentage = coalesce((SELECT TOP 1 percentage_value FROM LoanInsuranceType WHERE loan_insurance_type_id = @loanInsurenceType), NULL) 
		SELECT @current_loan_insurence = coalesce((SELECT TOP 1 loan_insurance FROM loan WHERE loan_id = @loanId), NULL) 
		SELECT @ID = coalesce((select max(loan_insurance_id) + 1 from LoanInsurance), 1)
		Print(@percentage)
		INSERT INTO LoanInsurance(loan_insurance_id, content, price, loan_insurance_type)
						VALUES (@ID,@type_name+ ' for loan: '+CAST(@loanId as varchar(10)), @loan_amount * @percentage / 100 , @loanInsurenceType)  
		RETURN @ID
END
GO
USE LoanModule
GO
ALTER DATABASE LoanModule SET READ_WRITE 
GO

	/* Execute AddLoanInsurence */
	--USE LoanModule
	--GO  
	--EXEC dbo.AddLoanInsurence @loan_amount=10000, @loanInsurenceType=2, @loanId=1,  @number_of_loan_installment=2
	--SELECT * FROM LoanInsurance 

/* Procedura ustawienia nowego ubezpieczenia */
/** 
Procedura dodaje nowe ubezpieczenie przez wywo³anie procedury AddLoanInsurence i ustawia je w ju¿ istniej¹cym kredycie
**/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER  PROCEDURE [dbo].[SetLoanInsurence] @loanId int, @loan_insurance_type int
AS BEGIN
		DECLARE @ID int,  @current_loan_insurence int, @loan_amount float, @loan_type int, @loan_current_insurance int, @msg varchar(300) ='Can not change insurence type. Insurence already set';
		SELECT @loan_amount = coalesce((SELECT TOP 1 amount FROM loan WHERE loan_id = @loanId), NULL) 
		SELECT @loan_type = coalesce((SELECT TOP 1 loan_type FROM loan WHERE loan_id = @loanId), NULL)
		SELECT @loan_current_insurance = coalesce((SELECT TOP 1 loan_insurance FROM loan WHERE loan_id = @loanId), NULL)
		if(coalesce((SELECT TOP 1 loan_insurance_type FROM LoanInsurance WHERE loan_insurance_id = @loan_current_insurance), NULL) =4)
			BEGIN
				exec @ID = AddLoanInsurence  @loan_amount, @loan_insurance_type, @loanId, @loan_type
				UPDATE Loan SET loan_insurance = @ID WHERE loan_id = @loanId
				DELETE LoanInsurance WHERE loan_insurance_id = @current_loan_insurence
			END
		else throw 51000, @msg, 1 
END
GO
USE LoanModule
GO
ALTER DATABASE LoanModule SET READ_WRITE 
GO

	/* Execute SetLoanInsurence */
	--USE LoanModule
	--GO  
	--EXEC dbo.SetLoanInsurence @loanId=12, @loan_insurance_type=1
	--SELECT * FROM LoanInsurance 
	--SELECT * FROM Loan 

/* Procedura wnioskowania o kredyt */
/** 
Procedura dodaje wniosek o kredyt.
Umo¿liwia ona na ustawienie rodzaju ubezpieczenia. Jesli nie jest ustawiony ¿adny typ ubezpieczenia ustawia go na NONE.
Oblicza wartoœæ ubezpieczneia na podstawie wartoœci kredytu i procentu jaki ustawiny jest dla danego typu ubezpieczenia.
**/
	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[ApplyForLoan] @amount float, @number_of_loan_installment int, @loan_type int, @currency int, @loan_insurence_type int, @account_id int
		AS BEGIN
				declare @id int, @loan_installment int, @loan_insurance int, @percentage int, @type_name varchar(50), @rrso float;
				select @id = coalesce((select max(loan_id) + 1 from Loan), 1)
				if @loan_insurence_type IS NOT NULL
					begin
						exec @loan_insurance = AddLoanInsurence  @amount, @loan_insurence_type, @id, @loan_type
						exec @rrso = CalculateRRSO  @amount, @number_of_loan_installment, @loan_type, @loan_insurence_type
					end
				else
					begin
						exec @loan_insurance = AddLoanInsurence  @amount, 4, @id, @loan_type
						exec @rrso = CalculateRRSO  @amount, @number_of_loan_installment, @loan_type, 4
					end
				
				exec @loan_installment = CalculateLoanInstallment  @amount, @number_of_loan_installment,  @rrso
				
				insert into Loan(loan_id, amount, current_amount, rrso, number_of_loan_installment, loan_installment, loan_type, loan_status, currency, loan_insurance, account)  
						values (@id, @amount, @loan_installment * @number_of_loan_installment, @rrso, @number_of_loan_installment, @loan_installment, @loan_type, 1, @currency, @loan_insurance, @account_id)  
			end
		go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute ApplyForLoan */
	--use LoanModule
	--go  
	--exec dbo.ApplyForLoan @amount=90000, @number_of_loan_installment = 10, @loan_type=1, @currency=1, @loan_insurence_type=1, @account_id=0
	--select * from Loan

/* Procedura zmiany statusu kredytu */
/** 
Procedura zmiany statusu kredytu.
Umo¿liwia nastêpuj¹ce zmiany statusów:
	Pending -> Active
	Active -> Repayed
	Delinquency and Default -> Repayed
	Deferment and Forebearance -> Repayed
	Grace Period -> Repayed
Uniemo¿liwia:
	Active -> Pending
	Delinquency and Default -> Pending
	Deferment and Forebearance -> Pending
	Grace Period -> Pending
	Repayed -> inne
	
Rzuca wyj¹tkiem jak przejœcie jest niemo¿liwe
**/
SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE OR ALTER  PROCEDURE [dbo].[ChangeLoanStatus]  @loan_id int, @loan_status int
		AS BEGIN
			DECLARE @current_status int, @current_status_name varchar(50),  @loan_status_name varchar(50), @current_amount float, @msg varchar(300) = 'Can not change loan status from ';
			SELECT @current_status = coalesce((SELECT TOP 1 loan_status FROM Loan WHERE loan_id = @loan_id), NULL) 
			SELECT @current_status_name = coalesce((SELECT TOP 1 name FROM LoanStatus WHERE loan_status_id = @current_status), NULL)
			SELECT @loan_status_name = coalesce((SELECT TOP 1 name FROM LoanStatus WHERE loan_status_id = @loan_status), NULL)
			SELECT @current_amount = coalesce((SELECT TOP 1 current_amount FROM Loan WHERE loan_id = @loan_id), NULL)
			SELECT @msg += @current_status_name + ' to ' + @loan_status_name

			if((@current_status = 1 AND @loan_status = 2) OR (@current_status IN(2,3,4,5) AND (@loan_status NOT IN(0,1) OR (@loan_status = 0 AND @current_amount=0))) )
				BEGIN
				UPDATE Loan SET loan_status = @loan_status WHERE loan_id = @loan_id
				END
			else throw 51000, @msg, 1 
			END
		GO
	USE LoanModule
	GO
	ALTER DATABASE LoanModule SET READ_WRITE 
	GO

	/* Execute ChangeLoanStatus */
	--USE LoanModule
	--GO  
	--EXEC dbo.ChangeLoanStatus  @loan_id = 2, @loan_status = 0
	--SELECT * FROM Loan


/* Procedura dodania sp³aty kredytu */
/** 
Sp³acenie kredytu mo¿liwe jedynie gdy jesgo status ustawiony jest na active = 2
W przeciwnym wypadku rzuca wyj¹tkiem o braku mo¿liwoœæi dokonania sp³aty dla innego statusu.
**/

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[RepayLoan] @loan_id int
		as begin
		declare @loan_status int, @msg varchar(50)= 'Can not repay loan with status ';
		select @loan_status = coalesce((select top 1 loan_status from Loan where loan_id = @loan_id), null)
		select @msg += coalesce((select top 1 name from LoanStatus where loan_status_id = @loan_status), null)
				if @loan_status = 2 
					begin
						declare @id int, @amount float, @currency_id int, @currency varchar(50);
						select @amount = coalesce((select top 1 loan_installment from Loan where loan_id = @loan_id), null)
						select @currency_id = coalesce((select top 1 currency from Loan where loan_id = @loan_id), null)
						select @currency = coalesce((select top 1 name from Currency where currency_id = @currency_id), null)
						select @id = coalesce((select max(repayment_event_id) + 1 from RepaymentEvent), 1)
						insert into RepaymentEvent(repayment_event_id, name, amount, repayment_date, repayment_status, loan, currency)  
						values (@id,'repayment amount = ' + cast(@amount as varchar(10))+' '+cast(@currency as varchar(10)), @amount, getdate(),0,@loan_id, @currency_id)  
					end
				else throw 51000, @msg, 1
			end
		go
	use loanmodule
	go
	alter database loanmodule set read_write 
	go

	/* Execute RepayLoan */
	--USE LoanModule
	--GO  
	--EXEC dbo.RepayLoan @loan_id = '1'
	
	--SELECT * FROM Loan
	--SELECT * FROM LoanInsurance
	--SELECT * FROM RepaymentEvent


/* Procedura wyœwietlenia historii sp³aty kredytu */
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE OR ALTER  PROCEDURE [dbo].[GetRepaymentHistory] @loanId int
		AS BEGIN
				 SELECT * FROM RepaymentEvent WHERE RepaymentEvent.loan = @loanId
			END
		GO
	USE LoanModule
	GO
	ALTER DATABASE LoanModule SET READ_WRITE 
	GO

	/* Execute GetRepaymentHistory */
	--USE LoanModule
	--GO  
	--EXEC dbo.GetRepaymentHistory @loanId=0


/* Procedura wyœwietlenia informacji o kredytach konta */

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE OR ALTER  PROCEDURE [dbo].[GetLoanInformationForAccount] @account_id int
		AS BEGIN
			 SELECT * FROM Loan WHERE account = @account_id
		END
	GO
	USE LoanModule
	GO
	ALTER DATABASE LoanModule SET READ_WRITE 
	GO

	/* Execute GetLoanInformationForAccount */
	--USE LoanModule
	--GO  
 --   EXEC dbo.GetLoanInformationForAccount @account_id=0
	

/* Wyœwietl dokumenty dotycz¹ce kredytu */

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE OR ALTER  PROCEDURE [dbo].[GetLoanDocuments] @loan_id int
		AS BEGIN
			 SELECT * FROM LoanDocument WHERE loan_id = @loan_id
		END
	GO
	USE LoanModule
	GO
	ALTER DATABASE LoanModule SET READ_WRITE 
	GO

	/* Execute GetLoanDocuments */
	--USE LoanModule
	--GO  
 --   EXEC dbo.GetLoanDocuments @loan_id=0
	

/* Procedura dodania dokumentu dla kredytu */

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE OR ALTER  PROCEDURE [dbo].[AddLoanDocument] @loanId int, @loanDocumentType int, @content varchar(500)
	AS BEGIN
			DECLARE @ID int;
			SELECT @ID = coalesce((select max(loan_document_id) + 1 from LoanDocument), 1)
			INSERT INTO LoanDocument(loan_document_id, content, loan_document_type, loan_id)  
							VALUES (@ID,@content, @loanDocumentType, @loanId)  
	END
	GO
	USE LoanModule
	GO
	ALTER DATABASE LoanModule SET READ_WRITE 
	GO

	/* Execute AddLoanDocument */
	--USE LoanModule
	--GO  
	--EXEC dbo.AddLoanDocument @loanId=0, @loanDocumentType=1, @content='text'
	--SELECT * FROM LoanDocument 

/* Procedura usuniêcia dokumentu dla kredytu */

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE OR ALTER  PROCEDURE [dbo].[DeleteLoanDocument] @loanDocumentId int
	AS BEGIN
			DECLARE @ID int;
			DELETE LoanDocument WHERE loan_document_id=@loanDocumentId
	  
	END
	GO
	USE LoanModule
	GO
	ALTER DATABASE LoanModule SET READ_WRITE 
	GO

	/* Execute DeleteLoanDocument */
	--USE LoanModule
	--GO  
	--EXEC dbo.DeleteLoanDocument @loanDocumentId=0
	--SELECT * FROM LoanDocument 

/* Procedura zmiany statusu wp³aty */
/** 
Procedura umo¿liwia zmianê statusy wniosku o sp³atê na:
	Pending -> Approved
	Pending -> Denied
Jeœli status kredytu jest inny ni¿ active = 2 rzuca wyj¹tkiem 
Jeœli status zmieniany jest na active zmienia wartoœci current_amount, number_of_loan_installment, oraz jeœli current_amount = 0 ustawia status kredytu na repayed = 0
**/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER  PROCEDURE [dbo].[ChangeRepaymentStatus]  @repayment_id int, @repayment_status int
	AS BEGIN
		DECLARE @current_status int, @amount float, @loanId int, @current_loan_status int, @msg varchar(300) = 'Can not repay loan with status', @msg2 varchar(300) = 'Can not change repayment status from ',
		@current_status_name varchar(50), @repayment_status_name varchar(50);
		
		SELECT @loanId = coalesce((SELECT TOP 1 loan FROM RepaymentEvent WHERE repayment_event_id = @repayment_id), NULL) 
		SELECT @amount = coalesce((SELECT TOP 1 amount FROM RepaymentEvent WHERE repayment_event_id = @repayment_id), NULL)
		SELECT @current_loan_status = coalesce((SELECT TOP 1 loan_status FROM Loan WHERE loan_id = @loanId), NULL) 
		SELECT @current_status = coalesce((SELECT TOP 1 repayment_status FROM RepaymentEvent WHERE repayment_event_id = @repayment_id), NULL) 
		SELECT @current_status_name = coalesce((SELECT TOP 1 name FROM RepaymentEventStatus WHERE repayment_event_status_id = @current_status), NULL) 
		SELECT @repayment_status_name = coalesce((SELECT TOP 1 name FROM RepaymentEventStatus WHERE repayment_event_status_id = @repayment_status), NULL) 
		SELECT @msg += coalesce((SELECT TOP 1 name FROM LoanStatus WHERE loan_status_id = @current_loan_status), NULL) 
		SELECT @msg2 += @current_status_name+' to '+@repayment_status_name
		if((@current_status = 0 AND @repayment_status IN(1,2)) )
			BEGIN
			if( @current_loan_status !=2) 
				throw 51000, @msg, 1
			else
				BEGIN
					UPDATE RepaymentEvent SET repayment_status = @repayment_status WHERE repayment_event_id = @repayment_id 
					if(@repayment_status=1)
						BEGIN
							UPDATE Loan SET 
									current_amount = current_amount - @amount, 
									number_of_loan_installment -= 1 
									WHERE loan_id = @loanId
							UPDATE Loan SET loan_status = 0 WHERE loan_id = @loanId and current_amount = 0 
						END
				END
			END
		else throw 51000, @msg2, 1
		END
	GO
USE LoanModule
GO
ALTER DATABASE LoanModule SET READ_WRITE 
GO

	/* Execute [ChangeRepaymentStatus] */
	--USE LoanModule
	--GO  
	--EXEC dbo.[ChangeRepaymentStatus] @repayment_id = 11 , @repayment_status = 1
	--SELECT * FROM RepaymentEvent
	--SELECT * FROM Loan


