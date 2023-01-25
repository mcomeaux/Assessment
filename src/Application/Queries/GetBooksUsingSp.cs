using MediatR;
using Assessment.Application.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Assessment.Application.Queries
{
    public class GetBooksUsingSp
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
                var result = await _dbContext.Books.FromSqlRaw($"EXECUTE dbo.GetAllBooks {request.SortBy}").ToListAsync();


                return result;
            }
        }
    }
}
