CREATE TABLE [dbo].Books
(
    [BookId] int identity,
    [Publisher] NVARCHAR(500) NOT NULL,
    [Title] NVARCHAR(500) NOT NULL,
    [AuthorLastName] NVARCHAR(500) NOT NULL,
    [AuthorFirstName] NVARCHAR(500) NOT NULL,
    [Container] NVARCHAR(500) NULL,
    [PublicationDate] NVARCHAR(500) NULL,
    [Location] NVARCHAR(500) NULL,
    [IssueNo] NVARCHAR(500) NULL,
    [VolumeNo] NVARCHAR(500) NULL,
    [Url] NVARCHAR(500) NULL,
    [Price] decimal(18, 2) NOT NULL,

    CONSTRAINT PK_Books PRIMARY KEY ([BookId])
)
GO

