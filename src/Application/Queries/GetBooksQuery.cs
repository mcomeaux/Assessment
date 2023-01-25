using MediatR;
using Assessment.Application.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Assessment.Application.Queries
{
    public class GetBooksQuery
    {
        public class Command : IRequest<List<Entities.Book>>
        {
            public string SortBy { get; set; }
        }

        public class CommandHandler : IRequestHandler<Command, List<Entities.Book>>
        {
            private readonly IApplicationDbContext _dbContext;


            public CommandHandler(IApplicationDbContext dbContext)
            {
                _dbContext = dbContext;
            }

            public async Task<List<Entities.Book>> Handle(Command request, CancellationToken cancellationToken)
            {
                
                List<Entities.Book> books;
                
                if (request.SortBy == "author")
                {
                    books = await _dbContext.Books
                        .OrderBy(c => c.AuthorLastName)
                        .ThenBy(c => c.AuthorFirstName)
                        .ThenBy(c => c.Title)
                        .ToListAsync();
                }
                else
                {
                    books = await _dbContext.Books
                        .OrderBy(c => c.Publisher)
                        .ThenBy(c => c.AuthorLastName)
                        .ThenBy(c => c.AuthorFirstName)
                        .ThenBy(c => c.Title)
                        .ToListAsync();
                }


                return books;
            }
        }
    }
}
