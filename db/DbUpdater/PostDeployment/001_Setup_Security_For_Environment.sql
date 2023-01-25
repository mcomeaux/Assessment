declare @Message varchar(max); 

if upper('$Environment$') not in ( 'LOCAL', 'DEV', 'TEST', 'CERT', 'PROD' )
    begin
        set @Message = concat(N'ERROR: The $',
                              '(Environment) value ($Environment$) is not recognized. It must be one of the following: LOCAL, DEV, TEST, CERT, or PROD');
        exec hql.Report @Message, @Severity = 16, @State = 1;
        return;
    end;
GO


