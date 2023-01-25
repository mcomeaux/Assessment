raiserror('--------------------------------------------------------------------------------', 10, 1) with noWait;
raiserror('--============================================================================--', 10, 1) with noWait;
raiserror('--	Helper Query Language (hql) Tools                                        --', 10, 1) with noWait;
raiserror('--                                                                            --', 10, 1) with noWait;
raiserror('--		hql(tm) is a set of scripting tools for SQL Server that are useful   --', 10, 1) with noWait;
raiserror('--		database management scripts.                                         --', 10, 1) with noWait;
raiserror('--                                                                            --', 10, 1) with noWait;
raiserror('--============================================================================--', 10, 1) with noWait;
raiserror('--------------------------------------------------------------------------------', 10, 1) with noWait;
raiserror('', 10, 1) with noWait;
go

-------------------------------------------------------------------------------
--=============================================================================

set quoted_Identifier on;
go
set ansi_Nulls on;
go

-------------------------------------------------------------------------------
--=============================================================================

if not exists ( select
                        1
                    from
                        sys.schemas
                    where
                        name = 'hql' )
    begin
        declare @FormattedMessage nVarchar(max) 
        = replace(concat(lTrim(rTrim(convert(varchar(32), getDate(), 127))), ' : [hql] : ', 'Creating schema...'),
                  space(2), space(1));
        raiserror(@FormattedMessage, 10, 1) with noWait;
        exec sp_executesql N'create schema [hql] authorization [dbo]';
    end;

go

-------------------------------------------------------------------------------
--=============================================================================

declare @FormattedMessage nVarchar(max) 
        = replace(concat(lTrim(rTrim(convert(varchar(32), getDate(), 127))), ' : [hql].[Print] : ',
                         'Creating stored procedure...'), space(2), space(1));
raiserror(@FormattedMessage, 10, 1) with noWait;
go

-------------------------------------------------------------------------------
--=============================================================================

if object_Id('[hql].[Print]') is not null
    drop procedure hql.[Print];
go

-------------------------------------------------------------------------------
--=============================================================================
--	hql.Print
--
--		Output a message to the standard output.
--
--		@Message		Required. The text that is to be displayed.
--
--		@Severity		Optional. The error severity for the message. If 
--						specified, the value must be 0-10 or 16. See MSDN article 
--						at https://msdn.microsoft.com/en-us/library/ms164086.aspx
--						for more information @Severity. For Severity values 0 to 
--						10, the database engine does not record an error. For 
--						a Severity value of 16, the database engine records an 
--						error, but execution of the caller is not terminated.
--						The default value is 10. 
--
--		@State			Optional. The error state for the message. If specified, 
--						this must be a legal value for RAISERROR (0 to 255). 
--						Default value is 1.
--
--		@Separator		Optional. The character used to separate the timestamp,
--						@Location and @Message. If specified, this must be a 
--						single character. Default value is ASCII colon (':').
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether the messages should be displayed.
--						Since it is the purpose of this procedure to display
--						output, the default value is True (1). If the @Verbose
--						value is zero ("0") or NULL, this procedure will exit
--						IMMEDIATELY and no further processing will occur.
--						
--
--		hql.Print uses RAISERROR(...) WITH NOWAIT to send the message with no 
--		waiting. The immediately The message will be formatted as follows:
--
--			yyyy-mm-ddThh:mm:ss.nnnnn @Separator @Location @Separator @Message
--
--		For example, the follow T-SQL snippet executed at precisely one second
--		after midnight on Christmas Eve 2014...
--
--			declare @Msg nvarchar(max) = N'Santa just arrived';
--			declare @Loc nvarchar(128) = N'Our Chimney';
--			declare @Sep nchar(1) = N'!';
--			exec hql.Print @Msg, @Location = @Loc, @Separator = @Sep;
--	
--		...would produce the following output message:
--
--			2014-12-24T00:00:01.00000!Our Chimney!Santa just arrived
--
--		The timestamp at the beginning of the message cannot be disabled nor
--		can the format be changed.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.[Print]
    (
      @Message nVarchar(max) = null,		-- the text to be displayed
      @Severity int = 10,					-- error severity. 
      @State tinyInt = 1,					-- error state. 
      @Separator nChar(1) = N':',			-- field separator. 
      @Location nVarchar(128) = null,		-- location of error. 
      @Verbose bit = true					-- verbosity
    )
    with execute as caller
as
    begin

    -- if @Verbose is false, there is nothing to be done
        if @Verbose is null
            or @Verbose = 0
            return;

        if @Message is null
            or len(lTrim(rTrim(@Message))) = 0
            begin
                raiserror(32052, -1, -1, N'@Message');
                return;
            end;

        if @Severity is null
            set @Severity = 10;

        if @Severity not in ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 16 )
            begin
                raiserror(15021, -1, -1, N'@Severity');
                return;
            end;

        set @Location = coalesce(@Location, N'');

        if @State is null
            set @State = 1;

        set @Separator = coalesce(@Separator, N':');

        declare @FormattedMessage varchar(max) = replace(concat(lTrim(rTrim(convert(varchar(32), getDate(), 127))),
                                                                char(32), @Separator, char(32), lTrim(rTrim(@Location)),
                                                                char(32), @Separator, char(32), lTrim(rTrim(@Message))),
                                                         space(2), space(1));

        raiserror(@FormattedMessage, @Severity, @State) with noWait;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.Print';
go

grant execute on hql.[Print] to public;
go

-------------------------------------------------------------------------------
--=============================================================================

exec hql.[Print] 'Creating stored procedure...', @Location = N'[hql].[Report]';
go

-------------------------------------------------------------------------------
--=============================================================================

if object_Id('[hql].[Report]') is not null
    drop procedure hql.Report;
go

-------------------------------------------------------------------------------
--=============================================================================
--	hql.Report
--
--		Output a message to the standard output.
--
--		@Message		Required. The text that is to be displayed.
--
--		@Severity		Optional. The error severity for the message. If 
--						specified, the value must be 0-10 or 16. See MSDN article 
--						at https://msdn.microsoft.com/en-us/library/ms164086.aspx
--						for more information @Severity. For Severity values 0 to 
--						10, the database engine does not record an error. For 
--						a Severity value of 16, the database engine records an 
--						error, but execution of the caller is not terminated.
--						The default value is 10. 
--
--		@State			Optional. The error state for the message. If specified, 
--						this must be a legal value for RAISERROR (0 to 255). 
--						Default value is 1.
--
--		@Separator		Optional. The character used to separate the timestamp,
--						@Location and @Message. If specified, this must be a 
--						single character. Default value is ASCII colon (':').
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether the messages should be displayed.
--						Since it is the purpose of this procedure to display
--						output, the default value is True (1). If the @Verbose
--						value is zero ("0") or NULL, this procedure will exit
--						IMMEDIATELY and no further processing will occur.
--						
--
--		hql.Report uses RAISERROR(...) WITH NOWAIT to send the message with no 
--		waiting. The immediately The message will be formatted as follows:
--
--			yyyy-mm-ddThh:mm:ss.nnnnn @Separator @Location @Separator @Message
--
--		For example, the follow T-SQL snippet executed at precisely one second
--		after midnight on Christmas Eve 2014...
--
--			declare @Msg nvarchar(max) = N'Santa just arrived';
--			declare @Loc nvarchar(128) = N'Our Chimney';
--			declare @Sep nchar(1) = N'!';
--			exec hql.Report @Msg, @Location = @Loc, @Separator = @Sep;
--	
--		...would produce the following output message:
--
--			2014-12-24T00:00:01.00000!Our Chimney!Santa just arrived
--
--		The timestamp at the beginning of the message cannot be disabled nor
--		can the format be changed.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.Report
    (
      @Message nVarchar(max) = null,		-- the text to be displayed
      @Severity int = 10,					-- error severity. 
      @State tinyInt = 1,					-- error state. 
      @Separator nChar(1) = N':',			-- field separator. 
      @Location nVarchar(128) = null,		-- location of error. 
      @Verbose bit = true					-- verbosity
    )
    with execute as caller
as
    begin

        exec hql.[Print] @Message = @Message, @Severity = @Severity, @State = @State, @Separator = @Separator,
            @Location = @Location, @Verbose = @Verbose;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.Report';
go

grant execute on hql.Report to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating table...', @Location = N'[hql].[Settings]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[Settings]', 'U') is not null )
    drop table hql.Settings;
go

-------------------------------------------------------------------------------
--=============================================================================

create table hql.Settings
    (
      Name varchar(776) not null
                        constraint PK_Settings primary key,
      Value sql_Variant null
    );

go

--exec sys.sp_MS_marksystemobject N'hql.Settings';
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating function...', @Location = N'[hql].[GetOption]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[GetOption]', 'FN') is not null )
    drop function hql.GetOption;
go

-------------------------------------------------------------------------------
--=============================================================================
--	hql.GetOption
--
--		Get the value of a User Option by Name.
--
--		@OptionName		Required. The Name of the Option Flag to retrieve. See
--						https://msdn.microsoft.com/en-us/library/ms190763.aspx
--						for more info. Must be one of the following values. The
--						value is NOT case-sensitive.
--
--						-	disable_def_cnst_chk
--						-	implicit_transactions
--						-	cursor_close_on_commit'
--						-	ansi_warnings
--						-	ansi_padding
--						-	ansi_nulls
--						-	arithabort
--						-	arithignore
--						-	quoted_identifier
--						-	nocount
--						-	ansi_null_dflt_on
--						-	ansi_null_dflt_off
--						-	concat_null_yields_null
--						-	numeric_roundabort
--						-	xact_abort
--
--		Return Value	A bit value. If the option is on, the value is 1. If the
--						option is off, the value is 0. Required.
--
-------------------------------------------------------------------------------
--=============================================================================

create function hql.GetOption
    (
      @OptionName nVarchar(128)
    )
returns bit
    with execute as caller
as
    begin

        declare @OptionMask int
            = case lower(lTrim(rTrim(@OptionName)))
                when N'disable_def_cnst_chk' then 0x00000001 -- 1
                when N'implicit_transactions' then 0x00000002 -- 2
                when N'cursor_close_on_commit' then 0x00000004 -- 4
                when N'ansi_warnings' then 0x00000008 -- 8
                when N'ansi_padding' then 0x00000010 -- 16
                when N'ansi_nulls' then 0x00000020 -- 32
                when N'arithabort' then 0x00000040 -- 64
                when N'arithignore' then 0x00000080 -- 128
                when N'quoted_identifier' then 0x00000100 -- 256
                when N'nocount' then 0x00000200 -- 512
                when N'ansi_null_dflt_on' then 0x00000400 -- 1024
                when N'ansi_null_dflt_off' then 0x00000800 -- 2048
                when N'concat_null_yields_null' then 0x00001000 -- 4096
                when N'numeric_roundabort' then 0x00002000 -- 8192
                when N'xact_abort' then 0x00004000 -- 16384
                else 0
              end;

        return
        (
            case @OptionMask
                when 0 then 0
                else (@@OPTIONS & @OptionMask) / @OptionMask
            end
        );

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.GetOption';
go

grant execute on hql.GetOption to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating stored procedure...', @Location = N'[hql].[AddSetting]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[AddSetting]', 'P') is not null )
    drop procedure hql.AddSetting;
go

-------------------------------------------------------------------------------
--=============================================================================
--	hql.AddSetting
--
--		Add a Setting with a Value
--
--		@Name			Required. The Name of the Setting to be added.
--
--		@Value			Required. The Value of the Setting to be added.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.AddSetting
    (
      @Name nVarchar(776),
      @Value sql_Variant,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @Name is null
            or len(lTrim(rTrim(@Name))) = 0
            begin
                raiserror(32052, -1, -1, N'@Name');
                return;
            end;

        declare @NoCountValue bit = hql.GetOption(N'nocount');

        set noCount on;

        update
                hql.Settings
            set
                Value = @Value
            where
                Name = @Name;

        if @@ROWCOUNT = 0
            insert into hql.Settings
                    ( Name, Value )
                values
                    ( @Name, @Value );

    end;

    if @NoCountValue = 0
        set noCount off;

go

--exec sys.sp_MS_marksystemobject N'hql.AddSetting';
go

grant execute on hql.AddSetting to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating stored procedure...', @Location = N'[hql].[GetSetting]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[GetSetting]', 'P') is not null )
    drop procedure hql.GetSetting;
go

--=============================================================================
--	hql.GetSetting
--
--		Get the value of a Setting
--
--		@Name			Required. The Name of the Setting to be retrieved.
--
--		@Value			Required. Output. The retrieved Value of the Setting.
--						@Value must be a sql_variant. Afterwards, use CAST() 
--						or CONVERT() to get to the native value.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.GetSetting
    (
      @Name nVarchar(776),
      @Value sql_Variant output,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @Name is null
            or len(lTrim(rTrim(@Name))) = 0
            begin
                raiserror(32052, -1, -1, N'@Name');
                return;
            end;

        declare @NoCountValue bit = hql.GetOption(N'nocount');

        set noCount on;

        set @Value = null;

        select
                @Value = Value
            from
                #hqlSettings
            where
                Name = @Name;

        if @NoCountValue = 0
            set noCount off;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.GetSetting';
go

grant execute on hql.GetSetting to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating stored procedure...', @Location = N'[hql].[GetSettingBit]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[GetSettingBit]', 'P') is not null )
    drop procedure hql.GetSettingBit;
go

-------------------------------------------------------------------------------
--=============================================================================
--	hql.GetSettingBit
--
--		Get the value of a Setting as a bit
--
--		@Name			Required. The Name of the Setting to be retrieved.
--
--		@Value			Required. Output. The retrieved Value of the Setting.
--						@Value must be type bit or a compatible type. 
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.GetSettingBit
    (
      @Name nVarchar(776),
      @Value bit output,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @Name is null
            or len(lTrim(rTrim(@Name))) = 0
            begin
                raiserror(32052, -1, -1, N'@Name');
                return;
            end;

        declare @SqlVariantValue sql_Variant;

        exec hql.GetSetting @Name, @SqlVariantValue output, @Location = @Location, @Verbose = @Verbose;

        set @Value = convert(bit, @SqlVariantValue);
    
    end;

go

--exec sys.sp_MS_marksystemobject N'hql.GetSettingBit';
go

grant execute on hql.GetSettingBit to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating stored procedure...', @Location = N'[hql].[GetSettingTinyInt]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[GetSettingTinyInt]', 'P') is not null )
    drop procedure hql.GetSettingTinyInt;
go

-------------------------------------------------------------------------------
--=============================================================================
--	hql.GetSettingTinyInt
--
--		Get the value of a Setting as a tinyint
--
--		@Name			Required. The Name of the Setting to be retrieved.
--
--		@Value			Required. Output. The retrieved Value of the Setting.
--						@Value must be type tinyint or a compatible type. 
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.GetSettingTinyInt
    (
      @Name nVarchar(776),
      @Value tinyInt output,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @Name is null
            or len(lTrim(rTrim(@Name))) = 0
            begin
                raiserror(32052, -1, -1, N'@Name');
                return;
            end;

        declare @SqlVariantValue sql_Variant;

        exec hql.GetSetting @Name, @SqlVariantValue output, @Location = @Location, @Verbose = @Verbose;

        set @Value = convert(tinyInt, @SqlVariantValue);
    
    end;

go

--exec sys.sp_MS_marksystemobject N'hql.GetSettingTinyInt';
go

grant execute on hql.GetSettingTinyInt to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[CreateLoginFromWindows]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[CreateLoginFromWindows]', 'P') is not null )
    drop procedure hql.CreateLoginFromWindows;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[CreateLoginFromWindows]
--
--		Drop the specified table from the database.
--
--		@LoginName	
--						Required. The name of the Windows user for which a SQL 
--						Login should be created. If this Login already exists, 
--						then the operation is skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.CreateLoginFromWindows
    (
      @LoginName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        declare @LoginObjectName varchar(776) = parseName(@LoginName, 1);

        -- value must not be null or empty
        if @LoginObjectName is null
            or len(lTrim(rTrim(@LoginObjectName))) = 0
            begin
                raiserror(32052, -1, -1, N'@LoginName');
                return;
            end;

        -- must not be a multi-part name, e.g., '[x].[LoginName]'
        if parseName(@LoginName, 2) is not null
            or parseName(@LoginName, 3) is not null
            or parseName(@LoginName, 4) is not null
            begin
                raiserror(40616, -1, -1, @LoginName);
            end;

        set @LoginName = quoteName(@LoginObjectName);

        declare @Msg nVarchar(max) = N'CREATE LOGIN ' + @LoginName;

        declare @LoginExists bit = case when exists ( select
                                                            SP.name
                                                        from
                                                            sys.server_principals as SP
                                                        where
                                                            SP.name = @LoginObjectName ) then 1
                                        else 0
                                   end;

        if @LoginExists = 1
            begin
                set @Msg += N' skipped. Login already exists.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'CREATE LOGIN ' + @LoginName + N' FROM WINDOWS WITH DEFAULT_DATABASE=' + db_name() + ';';


        exec sp_executesql @stmt = @Sql;

    end;	

go
    
--exec sys.sp_MS_marksystemobject N'hql.CreateLoginFromWindows';
go

grant execute on hql.CreateLoginFromWindows to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[CreateUser]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[CreateUser]', 'P') is not null )
    drop procedure hql.CreateUser;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[CreateUser]
--
--		Drop the specified table from the database.
--
--		@UserName		Required. The name of the database user to be created.
--						If this User already exists, then the operation is 
--						skipped, but no error is reported.
--
--		@UserName		Required. The name of the Windows Login for which a SQL 
--						User should be created. If this Login does not exists, 
--						then an error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.CreateUser
    (
      @UserName nVarchar(776),
      @LoginName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        declare @UserObjectName varchar(776) = parseName(@UserName, 1);

        -- value must not be null or empty
        if @UserObjectName is null
            or len(lTrim(rTrim(@UserObjectName))) = 0
            begin
                raiserror(32052, -1, -1, N'@UserName');
                return;
            end;

        -- must not be a multi-part name, e.g., '[x].[UserName]'
        if parseName(@UserName, 2) is not null
            or parseName(@UserName, 3) is not null
            or parseName(@UserName, 4) is not null
            begin
                raiserror(40668, -1, -1, @UserName);
            end;

        set @UserName = quoteName(@UserObjectName);

        declare @LoginObjectName varchar(776) = parseName(@LoginName, 1);

        -- value must not be null or empty
        if @LoginObjectName is null
            or len(lTrim(rTrim(@LoginObjectName))) = 0
            begin
                raiserror(32052, -1, -1, N'@LoginName');
                return;
            end;

        -- must not be a multi-part name, e.g., '[x].[LoginName]'
        if parseName(@LoginName, 2) is not null
            or parseName(@LoginName, 3) is not null
            or parseName(@LoginName, 4) is not null
            begin
                raiserror(40616, -1, -1, @LoginName);
            end;

        set @LoginName = quoteName(@LoginObjectName);

        declare @Msg nVarchar(max) = N'CREATE USER ' + @UserName;

        declare @UserExists bit = case when exists ( select
                                                            DP.name
                                                        from
                                                            sys.database_principals as DP
                                                        where
                                                            DP.name = @UserObjectName ) then 1
                                       else 0
                                  end;

        if @UserExists = 1
            begin
                set @Msg += N' skipped. User already exists.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'CREATE USER ' + @UserName + N' FOR LOGIN' + @LoginName + N';';

        exec sp_executesql @stmt = @Sql;

    end;
go

--exec sys.sp_MS_marksystemobject N'hql.CreateUser';
go

grant execute on hql.CreateUser to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropAssembly]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropAssembly]', 'P') is not null )
    drop procedure hql.DropAssembly;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropAssembly]
--
--		Drop the specified Assembly from the database.
--
--		@AssemblyName	Required. The name of the assembly to be dropped. If 
--						the Assembly cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropAssembly
    (
      @AssemblyName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @AssemblyName is null
            or len(lTrim(rTrim(@AssemblyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@AssemblyName');
                return;
            end;

        declare @Msg varchar(max) = N'DROP ASSEMBLY ' + @AssemblyName;

        declare @AssemblyExists bit = 0;

        select
                @AssemblyExists = 1
            from
                sys.assemblies
            where
                name = parseName(@AssemblyName, 1);
        
        if @AssemblyExists = 0
            begin
                set @Msg += N' skipped. Assembly does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'DROP ASSEMBLY ' + @AssemblyName + N';';

        exec sp_executesql @stmt = @Sql;
        
    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropAssembly';
go

grant execute on hql.DropAssembly to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropColumn]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropColumn]', 'P') is not null )
    drop procedure hql.DropColumn;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropColumn]
--
--		Drop the specified column from the table.
--
--		@ColumnName		Required. The name of the columnto be dropped. If 
--						the column cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be prepended to any 
--						message displayed using [hql].[Print]. If omitted, 
--						the name of the procedure will be used.
--
--		@Verbose		Optional. A true/false flag - 1 or 0, respectively - 
--						indicating whether status messages should be 
--						displayed. If ommitted, the default value is true (1).
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropColumn
    (
      @ColumnName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @ColumnName is null
            or len(lTrim(rTrim(@ColumnName))) = 0
            begin
                raiserror(32052, -1, -1, N'@ColumnName');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP COLUMN ' + @ColumnName;

        declare @ColumnExists bit 
            = case when col_Length(parseName(@ColumnName, 2), parseName(@ColumnName, 1)) is not null then 1
                   else 0
              end;
        
        if @ColumnExists = 0
            begin
                set @Msg += N' skipped. Column does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'ALTER TABLE ' + parseName(@ColumnName, 2) + N' DROP COLUMN '
            + parseName(@ColumnName, 1) + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropColumn';
go

grant execute on hql.DropColumn to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropForeignKey]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropForeignKey]', 'P') is not null )
    drop procedure hql.DropForeignKey;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropForeignKey]
--
--		Drop the specified foreign key from the table.
--
--		@ForeignKeyName	Required. The name of the foreign key to be dropped. If 
--						the foreign key cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropForeignKey
    (
      @ForeignKeyName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @ForeignKeyName is null
            or len(lTrim(rTrim(@ForeignKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@ForeignKeyName');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP FOREIGN KEY ' + @ForeignKeyName;

        declare @ForeignKeyExists int = case when object_Id(@ForeignKeyName) is null then 0
                                             else 1
                                        end;

        if @ForeignKeyExists = 0
            begin
                set @Msg += N' skipped. Foreign Key does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @OwningTableName nVarchar(776);

        select
                @OwningTableName = schema_Name(fk.schema_id) + N'.' + object_Name(fk.parent_object_id)
            from
                sys.foreign_keys as fk
            where
                fk.object_id = object_Id(@ForeignKeyName);

        declare @Sql nVarchar(max) = N'ALTER TABLE ' + @OwningTableName + N' DROP CONSTRAINT '
            + parseName(@ForeignKeyName, 1) + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropForeignKey';
go

grant execute on hql.DropForeignKey to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropFunction]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropFunction]', 'P') is not null )
    drop procedure hql.DropFunction;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropFunction]
--
--		Drop the specified function from the database.
--
--		@FunctionName	Required. The name of the function to be dropped. If 
--						the function cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropFunction
    (
      @FunctionName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @FunctionName is null
            or len(lTrim(rTrim(@FunctionName))) = 0
            begin
                raiserror(32052, -1, -1, N'@FunctionName');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP FUNCTION ' + @FunctionName;

        declare @FunctionExists bit = case when objectProperty(object_Id(@FunctionName), N'IsScalarFunction') = 1
                                                or objectProperty(object_Id(@FunctionName), N'IsTableFunction') = 1
                                           then 1
                                           else 0
                                      end;


        if @FunctionExists = 0
            begin
                set @Msg += N' skipped. Function does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                    
        declare @Sql nVarchar(max) = N'DROP FUNCTION ' + @FunctionName + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropFunction';
go

grant execute on hql.DropFunction to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropIndex]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropIndex]', 'P') is not null )
    drop procedure hql.DropIndex;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropIndex]
--
--		Drop the specified index from the table.
--
--		@IndexName		Required. The name of the index to be dropped. If 
--						the index cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropIndex
    (
      @IndexName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @IndexName is null
            or len(lTrim(rTrim(@IndexName))) = 0
            begin
                raiserror(32052, -1, -1, N'@IndexName');
                return;
            end;

        declare @ParsedIndexName sysname = parseName(@IndexName, 1);

        declare @TableName nVarchar(776)
        = case when parseName(@IndexName, 3) is not null then parseName(@IndexName, 3) + N'.'
               else N''
          end + parseName(@IndexName, 2);

        declare @Msg nVarchar(max) = N'DROP INDEX ' + @ParsedIndexName + N' ON ' + @TableName;

        declare @TableObjectID int = object_Id(@TableName);

        declare @IndexExists bit 
            = case when @TableObjectID is null then 0
                   when exists ( select top ( 1 )
                                        1
                                    from
                                        sys.indexes
                                    where
                                        name = @ParsedIndexName
                                        and object_id = @TableObjectID ) then 1
                   else 0
              end;

        if @IndexExists = 0
            begin
                set @Msg += N' skipped. Index does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'DROP INDEX ' + @ParsedIndexName + N' ON ' + @TableName + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropIndex';
go

grant execute on hql.DropIndex to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropPrimaryKey]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropPrimaryKey]', 'P') is not null )
    drop procedure hql.DropPrimaryKey;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropPrimaryKey]
--
--		Drop the specified primary key from the database.
--
--		@PrimaryKeyName	Required. The name of the primary key to be dropped. If 
--						the primary key cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropPrimaryKey
    (
      @PrimaryKeyName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @PrimaryKeyName is null
            or len(lTrim(rTrim(@PrimaryKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@PrimaryKeyName');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP PRIMARY KEY ' + @PrimaryKeyName;

        declare @PrimaryKeyExists bit
            = case when object_Id(@PrimaryKeyName, N'PK') is not null then 1
                   else 0
              end;

        if @PrimaryKeyExists = 0
            begin
                set @Msg += N' skipped. Primary Key does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @OwningTableName nVarchar(776);

        select
                @OwningTableName = schema_Name(fk.schema_id) + N'.' + object_Name(fk.parent_object_id)
            from
                sys.foreign_keys as fk
            where
                fk.object_id = object_Id(@PrimaryKeyName);

        declare @Sql nVarchar(max) = N'ALTER TABLE ' + @OwningTableName + N' DROP CONSTRAINT '
            + parseName(@PrimaryKeyName, 1) + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropPrimaryKey';
go

grant execute on hql.DropPrimaryKey to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropProcedure]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropProcedure]', 'P') is not null )
    drop procedure hql.DropProcedure;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropProcedure]
--
--		Drop the specified procedure from the database.
--
--		@FunctionName	Required. The name of the procedure to be dropped. If 
--						the procedure cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropProcedure
    (
      @ProcedureName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @ProcedureName is null
            or len(lTrim(rTrim(@ProcedureName))) = 0
            begin
                raiserror(32052, -1, -1, N'@ProcedureName ');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP PROCEDURE ' + @ProcedureName;

        declare @ProcedureExists bit = isNull(objectProperty(object_Id(@ProcedureName), N'IsProcedure'), 0);

        if @ProcedureExists = 0
            begin
                set @Msg += N' skipped. Procedure does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @CorrectedProcedureName varchar(776)
    = case when left(parseName(@ProcedureName, 1), 1) = N'#' then parseName(@ProcedureName, 1)
           else @ProcedureName
      end;

        declare @Sql nVarchar(max) = N'DROP PROCEDURE ' + @CorrectedProcedureName + N';'; 

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropProcedure';
go

grant execute on hql.DropProcedure to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropSchema]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropSchema]', 'P') is not null )
    drop procedure hql.DropSchema;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropSchema]
--
--		Drop the specified table from the database.
--
--		@SchemaName		Required. The name of the database Schema to be dropped.
--						If this Schema already exists, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropSchema
    (
      @SchemaName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        declare @SchemaObjectName varchar(776) = parseName(@SchemaName, 1);

        -- value must not be null or empty
        if @SchemaObjectName is null
            or len(lTrim(rTrim(@SchemaObjectName))) = 0
            begin
                raiserror(32052, -1, -1, N'@SchemaName');
                return;
            end;

        -- must not be a multi-part name, e.g., '[x].[SchemaName]'
        if parseName(@SchemaName, 2) is not null
            or parseName(@SchemaName, 3) is not null
            or parseName(@SchemaName, 4) is not null
            begin
                raiserror(40668, -1, -1, @SchemaName);
            end;

        set @SchemaName = quoteName(@SchemaObjectName);

        declare @Msg nVarchar(max) = N'DROP  Schema ' + @SchemaName;

        declare @SchemaExists bit = case when exists ( select
                                                            DS.name
                                                        from
                                                            sys.schemas as DS
                                                        where
                                                            DS.name = @SchemaObjectName ) then 1
                                         else 0
                                    end;

        if @SchemaExists = 0
            begin
                set @Msg += N' skipped. Schema does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'DROP  Schema ' + @SchemaName + N';';

        exec sp_executesql @stmt = @Sql;

    end;
go

--exec sys.sp_MS_marksystemobject N'hql.DropSchema';
go

grant execute on hql.DropSchema to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropTable]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropTable]', 'P') is not null )
    drop procedure hql.DropTable;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropTable]
--
--		Drop the specified table from the database.
--
--		@FunctionName	Required. The name of the table to be dropped. If 
--						the table cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropTable
    (
      @TableName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @TableName is null
            or len(lTrim(rTrim(@TableName))) = 0
            begin
                raiserror(32052, -1, -1, N'@TableName');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP TABLE ' + @TableName;

        declare @TableObjectName varchar(775) 
    = case when left(parseName(@TableName, 1), 1) = N'#' then N'tempdb..' + parseName(@TableName, 1)
           else @TableName
      end;

        declare @TableExists bit = case when object_Id(@TableObjectName, N'U') is null then 0
                                        else 1
                                   end;

        if @TableExists = 0
            begin
                set @Msg += N' skipped. Table does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @CorrectedTableName nVarchar(776)
    = case when left(parseName(@TableName, 1), 1) = N'#' then parseName(@TableName, 1)
           else @TableName
      end;

        declare @Sql nVarchar(max) = N'DROP TABLE ' + @CorrectedTableName + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropTable';
go

grant execute on hql.DropTable to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropTrigger]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropTrigger]', 'P') is not null )
    drop procedure hql.DropTrigger;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropTrigger]
--
--		Drop the specified trigger from the database.
--
--		@FunctionName	Required. The name of the trigger to be dropped. If 
--						the table cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropTrigger
    (
      @TriggerName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @TriggerName is null
            or len(lTrim(rTrim(@TriggerName))) = 0
            begin
                raiserror(32052, -1, -1, N'@TriggerName');
                return;
            end;

        declare @Msg nVarchar(max) = N'DROP TRIGGER ' + @TriggerName;

        declare @TriggerExists bit
            = case when object_Id(@TriggerName, 'TR') is not null then 1
                   when object_Id(@TriggerName, 'TA') is not null then 1
                   else 0
              end;

        if @TriggerExists = 0
            begin
                set @Msg += N' skipped. Trigger does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'DROP TRIGGER ' + @TriggerName + ';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.DropTrigger';
go

grant execute on hql.DropTrigger to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[DropUser]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[DropUser]', 'P') is not null )
    drop procedure hql.DropUser;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[DropUser]
--
--		Drop the specified table from the database.
--
--		@UserName		Required. The name of the database user to be dropped.
--						If this User already exists, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.DropUser
    (
      @UserName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        declare @UserObjectName varchar(776) = parseName(@UserName, 1);

        -- value must not be null or empty
        if @UserObjectName is null
            or len(lTrim(rTrim(@UserObjectName))) = 0
            begin
                raiserror(32052, -1, -1, N'@UserName');
                return;
            end;

        -- must not be a multi-part name, e.g., '[x].[UserName]'
        if parseName(@UserName, 2) is not null
            or parseName(@UserName, 3) is not null
            or parseName(@UserName, 4) is not null
            begin
                raiserror(40668, -1, -1, @UserName);
            end;

        set @UserName = quoteName(@UserObjectName);

        declare @Msg nVarchar(max) = N'DROP  USER ' + @UserName;

        declare @UserExists bit = case when exists ( select
                                                            DP.name
                                                        from
                                                            sys.database_principals as DP
                                                        where
                                                            DP.name = @UserObjectName ) then 1
                                       else 0
                                  end;

        if @UserExists = 0
            begin
                set @Msg += N' skipped. User does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @Sql nVarchar(max) = N'DROP  USER ' + @UserName + N';';

        exec sp_executesql @stmt = @Sql;

    end;
go

--exec sys.sp_MS_marksystemobject N'hql.DropUser';
go

grant execute on hql.DropUser to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RebuildIndex]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RebuildIndex]', 'P') is not null )
    drop procedure hql.RebuildIndex;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RebuildIndex]
--
--		Rebuild the specified index(es) on the table.
--
--		@IndexName		Required. The name of the index to be rebuilt. If 
--						the index cannot be found, then the operation is 
--						skipped, but no error is reported. If ALL is supplied
--						as the index name, e.g., 'dbo.mytable.all', then all
--						indexes on the table will be rebuilt.
--
--		@FillFactor		Optional. If specified, the fill factor to be used when
--						rebuilding the index(es). If not specified, the T-SQL
--						default will be used.
--		
--		@Online			Optional. If specified, a value determining whether the 
--						rebuild will be done online or not. Yes = 1, No = 0 or
--						NULL. If not specified, the T-SQL default will be used.
--		
--		@SortInTempDB	Optional. If specified, a value determining whether the 
--						sorting will be done in tempdb or the current database.
--						Yes = 1, No = 0 or NULL. If not specified, the T-SQL 
--						default will be used.
--		
--		@StatisticsNoRecompute
--						Optional. If specified, a value determining whether the 
--						statistics for the index will be recomputed. Yes = 1, 
--						No = 0 or NULL. If not specified, the T-SQL default will 
--						be used.
--		
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RebuildIndex
    (
      @IndexName nVarchar(776),
      @FillFactor int = null,
      @Online bit = null,
      @SortInTempDB bit = null,
      @StatisticsNoRecompute bit = null,
      @Location nVarchar(128) = null,
      @Verbose bit = null

    )
    with execute as caller
as
    begin

        if @IndexName is null
            or len(lTrim(rTrim(@IndexName))) = 0
            begin
                raiserror(32052, -1, -1, N'@IndexName');
                return;
            end;

        declare @ParsedIndexName sysname = parseName(@IndexName, 1);

        declare @TableName nVarchar(776)
            = case when parseName(@IndexName, 3) is not null then parseName(@IndexName, 3) + N'.'
                   else N''
              end + parseName(@IndexName, 2);

        declare @TableObjectID int = object_Id(@TableName);

        declare @IndexExists bit 
            = case when @ParsedIndexName = N'all' then 1
                   when exists ( select top ( 1 )
                                        1
                                    from
                                        sys.indexes
                                    where
                                        object_id = @TableObjectID
                                        and @ParsedIndexName = name ) then 1
                   else 0
              end;

        declare @Msg nVarchar(max) = N'REBUILD INDEX ' + @ParsedIndexName + N' ON ' + @TableName;

        if @IndexExists = 0
            begin
                set @Msg += N' skipped. Index does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @WithClause nVarchar(max) = null;

        if @FillFactor is not null
            begin
                set @WithClause = case when @WithClause is null then N'with ('
                                       else @WithClause
                                  end + N'FILLFACTOR = ' + cast(@FillFactor as varchar(3));
            end;
        
        if @Online is not null
            begin
                set @WithClause = case when @WithClause is null then N'with ('
                                       else @WithClause + N', '
                                  end + N'ONLINE = ' + case @Online
                                                         when 1 then N'ON'
                                                         else N'OFF'
                                                       end;
            end;

        if @SortInTempDB is not null
            begin
                set @WithClause = case when @WithClause is null then N'with ('
                                       else @WithClause + N', '
                                  end + N'SORT_IN_TEMPDB = ' + case @SortInTempDB
                                                                 when 1 then N'ON'
                                                                 else N'OFF'
                                                               end;
            end;

        if @StatisticsNoRecompute is not null
            begin
                set @WithClause = case when @WithClause is null then N'with ('
                                       else @WithClause + N', '
                                  end + N'STATISTICS_NORECOMPUTE = ' + case @StatisticsNoRecompute
                                                                         when 1 then N'ON'
                                                                         else N'OFF'
                                                                       end;
            end;

        set @WithClause = case when @WithClause is null then N''
                               else @WithClause + N')'
                          end;
            
        declare @Sql nVarchar(max) = N'
                ALTER INDEX 
                    ' + @ParsedIndexName + N' 
                        ON ' + @TableName + N'
                        REBUILD ' + @WithClause + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RebuildIndex';
go

grant execute on hql.RebuildIndex to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameColumn]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameColumn]', 'P') is not null )
    drop procedure hql.RenameColumn;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameColumn]
--
--		Rename the specified column on the table.
--
--		@ColummName		Required. The name of the column to be renamed. If 
--						the column cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewColummName	Required. The new name of the column.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameColumn
    (
      @ColumnName nVarchar(776),
      @NewColumnName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @ColumnName is null
            or len(lTrim(rTrim(@ColumnName))) = 0
            begin
                raiserror(32052, -1, -1, N'@ColumnName');
                return;
            end;

        if @NewColumnName is null
            or len(lTrim(rTrim(@NewColumnName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewColumnName');
                return;
            end;

        declare @Msg nVarchar(max) = N'RENAME COLUMN ' + @ColumnName + N' TO ' + @NewColumnName;

        declare @ColumnExists bit 
            = case when col_Length(parseName(@ColumnName, 2), parseName(@ColumnName, 1)) is not null then 1
                   else 0
              end;
        
        if @ColumnExists = 0
            begin
                set @Msg += N' skipped. Column does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @ColumnName, @newname = @NewColumnName, @objtype = N'COLUMN';

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameColumn';
go

grant execute on hql.RenameColumn to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameDefaultConstraint]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameDefaultConstraint]', 'P') is not null )
    drop procedure hql.RenameDefaultConstraint;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameDefaultConstraint]
--
--		Rename the specified default constraint on the table.
--
--		@DefaultConstraintName		
--						Required. The name of the constraint to be renamed. If 
--						the constraint cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewDefaultConstraintName		
--						Required. The new name of the constraint. 
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameDefaultConstraint
    (
      @DefaultConstraintName nVarchar(776),
      @NewDefaultConstraintName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @DefaultConstraintName is null
            or len(lTrim(rTrim(@DefaultConstraintName))) = 0
            begin
                raiserror(32052, -1, -1, N'@DefaultConstraintName');
                return;
            end;

        if @NewDefaultConstraintName is null
            or len(lTrim(rTrim(@NewDefaultConstraintName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewDefaultConstraintName');
                return;
            end;

        declare @Msg nVarchar(max) = N'RENAME DEFAULT CONSTRAINT ' + @DefaultConstraintName + N' TO '
            + @NewDefaultConstraintName;

        declare @DefaultConstraintExists bit 
            = case when object_Id(@DefaultConstraintName, N'D') is not null then 1
                   else 0
              end;
        
        if @DefaultConstraintExists = 0
            begin
                set @Msg += ' skipped. Default Constraint does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @DefaultConstraintName, @newname = @NewDefaultConstraintName;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameDefaultConstraint';
go

grant execute on hql.RenameDefaultConstraint to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameForeignKey]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameForeignKey]', 'P') is not null )
    drop procedure hql.RenameForeignKey;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameForeignKey]
--
--		Rename the specified foreign key on the table.
--
--		@ForeignKeyName	Required. The name of the foreign key to be renamed. If 
--						the foreign key cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewForeignKeyName	
--						Required. The new name of the foreign key.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameForeignKey
    (
      @ForeignKeyName nVarchar(776),
      @NewForeignKeyName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @ForeignKeyName is null
            or len(lTrim(rTrim(@ForeignKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@ForeignKeyName');
                return;
            end;

        if @NewForeignKeyName is null
            or len(lTrim(rTrim(@NewForeignKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewForeignKeyName');
                return;
            end;

        declare @Msg nVarchar(max) = 'RENAME FOREIGN KEY ' + @ForeignKeyName + ' TO ' + @NewForeignKeyName;

        declare @ForeignKeyExists int 
            = case when object_Id(@ForeignKeyName) is not null then 1
                   else 0
              end;

        if @ForeignKeyExists = 0
            begin
                set @Msg += ' skipped. Foreign Key does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @ForeignKeyName, @newname = @NewForeignKeyName;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameForeignKey';
go

grant execute on hql.RenameForeignKey to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameIndex]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameIndex]', 'P') is not null )
    drop procedure hql.RenameIndex;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameIndex]
--
--		Rename the specified index on the table.
--
--		@IndexName		Required. The name of the index to be renamed. If 
--						the index cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewIndexName	Required. The name of the index to be renamed.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameIndex
    (
      @IndexName nVarchar(776),
      @NewIndexName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @IndexName is null
            or len(lTrim(rTrim(@IndexName))) = 0
            begin
                raiserror(32052, -1, -1, N'@IndexName');
                return;
            end;

        if @NewIndexName is null
            or len(lTrim(rTrim(@NewIndexName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewIndexName');
                return;
            end;

        declare @ParsedIndexName sysname = parseName(@IndexName, 1);

        declare @TableName sysname
            = case when parseName(@IndexName, 3) is not null then parseName(@IndexName, 3) + N'.'
                   else N''
              end + parseName(@IndexName, 2);

        declare @Msg nVarchar(max) = N'RENAME INDEX ' + @IndexName + N' TO ' + @NewIndexName;

        declare @TableObjectID int = object_Id(@TableName);

        declare @IndexExists bit 
            = case when @TableObjectID is null then 0
                   when exists ( select top ( 1 )
                                        1
                                    from
                                        sys.indexes
                                    where
                                        name = @ParsedIndexName
                                        and object_id = @TableObjectID ) then 1
                   else 0
              end;

        if @IndexExists = 0
            begin
                set @Msg += ' skipped. Index does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @IndexName, @newname = @NewIndexName, @objtype = 'INDEX';

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameIndex';
go

grant execute on hql.RenameIndex to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenamePrimaryKey]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenamePrimaryKey]', 'P') is not null )
    drop procedure hql.RenamePrimaryKey;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenamePrimaryKey]
--
--		Rename the specified primary key on the table.
--
--		@PrimaryKeyName	Required. The name of the primary key to be renamed. If 
--						the primary key cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewPrimaryKeyName	Required. The new name of the primary key. 
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenamePrimaryKey
    (
      @PrimaryKeyName nVarchar(776),
      @NewPrimaryKeyName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @PrimaryKeyName is null
            or len(lTrim(rTrim(@PrimaryKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@PrimaryKeyName');
                return;
            end;

        if @NewPrimaryKeyName is null
            or len(lTrim(rTrim(@NewPrimaryKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewPrimaryKeyName');
                return;
            end;

        declare @Msg nVarchar(max) = N'RENAME PRIMARY KEY ' + @PrimaryKeyName + N' TO ' + @NewPrimaryKeyName;

        declare @PrimaryKeyExists bit
            = case when object_Id(@PrimaryKeyName, 'PK') is not null then 1
                   else 0
              end;

        if @PrimaryKeyExists = 0
            begin
                set @Msg += ' skipped. PrimaryKey does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @PrimaryKeyName, @newname = @NewPrimaryKeyName;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenamePrimaryKey';
go

grant execute on hql.RenamePrimaryKey to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameTable]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameTable]', 'P') is not null )
    drop procedure hql.RenameTable;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameTable]
--
--		Rename the specified table.
--
--		@TableName		Required. The name of the table to be renamed. If 
--						the table cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewTableName	Required. The new name of the table.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameTable
    (
      @TableName nVarchar(776),
      @NewTableName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @TableName is null
            or len(lTrim(rTrim(@TableName))) = 0
            begin
                raiserror(32052, -1, -1, N'@TableName');
                return;
            end;

        if @NewTableName is null
            or len(lTrim(rTrim(@NewTableName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewTableName');
                return;
            end;

        declare @Msg nVarchar(max) = N'RENAME TABLE ' + @TableName + N' TO ' + @NewTableName;

        declare @TableObjectName nVarchar(776) 
    = case when left(parseName(@TableName, 1), 1) = N'#' then N'tempdb..' + parseName(@TableName, 1)
           else @TableName
      end;

        declare @TableExists bit 
            = isNull(objectProperty(object_Id(@TableObjectName), N'IsTable') - objectProperty(object_Id(@TableObjectName),
                                                                                              N'IsSystemTable'), 0);

        if @TableExists = 0
            begin
                set @Msg += N' skipped. Table does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @CorrectedTableName varchar(776)
            = case when left(parseName(@TableName, 1), 1) = '#' then parseName(@TableName, 1)
                   else @TableName
              end;

        exec sp_rename @objname = @CorrectedTableName, @newname = @NewTableName;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameTable';
go

grant execute on hql.RenameTable to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameTrigger]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameTrigger]', 'P') is not null )
    drop procedure hql.RenameTrigger;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameTrigger]
--
--		Rename the specified Trigger on the table.
--
--		@TriggerName	Required. The name of the trigger to be renamed. If 
--						the trigger cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewTriggerName	Required. The new name of the trigger. 
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameTrigger
    (
      @TriggerName nVarchar(776),
      @NewTriggerName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @TriggerName is null
            or len(lTrim(rTrim(@TriggerName))) = 0
            begin
                raiserror(32052, -1, -1, N'@TriggerName');
                return;
            end;

        if @NewTriggerName is null
            or len(lTrim(rTrim(@NewTriggerName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewTriggerName');
                return;
            end;

        declare @Msg nVarchar(max) = N'RENAME PRIMARY KEY ' + @TriggerName + N' TO ' + @NewTriggerName;

        declare @TriggerExists bit
            = case when object_Id(@TriggerName, 'TR') is not null then 1
                   when object_Id(@TriggerName, 'TA') is not null then 1
                   else 0
              end;

        if @TriggerExists = 0
            begin
                set @Msg += ' skipped. Trigger does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @TriggerName, @newname = @NewTriggerName;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameTrigger';
go

grant execute on hql.RenameTrigger to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[RenameUniqueKey]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[RenameUniqueKey]', 'P') is not null )
    drop procedure hql.RenameUniqueKey;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[RenameUniqueKey]
--
--		Rename the specified unique key on the table.
--
--		@UniqueKeyName	Required. The name of the unique key to be renamed. If 
--						the unique key cannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@NewUniqueKeyName	
--						Required. The new name of the unique key.
--
--		@Location		Optional. A string that will be prepended to any 
--						message displayed using [hql].[Print]. If omitted, 
--						the name of the unique key will be used.
--
--		@Verbose		Optional. A true/false flag - 1 or 0, respectively - 
--						indicating whether status messages should be 
--						displayed. If ommitted, the default value is true (1).
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.RenameUniqueKey
    (
      @UniqueKeyName nVarchar(776),
      @NewUniqueKeyName sysname,
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @UniqueKeyName is null
            or len(lTrim(rTrim(@UniqueKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@UniqueKeyName');
                return;
            end;

        if @NewUniqueKeyName is null
            or len(lTrim(rTrim(@NewUniqueKeyName))) = 0
            begin
                raiserror(32052, -1, -1, N'@NewUniqueKeyName');
                return;
            end;

        declare @Msg nVarchar(max) = N'RENAME UNIQUE KEY ' + @UniqueKeyName + N' TO ' + @NewUniqueKeyName;

        declare @UniqueKeyExists bit 
            = case when object_Id(@UniqueKeyName, N'UQ') is not null then 1
                   else 0
              end;

        if @UniqueKeyExists = 0
            begin
                set @Msg += ' skipped. Unique Key does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        exec sp_rename @objname = @UniqueKeyName, @newname = @NewUniqueKeyName;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.RenameUniqueKey';
go

grant execute on hql.RenameUniqueKey to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[TruncateTable]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[TruncateTable]', 'P') is not null )
    drop procedure hql.TruncateTable;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[TruncateTable]
--
--		Truncate the specified table.
--
--		@IndexName		Required. The name of the table to be truncated. If 
--						the tablecannot be found, then the operation is 
--						skipped, but no error is reported.
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.TruncateTable
    (
      @TableName nVarchar(776),
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        if @TableName is null
            or len(lTrim(rTrim(@TableName))) = 0
            begin
                raiserror(32052, -1, -1, N'@TableName');
                return;
            end;

        declare @Msg nVarchar(max) = N'TRUNCATE TABLE ' + @TableName;

        declare @TableObjectName nVarchar(776) 
            = case when left(parseName(@TableName, 1), 1) = N'#' then N'tempdb..' + parseName(@TableName, 1)
                   else @TableName
              end;

        declare @TableExists bit
            = case when object_Id(@TableObjectName) is not null then 1
                   else 0
              end;

        if @TableExists = 0
            begin
                set @Msg += N' skipped. Table does not exist.';
                exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;
                return;
            end;

        exec hql.[Print] @Msg, @Location = @Location, @Verbose = @Verbose;

        declare @CorrectedTableName varchar(776)
                = case when left(parseName(@TableName, 1), 1) = N'#' then parseName(@TableName, 1)
                       else @TableName
                  end;

        declare @Sql nVarchar(max) = N'TRUNCATE TABLE ' + @CorrectedTableName + N';';

        exec sp_executesql @stmt = @Sql;

    end;

go

--exec sys.sp_MS_marksystemobject N'hql.TruncateTable';
go

grant execute on hql.TruncateTable to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[ShowDuplicateIndexes]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[ShowDuplicateIndexes]', 'P') is not null )
    drop procedure hql.ShowDuplicateIndexes;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[ShowDuplicateIndexes]
--
--		Display a list of (potentially) duplicate indexes. 
--
--		@ObjectName		Optional. The name of the object for which duplicate
--						indexes will be displayed. If @ObjectName is NULL, 
--						duplicate indexes will be displayed for the 
--						entire database. If ommitted, the default value is NULL.
--
--		@UpdateUsage	Optional. A string containing either 'true' or 'false'
--						specifying that usage info should be updated before
--						reporting.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.ShowDuplicateIndexes
    (
      @ObjectName nVarchar(776) = null,
      @UpdateUsage bit = null
    )
    with execute as caller
as
    begin

        declare @ObjectID int;				-- The object id that takes up space  
        declare @Type character(2);			-- The object type.  
        declare @DbName sysname;
        declare @SchemaName sysname;
        declare @TableName sysname;
        declare @IndexName sysname;
        declare @ColumnName sysname;
        declare @IsDescendingKey bit;
        declare @IsIncludedColumn bit;

    /*  
    **  Check to see that @ObjectName is local.  
    */  

        if @ObjectName is not null
            begin
                select
                        @DbName = parseName(@ObjectName, 3);  
        
                if @DbName is not null
                    and @DbName <> db_Name()
                    begin
                        raiserror(15250,-1,-1);
                        return(1);
                    end;  
  
                if @DbName is null
                    select
                            @DbName = db_Name();
 
            /*  
            **  Try to find the object.  
            */  
                select
                        @ObjectID = object_id,
                        @Type = type
                    from
                        sys.objects
                    where
                        object_id = object_Id(@ObjectName);  
  
            -- Translate @ObjectID to internal-table for queue  
                if @Type = N'SQ'
                    select
                            @ObjectID = object_id
                        from
                            sys.internal_tables
                        where
                            parent_id = @ObjectID
                            and internal_type = 201; --ITT_ServiceQueue  
  
            /*  
            **  Does the object exist?  
            */  
                if @ObjectID is null
                    begin  
                        raiserror(15009,-1,-1,@ObjectName,@DbName);
                        return(1);
                    end;
  
            -- Is it a table, view or queue?  
                if @Type not in ( N'U ', N'S ', N'V ', N'SQ', N'IT' )
                    begin  
                        raiserror(15234,-1,-1);
                        return(1);
                    end;
            end;
  
    /*  
    **  Update usages procedure user specified to do so.  
    */  
  
        if @UpdateUsage = 1
            begin  
                if @ObjectName is null
                    begin
                        dbcc updateUsage(0) with no_Infomsgs;
                    end;
                else
                    begin
                        dbcc updateUsage(0,@ObjectName) with no_Infomsgs;
                    end;
                print N' ';
            end;
  
        set noCount on;
  
        -- get the index sizes

        exec hql.DropTable '#IndexSizeTable';

        select
                schema_Name(t.schema_id) as SchemaName,
                object_Name(t.object_id) as TableName,
                coalesce(i.name, '<heap>') as IndexName,
                cast(8 * sum(a.used_pages) / 1024.0 as decimal(20, 1)) as [IndexSize(MB)]
            into
                #IndexSizeTable
            from
                sys.tables as t
                inner join sys.schemas as s
                    on s.schema_id = t.schema_id
                inner join sys.indexes as i
                    on t.object_id = i.object_id
                inner join sys.partitions as p
                    on i.object_id = p.object_id
                       and i.index_id = p.index_id
                inner join sys.allocation_units as a
                    on p.partition_id = a.container_id
            where
                i.type > 0
                and t.is_ms_shipped = 0
                and i.object_id > 255 
                --  
                --  If @ObjectID is null, then we want all tables in the current database
                --  
                and t.object_id = isNull(@ObjectID, t.object_id)
            group by
                t.schema_id,
                t.object_id,
                i.name;
                                                
         --get important properties of indexes

        exec hql.DropTable '#Helpindex';

        select
                schema_Name(t.schema_id) as SchemaName,
                t.name as TableName,
                ix.name as IndexName,
                cast('' as varchar(max)) as IndexColumns,
                cast('' as varchar(max)) as IncludedColumns,
                ix.is_unique,
                ix.type_desc,
                ix.fill_factor as Fill_Factor,
                ix.is_disabled,
                da.name as data_space,
                ix.is_padded,
                ix.allow_page_locks,
                ix.allow_row_locks,
                indexProperty(t.object_id, ix.name, 'IsAutoStatistics') as IsAutoStatistics,
                ix.ignore_dup_key
            into
                #HelpIndex
            from
                sys.tables as t
                inner join sys.indexes as ix
                    on t.object_id = ix.object_id
                inner join sys.data_spaces as da
                    on da.data_space_id = ix.data_space_id
            where
                ix.type > 0
                and t.is_ms_shipped = 0
                and ix.object_id > 255 
                --  
                --  If @ObjectID is null, then we want all tables in the current database
                --  
                and t.object_id = isNull(@ObjectID, t.object_id)
            order by
                SchemaName,
                TableName,
                IndexName;

    ---get the index keys and included columns

        declare CursorIndex cursor
        for
            select
                    schema_Name(t.schema_id) as schema_name,
                    t.name,
                    ix.name
                from
                    sys.tables as t
                    inner join sys.indexes as ix
                        on t.object_id = ix.object_id
                where
                    ix.type > 0
                    and t.is_ms_shipped = 0
                    and ix.object_id > 255
                    and t.object_id = isNull(@ObjectID, t.object_id)
                order by
                    schema_Name(t.schema_id),
                    t.name,
                    ix.name;

        open CursorIndex;

        fetch next from CursorIndex into @SchemaName, @TableName, @IndexName;

        while ( @@FETCH_STATUS = 0 )
            begin
        
                declare @IndexColumns varchar(max);
                declare @IncludedColumns varchar(max);
        
                select
                        @IndexColumns = '',
                        @IncludedColumns = '';

                declare CursorIndexColumn cursor
                for
                    select
                            col.name,
                            ixc.is_descending_key,
                            ixc.is_included_column
                        from
                            sys.tables as tb
                            inner join sys.indexes as ix
                                on tb.object_id = ix.object_id
                            inner join sys.index_columns as ixc
                                on ix.object_id = ixc.object_id
                                   and ix.index_id = ixc.index_id
                            inner join sys.columns as col
                                on ixc.object_id = col.object_id
                                   and ixc.column_id = col.column_id
                        where
                            ix.type > 0
                            and tb.is_ms_shipped = 0
                            and ix.object_id > 255
                            and schema_Name(tb.schema_id) = @SchemaName
                            and tb.name = @TableName
                            and ix.name = @IndexName
                            and tb.object_id = isNull(@ObjectID, tb.object_id)
                        order by
                            ixc.index_column_id;

                open CursorIndexColumn;

                fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn;

                while ( @@FETCH_STATUS = 0 )
                    begin

                        if @IsIncludedColumn = 0
                            set @IndexColumns += @ColumnName + ', '; 
                        else
                            set @IncludedColumns += @ColumnName + ', ';
     
                        fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn;

                    end;
         
                close CursorIndexColumn;

                deallocate CursorIndexColumn;

                select
                        @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns) - 1),
                        @IncludedColumns = case when len(@IncludedColumns) > 0
                                                then substring(@IncludedColumns, 1, len(@IncludedColumns) - 1)
                                                else ''
                                           end;

                update
                        #HelpIndex
                    set
                        IndexColumns = @IndexColumns,
                        IncludedColumns = @IncludedColumns
                    where
                        SchemaName = @SchemaName
                        and TableName = @TableName
                        and IndexName = @IndexName;
 
                fetch next from CursorIndex into @SchemaName, @TableName, @IndexName;

            end;

        close CursorIndex;

        deallocate CursorIndex;
        

    --show the results

        with    IndexesCTE
                  as (
                       select
                            s.name as SchemaName,
                            o.name as TableName,
                            i.name as IndexName,
                            index_Col(s.name + '.' + o.name, i.index_id, 1) as KeyCol1,
                            index_Col(s.name + '.' + o.name, i.index_id, 2) as KeyCol2,
                            index_Col(s.name + '.' + o.name, i.index_id, 3) as KeyCol3,
                            index_Col(s.name + '.' + o.name, i.index_id, 4) as KeyCol4,
                            index_Col(s.name + '.' + o.name, i.index_id, 5) as KeyCol5,
                            index_Col(s.name + '.' + o.name, i.index_id, 6) as KeyCol6,
                            index_Col(s.name + '.' + o.name, i.index_id, 7) as KeyCol7,
                            index_Col(s.name + '.' + o.name, i.index_id, 8) as KeyCol8,
                            index_Col(s.name + '.' + o.name, i.index_id, 9) as KeyCol9,
                            index_Col(s.name + '.' + o.name, i.index_id, 10) as KeyCol10,
                            index_Col(s.name + '.' + o.name, i.index_id, 11) as KeyCol11,
                            index_Col(s.name + '.' + o.name, i.index_id, 12) as KeyCol12,
                            index_Col(s.name + '.' + o.name, i.index_id, 13) as KeyCol13,
                            index_Col(s.name + '.' + o.name, i.index_id, 14) as KeyCol14,
                            index_Col(s.name + '.' + o.name, i.index_id, 15) as KeyCol15,
                            index_Col(s.name + '.' + o.name, i.index_id, 16) as KeyCol16
                        from
                            sys.indexes as i
                            inner join sys.objects as o
                                on i.object_id = o.object_id
                            inner join sys.schemas as s
                                on s.schema_id = o.schema_id
                        where
                            i.index_id > 0
                     )
            select
                    hi.SchemaName,
                    hi.TableName,
                    hi.IndexName,
                    idup.IndexName,
                    ixs.[IndexSize(MB)],
                    hi.is_unique,
                    hi.is_disabled,
                    hi.IndexColumns,
                    hi.IncludedColumns,
                    hi.data_space
                from
                    #HelpIndex as hi
                    inner join #IndexSizeTable as ixs
                        on hi.SchemaName = ixs.SchemaName
                           and hi.TableName = ixs.TableName
                           and hi.IndexName = ixs.IndexName
                    inner join IndexesCTE as i
                        on hi.SchemaName = i.SchemaName
                           and hi.TableName = i.TableName
                           and hi.IndexName = i.IndexName
                    inner join IndexesCTE as idup
                        on i.SchemaName = idup.SchemaName
                           and i.TableName = idup.TableName
                           and i.IndexName <> idup.IndexName
                           and i.KeyCol1 = idup.KeyCol1
                           and (
                                 i.KeyCol2 is null
                                 or idup.KeyCol2 is null
                                 or i.KeyCol2 = idup.KeyCol2
                               )
                           and (
                                 i.KeyCol3 is null
                                 or idup.KeyCol3 is null
                                 or i.KeyCol3 = idup.KeyCol3
                               )
                           and (
                                 i.KeyCol4 is null
                                 or idup.KeyCol4 is null
                                 or i.KeyCol4 = idup.KeyCol4
                               )
                           and (
                                 i.KeyCol5 is null
                                 or idup.KeyCol5 is null
                                 or i.KeyCol5 = idup.KeyCol5
                               )
                           and (
                                 i.KeyCol6 is null
                                 or idup.KeyCol6 is null
                                 or i.KeyCol6 = idup.KeyCol6
                               )
                           and (
                                 i.KeyCol7 is null
                                 or idup.KeyCol7 is null
                                 or i.KeyCol7 = idup.KeyCol7
                               )
                           and (
                                 i.KeyCol8 is null
                                 or idup.KeyCol8 is null
                                 or i.KeyCol8 = idup.KeyCol8
                               )
                           and (
                                 i.KeyCol9 is null
                                 or idup.KeyCol9 is null
                                 or i.KeyCol9 = idup.KeyCol9
                               )
                           and (
                                 i.KeyCol10 is null
                                 or idup.KeyCol10 is null
                                 or i.KeyCol10 = idup.KeyCol10
                               )
                           and (
                                 i.KeyCol11 is null
                                 or idup.KeyCol11 is null
                                 or i.KeyCol11 = idup.KeyCol11
                               )
                           and (
                                 i.KeyCol12 is null
                                 or idup.KeyCol12 is null
                                 or i.KeyCol12 = idup.KeyCol12
                               )
                           and (
                                 i.KeyCol13 is null
                                 or idup.KeyCol13 is null
                                 or i.KeyCol13 = idup.KeyCol13
                               )
                           and (
                                 i.KeyCol14 is null
                                 or idup.KeyCol14 is null
                                 or i.KeyCol14 = idup.KeyCol14
                               )
                           and (
                                 i.KeyCol15 is null
                                 or idup.KeyCol15 is null
                                 or i.KeyCol15 = idup.KeyCol15
                               )
                           and (
                                 i.KeyCol16 is null
                                 or idup.KeyCol16 is null
                                 or i.KeyCol16 = idup.KeyCol16
                               )
                order by
                    hi.SchemaName,
                    hi.TableName,
                    hi.IndexColumns,
                    hi.IncludedColumns;

        exec hql.DropTable '#helpindex';

        exec hql.DropTable '#IndexSizeTable';


        set noCount off;
        
        return(0);
    end;

go

--exec sys.sp_MS_marksystemobject N'hql.ShowDuplicateIndexes';
go

grant execute on hql.ShowDuplicateIndexes to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[ShowSpaceUsed]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[ShowSpaceUsed]', 'P') is not null )
    drop procedure hql.ShowSpaceUsed;
go

-------------------------------------------------------------------------------
--=============================================================================

-- TODO: Can this be handled at run-time?

--if serverproperty(N'productversion') < N'11'
--	begin
--		exec [hql].[Print]
--			N'This hql tool requires SQL Server 2012 or later.',
--			16,
--			1,
--			@Location = N'[hql].[ShowSpaceUsed]';
--		return;
--	end;

--go 

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[ShowSpaceUsed]
--
--		Display the space used by the database or an object within the database.
--		This is a revised version of sp_spaceused that ships with SQL Server.
--		The SELECT output has been tailored a bit. The information is also
--		displayed on the standard output.
--
--		@ObjectName		Optional. The name of the object that we want size on.
--						If @ObjectName is NULL, space usage is give for the 
--						entire database. If ommitted, the default value is NULL.
--
--		@UpdateUsage	Optional. A string containing either 'true' or 'false'
--						specifying that usage info should be updated before
--						reporting.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.ShowSpaceUsed
    (
      @ObjectName nVarchar(776) = null,
      @UpdateUsage bit = null
    )
    with execute as caller
as
    begin

        declare
            @id int             -- The object id that takes up space  
            ,
            @type character(2)    -- The object type.  
            ,
            @pages bigInt          -- Working variable for size calc.  
            ,
            @dbname sysname,
            @dbsize bigInt,
            @logsize bigInt,
            @msg nVarchar(max),
            @reservedpages bigInt,
            @usedpages bigInt,
            @rowCount bigInt;
    
        declare @OneKB decimal(18, 3) = 1024.0;
    
        declare @EightKB decimal(18, 3) = 8 * @OneKB;
    
        declare @OneMB decimal(18, 3) = @OneKB * @OneKB;
    
        declare @OneGB decimal(18, 3) = @OneKB * @OneKB * @OneKB;
    
        declare @NumberFormat nChar(2) = N'N3';

    /*  
    **  Check to see that the objname is local.  
    */  

        if @ObjectName is not null
            begin
                select
                        @dbname = parseName(@ObjectName, 3);  
        
                if @dbname is not null
                    and @dbname <> db_Name()
                    begin
                        raiserror(15250,-1,-1);
                        return(1);
                    end;  
  
                if @dbname is null
                    select
                            @dbname = db_Name();
 
            /*  
            **  Try to find the object.  
            */  
                select
                        @id = object_id,
                        @type = type
                    from
                        sys.objects
                    where
                        object_id = object_Id(@ObjectName);  
  
            -- Translate @id to internal-table for queue  
                if @type = N'SQ'
                    select
                            @id = object_id
                        from
                            sys.internal_tables
                        where
                            parent_id = @id
                            and internal_type = 201; --ITT_ServiceQueue  
  
            /*  
            **  Does the object exist?  
            */  
                if @id is null
                    begin  
                        raiserror(15009,-1,-1,@ObjectName,@dbname);
                        return(1);
                    end;
  
            -- Is it a table, view or queue?  
                if @type not in ( N'U ', N'S ', N'V ', N'SQ', N'IT' )
                    begin  
                        raiserror(15234,-1,-1);
                        return(1);
                    end;
            end;
  
    /*  
    **  Update usages procedure user specified to do so.  
    */  
  
        if @UpdateUsage = 1
            begin  
                if @ObjectName is null
                    begin
                        dbcc updateUsage(0) with no_Infomsgs;
                    end;
                else
                    begin
                        dbcc updateUsage(0,@ObjectName) with no_Infomsgs;
                    end;
                print N' ';
            end;
  
        set noCount on;
  
    /*  
    **  If @id is null, then we want summary data.  
    */  
        if @id is null
            begin  
                select
                        @dbsize = sum(convert(bigInt, case when status & 64 = 0 then size
                                                           else 0
                                                      end)),
                        @logsize = sum(convert(bigInt, case when status & 64 <> 0 then size
                                                            else 0
                                                       end))
                    from
                        dbo.sysfiles;
  
                select
                        @reservedpages = sum(a.total_pages),
                        @usedpages = sum(a.used_pages),
                        @pages = sum(case
                            -- XML-Index and FT-Index and semantic index internal tables are not considered "data", but is part of "index_size" 
                                          when it.internal_type in ( 202, 204, 207, 211, 212, 213, 214, 215, 216, 221,
                                                                     222, 236 ) then 0
                                          when a.type <> 1
                                               and p.index_id < 2 then a.used_pages
                                          when p.index_id < 2 then a.data_pages
                                          else 0
                                     end)
                    from
                        sys.partitions as p
                        join sys.allocation_units as a
                            on p.partition_id = a.container_id
                        left join sys.internal_tables as it
                            on p.object_id = it.object_id; 
  
            /* unallocated space could not be negative */
                select
                        server_name = lower(@@SERVERNAME),
                        database_name = db_Name(),
                        N'total_size_gb' = format(( @dbsize + @logsize ) * @EightKB / @OneGB, @NumberFormat),
                        N'db_size_gb' = format(@dbsize * @EightKB / @OneGB, @NumberFormat),
                        N'reserved_gb' = lTrim(format(@reservedpages * @EightKB / @OneGB, @NumberFormat)),
                        N'data_gb' = lTrim(format(@pages * @EightKB / @OneGB, @NumberFormat)),
                        N'index_size_gb' = lTrim(format(( @usedpages - @pages ) * @EightKB / @OneGB, @NumberFormat)),
                        N'unused_gb' = lTrim(format(( @reservedpages - @usedpages ) * @EightKB / @OneGB, @NumberFormat)),
                        N'unallocated_space_gb' = format(( case when @dbsize >= @reservedpages
                                                                then ( @dbsize - @reservedpages ) * @EightKB / @OneGB
                                                                else 0
                                                           end ), @NumberFormat),
                        N'log_size_gb' = format(@logsize * @EightKB / @OneGB, @NumberFormat);
  
                set @msg = N'The database, ' + db_Name() + N' on ' + lower(@@SERVERNAME) + N', occupies '
                    + format(( @dbsize + @logsize ) * @EightKB / @OneGB, @NumberFormat) + N' GB of disk space.';
                print @msg;

                set @msg = N'The total storage consists of ' + format(@dbsize * @EightKB / @OneGB, @NumberFormat)
                    + N' GB in database (.mdf) files and ' + format(@logsize * @EightKB / @OneGB, @NumberFormat)
                    + N' GB in log (.ldf) files.';
                print @msg;

                set @msg = N'The database files contain ' + format(@reservedpages * @EightKB / @OneGB, @NumberFormat)
                    + N' GB of allocated space and '
                    + format(( case when @dbsize >= @reservedpages
                                    then ( cast(@dbsize as bigInt) - @reservedpages ) * @EightKB / @OneGB
                                    else 0
                               end ), @NumberFormat) + N' GB of unallocated free space.';
                print @msg;

                set @msg = N'The reserved space is made up of ' + format(@pages * @EightKB / @OneGB, @NumberFormat)
                    + N' GB of data such as table, ' + format(( @usedpages - @pages ) * @EightKB / @OneGB, @NumberFormat)
                    + N' GB of indexes, and ' + format(( @reservedpages - @usedpages ) * @EightKB / @OneGB,
                                                       @NumberFormat) + N' GB of unused space.';

                print @msg;

            end;
  
        else  
        /*  
        **  We want a particular object.  
        */
            begin  
            /*  
            ** Now calculate the summary data.   
            *  Note that LOB Data and Row-overflow Data are counted as Data Pages for the base table  
            *  For non-clustered indices they are counted towards the index pages  
            */  
                select
                        @reservedpages = sum(reserved_page_count),
                        @usedpages = sum(used_page_count),
                        @pages = sum(case when ( index_id < 2 )
                                          then ( in_row_data_page_count + lob_used_page_count
                                                 + row_overflow_used_page_count )
                                          else 0
                                     end),
                        @rowCount = sum(case when ( index_id < 2 ) then row_count
                                             else 0
                                        end)
                    from
                        sys.dm_db_partition_stats
                    where
                        object_id = @id;  
  
            /*  
            ** Check procedure table has XML Indexes or Fulltext Indexes which use internal tables tied to this table  
            */  
                if exists ( select top ( 1 )
                                    1 
                        --count(*)
                                from
                                    sys.internal_tables
                                where
                                    parent_id = @id
                                    and internal_type in ( 202, 204, 207, 211, 212, 213, 214, 215, 216, 221, 222, 236 ) )
                    begin  
                    /*  
                    **  Now calculate the summary data. Row counts in these internal tables don't   
                    **  contribute towards row count of original table.  
                    */  
                        select
                                @reservedpages = @reservedpages + sum(reserved_page_count),
                                @usedpages = @usedpages + sum(used_page_count)
                            from
                                sys.dm_db_partition_stats as p,
                                sys.internal_tables as it
                            where
                                it.parent_id = @id
                                and it.internal_type in ( 202, 204, 207, 211, 212, 213, 214, 215, 216, 221, 222, 236 )
                                and p.object_id = it.object_id;  
                    end;
  
                select
                        name = object_Name(@id),
                        rows = format(@rowCount, 'N0'),
                        N'reserved_gb' = lTrim(format(@reservedpages * @EightKB / @OneGB, @NumberFormat)),
                        N'data_gb' = lTrim(format(@pages * @EightKB / @OneGB, @NumberFormat)),
                        N'index_size_gb' = lTrim(format(( case when @usedpages > @pages then ( @usedpages - @pages )
                                                               else 0
                                                          end ) * @EightKB / @OneGB, @NumberFormat)),
                        N'unused_gb' = lTrim(format(( case when @reservedpages > @usedpages
                                                           then ( @reservedpages - @usedpages )
                                                           else 0
                                                      end ) * @EightKB / @OneGB, @NumberFormat));
            end;
    
        return(0);
    end;

go

--exec sys.sp_MS_marksystemobject N'hql.ShowSpaceUsed';
go

grant execute on hql.ShowSpaceUsed to public;
go

-------------------------------------------------------------------------------
--=============================================================================

execute hql.[Print] 'Creating procedure...', @Location = N'[hql].[Uninstall]';
go

-------------------------------------------------------------------------------
--=============================================================================

if ( object_Id('[hql].[Uninstall]', 'P') is not null )
    drop procedure hql.Uninstall;
go

-------------------------------------------------------------------------------
--=============================================================================
--	[hql].[Uninstall]
--
--		Remove the hql tools, a set of SQL Server objects that are useful in 
--		database deployment and maintenance scripts. 
--
--		@Location		Optional. A string that will be inserted into any 
--						messages that are displayed. Default is empty string. 
--
--		@Verbose		Optional. A bit value where True = 1, False = 0. 
--						Indicates whether status messages should be displayed
--						displayed. Default is False.
--
-------------------------------------------------------------------------------
--=============================================================================

create procedure hql.Uninstall
    (
      @Location nVarchar(128) = null,
      @Verbose bit = null
    )
    with execute as caller
as
    begin

        -------------------------------------------------------------------------------
        --	hqlSettings Stored Procs
        -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.AddSetting', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.AddSetting', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.GetSetting', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.GetSetting', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.GetSettingBit', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.GetSettingBit', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.GetSettingTinyInt', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.GetSettingTinyInt', @Location = @Location;

    -------------------------------------------------------------------------------
    --	hqlSettings Table
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping table...', @Location = N'hql.Settings', @Verbose = @Verbose;
        exec hql.DropTable N'hql.Settings', @Location = @Location;

    -------------------------------------------------------------------------------
    --	hql procedures
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.CreateLoginFromWindows', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.CreateLoginFromWindows', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.CreateUser', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.CreateUser', @Location = @Location;


        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropAssembly', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropAssembly', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropColumn', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropColumn', @Location = @Location;
        
        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropForeignKey', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropForeignKey', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropIndex', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropIndex', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropPrimaryKey', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropPrimaryKey', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropSchema', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropSchema', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropTable', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropTable', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropTrigger', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropTrigger', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropUser', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropUser', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RebuildIndex', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RebuildIndex', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameColumn', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameColumn', @Location = @Location;
        
        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameDefaultConstraint', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameDefaultConstraint', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameForeignKey', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameForeignKey', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameIndex', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameIndex', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenamePrimaryKey', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenamePrimaryKey', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameTable', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameTable', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameForeignKey', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameTrigger', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.RenameUniqueKey', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.RenameUniqueKey', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.TruncateTable', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.TruncateTable', @Location = @Location;

    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.ShowDuplicateIndexes', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.ShowDuplicateIndexes', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.ShowSpaceUsed', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.ShowSpaceUsed', @Location = @Location;

    -------------------------------------------------------------------------------
    --	hql Functions
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping function...', @Location = N'hql.GetOption', @Verbose = @Verbose;
        exec hql.DropFunction 'hql.GetOption', @Location = @Location;

    -------------------------------------------------------------------------------
    --	hql features being used in this script, but no longer needed
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.DropFunction', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropFunction', @Location = @Location;

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.ShowSpaceUsed', @Verbose = @Verbose;
        exec hql.DropProcedure N'hql.DropProcedure', @Location = @Location;

    -------------------------------------------------------------------------------
    --	hql.Uninstall -- this procedure...
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.Uninstall', @Verbose = @Verbose;

        if object_Id(N'hql.Uninstall', N'P') is not null
            drop procedure hql.Uninstall;

    -------------------------------------------------------------------------------
    --	hql.Report -- in use here, but we can no longer delay the inevitable...
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.Report', @Verbose = @Verbose;

        if object_Id(N'hql.Report', N'P') is not null
            drop procedure hql.Report;

    -------------------------------------------------------------------------------
    --	hql.Print -- in use here, but we can no longer delay the inevitable...
    -------------------------------------------------------------------------------

        exec hql.[Print] N'Dropping procedure...', @Location = N'hql.Print', @Verbose = @Verbose;

        if object_Id(N'hql.Print', N'P') is not null
            drop procedure hql.[Print];

    -------------------------------------------------------------------------------
    --	hql -- the schema... the last remnant. ;)
    -------------------------------------------------------------------------------
        if exists ( select
                            1
                        from
                            sys.schemas
                        where
                            name = 'hql' )
            begin
                declare @FormattedMessage nVarchar(max) 
                        = replace(concat(lTrim(rTrim(convert(varchar(32), getDate(), 127))), ' : hql : ',
                                         'Dropping schema...'), space(2), space(1));
                raiserror(@FormattedMessage, 10, 1) with noWait;
                drop schema hql; 
            end;
    end;

go

--exec sys.sp_MS_marksystemobject N'hql.Uninstall';
go

grant execute on hql.Uninstall to public;
go

