use LoanModule


/* Procedura obliczenia rrso */
/**
Procedura oblicza rrso, zwraca ResultSet dla Android.
Wzór: rrso = oprocentowanie + prowizja * okres kredytowania + procent ubezpieczenia miesiêcznie * 12
Przyjmuj ¿e prowizja to 1%
**/
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
	--use LoanModule
	--GO 
	--declare @result float
	--EXEC @result = dbo.CalculateRRSOAndroid @amount= 15000, @number_of_loan_installment= 15, @loan_type= 1, @loan_insurance_type = 1
	--PRINT(@result)


/* Procedura obliczenia raty kredytu */
/**
Procedura oblicza wartoœæ raty kredytu, zwraca ResultSet dla Android. 
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
--	use LoanModule
--	GO 
--	declare @result float
--	EXEC @result = dbo.CalculateLoanInstallmentAndroid @amount= 15000, @number_of_loan_installment= 48,  @rrso =13
--	PRINT(@result)
--use LoanModule

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
	use LoanModule
	GO 
	declare @result float
	EXEC @result = dbo.CalculateRRSO @amount= 5000, @number_of_loan_installment= 16, @loan_type= 2, @loan_insurance_type = 4
	PRINT(@result)


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
	--use LoanModule
	--GO 
	--declare @result float
	--EXEC @result = dbo.CalculateLoanInstallment @amount= 5000, @number_of_loan_installment= 16,  @rrso =79
	--PRINT(@result)

/* Procedura dodania nowego ubezpieczenia */
/** 
Procedura wewnêtrzna dodaj¹ca nowe ubezpieczenie
Oblicza wartoœæ ubezpieczenia na podstawie wartoœci kredytu i procentu jaki ustawiany jest dla danego typu ubezpieczenia.
**/

set ansi_nulls on
go
set quoted_identifier on
go
create or alter  procedure [dbo].[AddLoanInsurence] @loan_amount float, @loan_insurence_type int, @loanId int,  @number_of_loan_installment int
as begin
		declare @ID int, @percentage float, @type_name varchar(50), @current_loan_insurence int;
		select @type_name = coalesce((select top 1 name from LoanInsuranceType where loan_insurance_type_id = @loan_insurence_type), NULL) 
		select @percentage = coalesce((select top 1 percentage_value from LoanInsuranceType where loan_insurance_type_id = @loan_insurence_type), NULL) 
		select @current_loan_insurence = coalesce((select top 1 loan_insurance from Loan where loan_id = @loanId), NULL) 
		select @ID = coalesce((select max(loan_insurance_id) + 1 from LoanInsurance), 1)
		insert into LoanInsurance(loan_insurance_id, content, price, loan_insurance_type)
						values (@ID,@type_name+ ' for loan: '+cast(@loanId as varchar(10)), @loan_amount * @percentage / 100 , @loan_insurence_type)  
		return @ID
end
go
use LoanModule
go
alter database LoanModule set read_write 
go

	/* Execute AddLoanInsurence */
	use LoanModule
	GO  
	EXEC dbo.AddLoanInsurence @loan_amount=10000, @loan_insurence_type=2, @loanId=1,  @number_of_loan_installment=2
	select * from LoanInsurance 

/* Procedura ustawienia nowego ubezpieczenia */
/** 
Procedura dodaje nowe ubezpieczenie przez wywo³anie procedury AddLoanInsurence i ustawia je w ju¿ istniej¹cym kredycie
**/

set ansi_nulls on
go
set quoted_identifier on
go
create or alter  procedure [dbo].[SetLoanInsurence] @loanId int, @loan_insurance_type int
as begin
		declare @ID int, @loan_amount float, @loan_type int, @loan_current_insurance int, @msg varchar(300) ='Can not change insurance type. Insurance already set';
		select @loan_amount = coalesce((select top 1 amount from Loan where loan_id = @loanId), NULL) 
		select @loan_type = coalesce((select top 1 loan_type from Loan where loan_id = @loanId), NULL)
		select @loan_current_insurance = coalesce((select top 1 loan_insurance from Loan where loan_id = @loanId), NULL)
		if(coalesce((select top 1 loan_insurance_type from LoanInsurance where loan_insurance_id = @loan_current_insurance), NULL) = 4)
			begin
				exec @ID = AddLoanInsurence  @loan_amount, @loan_insurance_type, @loanId, @loan_type
				UPDATE Loan set loan_insurance = @ID where loan_id = @loanId
				delete LoanInsurance where loan_insurance_id = @loan_current_insurance
			end
		else throw 51000, @msg, 1 
end
go
use LoanModule
go
alter database LoanModule set read_write 
go

	/* Execute SetLoanInsurence */
	use LoanModule
	GO  
	EXEC dbo.SetLoanInsurence @loanId=12, @loan_insurance_type=1
	select * from LoanInsurance 
	select * from Loan 

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
		AS begin
				declare @id int, @loan_installment int, @loan_insurance int, @percentage int, @type_name varchar(50), @rrso float;
				select @id = coalesce((select max(loan_id) + 1 from Loan), 1)
				if @loan_insurence_type is not null
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
	use LoanModule
	go  
	exec dbo.ApplyForLoan @amount=90000, @number_of_loan_installment = 10, @loan_type=1, @currency=1, @loan_insurence_type=null, @account_id=0
	select * from Loan

/* Procedura zmiany statusu kredytu */
/** 
Procedura zmiany statusu kredytu.
Umo¿liwia nastêpuj¹ce zmiany statusów:
	Pending -> Active
	Pending -> Denied
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
	Denied -> inne
	
Procedura rzuca wyj¹tkiem jeœli przejœcie jest niemo¿liwe
**/
set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[ChangeLoanStatus]  @loan_id int, @loan_status int
		as begin
			declare @current_status int, @current_status_name varchar(50),  @loan_status_name varchar(50), @current_amount float, @msg varchar(300) = 'Can not change loan status from ';
			select @current_status = coalesce((select top 1 loan_status from Loan where loan_id = @loan_id), NULL) 
			select @current_status_name = coalesce((select top 1 name from LoanStatus where loan_status_id = @current_status), NULL)
			select @loan_status_name = coalesce((select top 1 name from LoanStatus where loan_status_id = @loan_status), NULL)
			select @current_amount = coalesce((select top 1 current_amount from Loan where loan_id = @loan_id), NULL)
			select @msg += @current_status_name + ' to ' + @loan_status_name

			if((@current_status = 1 and @loan_status in( 2,6)) or (@current_status in(2,3,4,5) and (@loan_status not in(0,1) or (@loan_status = 0 and @current_amount=0))) )
				begin
				update Loan set loan_status = @loan_status where loan_id = @loan_id
				end
			else throw 51000, @msg, 1 
			end
		go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute ChangeLoanStatus */
	use LoanModule
	GO  
	EXEC dbo.ChangeLoanStatus  @loan_id = 2, @loan_status = 4
	select * from Loan


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
						values (@id,'Repayment amount = ' + cast(@amount as varchar(10))+' '+cast(@currency as varchar(10)), @amount, getdate(),0,@loan_id, @currency_id)  
					end
				else throw 51000, @msg, 1
			end
		go
	use loanmodule
	go
	alter database loanmodule set read_write 
	go

	/* Execute RepayLoan */
	use LoanModule
	GO  
	EXEC dbo.RepayLoan @loan_id = 1
	select * from RepaymentEvent


/* Procedura wyœwietlenia historii sp³aty kredytu */
	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[GetRepaymentHistory] @loan_id int
		as begin
				 select * from RepaymentEvent where RepaymentEvent.loan = @loan_id
			end
		go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute GetRepaymentHistory */
	use LoanModule
	GO  
	EXEC dbo.GetRepaymentHistory @loan_id=8


/* Procedura wyœwietlenia informacji o kredytach konta */

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[GetLoanInformationForAccount] @account_id int
		as begin
			 select * from Loan where account = @account_id
		end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute GetLoanInformationForAccount */
	use LoanModule
	GO  
    EXEC dbo.GetLoanInformationForAccount @account_id=0
	

/* Wyœwietl dokumenty dotycz¹ce kredytu */

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[GetLoanDocuments] @loan_id int
		as begin
			 select * from LoanDocument where loan_id = @loan_id
		end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute GetLoanDocuments */
	use LoanModule
	GO  
    EXEC dbo.GetLoanDocuments @loan_id=0
	

/* Procedura dodania dokumentu dla kredytu */

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[AddLoanDocument] @loanId int, @loan_document_type int, @content varchar(500)
	as begin
			declare @ID int;
			select @ID = coalesce((select max(loan_document_id) + 1 from LoanDocument), 1)
			insert into LoanDocument(loan_document_id, content, loan_document_type, loan_id)  
							values (@ID,@content, @loan_document_type, @loanId)  
	end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute AddLoanDocument */
	use LoanModule
	GO  
	EXEC dbo.AddLoanDocument @loanId=0, @loan_document_type=1, @content='text'
	select * from LoanDocument 

/* Procedura usuniêcia dokumentu dla kredytu */

	set ansi_nulls on
	go
	set quoted_identifier on
	go
	create or alter  procedure [dbo].[deleteLoanDocument] @loan_document_id int
	as begin
			declare @ID int;
			delete LoanDocument where loan_document_id=@loan_document_id
	  
	end
	go
	use LoanModule
	go
	alter database LoanModule set read_write 
	go

	/* Execute deleteLoanDocument */
	use LoanModule
	GO  
	EXEC dbo.deleteLoanDocument @loan_document_id=0
	select * from LoanDocument 

/* Procedura zmiany statusu wp³aty */
/** 
Procedura umo¿liwia zmianê statusy wniosku o sp³atê na:
	Pending -> Approved
	Pending -> Denied
Jeœli status kredytu jest inny ni¿ active = 2 rzuca wyj¹tkiem 
Jeœli status zmieniany jest na active zmienia wartoœci current_amount, number_of_loan_installment, oraz jeœli current_amount = 0 ustawia status kredytu na repayed = 0
**/
set ansi_nulls on
go
set quoted_identifier on
go
create or alter  procedure [dbo].[ChangeRepaymentStatus]  @repayment_id int, @repayment_status int
	as begin
		declare @current_status int, @amount float, @loanId int, @current_loan_status int, @msg varchar(300) = 'Can not repay loan with status', @msg2 varchar(300) = 'Can not change repayment status from ',
		@current_status_name varchar(50), @repayment_status_name varchar(50);
		
		select @loanId = coalesce((select top 1 loan from RepaymentEvent where repayment_event_id = @repayment_id), NULL) 
		select @amount = coalesce((select top 1 amount from RepaymentEvent where repayment_event_id = @repayment_id), NULL)
		select @current_loan_status = coalesce((select top 1 loan_status from Loan where loan_id = @loanId), NULL) 
		select @current_status = coalesce((select top 1 repayment_status from RepaymentEvent where repayment_event_id = @repayment_id), NULL) 
		select @current_status_name = coalesce((select top 1 name from RepaymentEventStatus where repayment_event_status_id = @current_status), NULL) 
		select @repayment_status_name = coalesce((select top 1 name from RepaymentEventStatus where repayment_event_status_id = @repayment_status), NULL) 
		select @msg += coalesce((select top 1 name from LoanStatus where loan_status_id = @current_loan_status), NULL) 
		select @msg2 += @current_status_name+' to '+@repayment_status_name
		if((@current_status = 0 AND @repayment_status IN(1,2)) )
			begin
			if( @current_loan_status !=2) 
				throw 51000, @msg, 1
			else
				begin
					update RepaymentEvent set repayment_status = @repayment_status where repayment_event_id = @repayment_id 
					if(@repayment_status=1)
						begin
							update Loan set 
									current_amount = current_amount - @amount, 
									number_of_loan_installment -= 1 
									where loan_id = @loanId
							update Loan set loan_status = 0 where loan_id = @loanId and current_amount = 0 
						end
				end
			end
		else throw 51000, @msg2, 1
		end
	go
use LoanModule
go
alter database LoanModule set read_write 
go

	/* Execute [ChangeRepaymentStatus] */
	use LoanModule
	GO  
	EXEC dbo.[ChangeRepaymentStatus] @repayment_id = 12 , @repayment_status = 1
	select * from RepaymentEvent
	select * from Loan


