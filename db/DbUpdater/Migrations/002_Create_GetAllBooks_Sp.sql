create or alter procedure dbo.GetAllBooks
@sortBy as varchar(10)
as

if(@sortBy = 'author')
Begin
SELECT * FROM dbo.Books
ORDER BY AuthorLastName, AuthorFirstName, Title
End
Else
Begin
SELECT * FROM dbo.Books
ORDER BY Publisher, AuthorLastName, AuthorFirstName, Title
End


go
